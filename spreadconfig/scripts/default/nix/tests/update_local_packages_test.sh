#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
repo_root="$(cd -- "$script_dir/../../../../.." && pwd -P)"
command_path="$repo_root/spreadconfig/scripts/default/nix/update_local_packages"
test_root="$(mktemp -d "${TMPDIR:-/tmp}/update_local_packages_test.XXXXXX")"
trap 'rm -rf "$test_root"' EXIT

tests_run=0

fail() {
	echo "FAIL: $*" >&2
	exit 1
}

assert_contains() {
	local file="$1"
	local expected="$2"

	grep -Fqx -- "$expected" "$file" || fail "expected '$expected' in $file"
}

assert_not_contains() {
	local file="$1"
	local unexpected="$2"

	if grep -Fq -- "$unexpected" "$file"; then
		fail "did not expect '$unexpected' in $file"
	fi
}

assert_file_equals() {
	local expected="$1"
	local actual="$2"

	if ! diff -u "$expected" "$actual"; then
		fail "unexpected command log"
	fi
}

assert_line_count() {
	local file="$1"
	local expected="$2"
	local count="$3"
	local actual

	actual="$(grep -Fxc -- "$expected" "$file" || true)"
	[[ "$actual" == "$count" ]] || fail "expected '$expected' $count time(s) in $file, found $actual"
}

new_fixture() {
	local name="$1"

	fixture="$test_root/$name"
	fake_bin="$fixture/bin"
	fake_repo="$fixture/repo"
	fake_state="$fixture/state"
	call_log="$fixture/calls.log"
	stdout_log="$fixture/stdout.log"
	stderr_log="$fixture/stderr.log"
	mkdir -p "$fake_bin" "$fake_repo" "$fake_state"
	: >"$call_log"

	cat >"$fake_bin/nix" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail

if [[ "$1" == "eval" && "$*" == *"builtins.currentSystem"* ]]; then
	printf '%s\n' "${FAKE_SYSTEM:-x86_64-linux}"
	exit 0
fi

if [[ "$1" == "eval" ]]; then
	printf '%s\n' "$FAKE_PACKAGE_STATUS_JSON"
	exit 0
fi

if [[ "$1" == "build" ]]; then
	printf 'build' >>"$CALL_LOG"
	printf '\t%s' "${@:2}" >>"$CALL_LOG"
	printf '\n' >>"$CALL_LOG"
	exit 0
fi

echo "unexpected nix invocation: $*" >&2
exit 97
EOF

	cat >"$fake_bin/nix-update" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail

printf 'update\t%s\t%s' "$PWD" "$1" >>"$CALL_LOG"
printf '\t%s' "${@:2}" >>"$CALL_LOG"
printf '\n' >>"$CALL_LOG"

attempt_file="$FAKE_STATE_DIR/$1.attempts"
attempt=0
if [[ -f "$attempt_file" ]]; then
	read -r attempt <"$attempt_file"
fi
attempt=$((attempt + 1))
printf '%s\n' "$attempt" >"$attempt_file"

if [[ "${FAKE_FAIL_PACKAGE:-}" == "$1" ]] && ((attempt <= ${FAKE_FAIL_ATTEMPTS:-0})); then
	exit 42
fi
EOF

	cat >"$fake_bin/sleep" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail

printf 'sleep\t%s\n' "$1" >>"$CALL_LOG"
EOF

	chmod +x "$fake_bin/nix" "$fake_bin/nix-update" "$fake_bin/sleep"
}

run_command() {
	PATH="$fake_bin:$PATH" \
		CALL_LOG="$call_log" \
		FAKE_PACKAGE_STATUS_JSON="$FAKE_PACKAGE_STATUS_JSON" \
		FAKE_FAIL_PACKAGE="${FAKE_FAIL_PACKAGE:-}" \
		FAKE_FAIL_ATTEMPTS="${FAKE_FAIL_ATTEMPTS:-0}" \
		FAKE_STATE_DIR="$fake_state" \
		SPREADCONFIG_REPO="$fake_repo" \
		bash "$command_path" >"$stdout_log" 2>"$stderr_log"
}

test_updates_in_sorted_order_then_builds_every_package() {
	local expected

	new_fixture sorted
	expected="$fixture/expected.log"
	FAKE_PACKAGE_STATUS_JSON='{"zcode":true,"bili23-downloader":true,"cc-connect":true}'
	FAKE_FAIL_PACKAGE=""
	FAKE_FAIL_ATTEMPTS=0

	run_command || fail "expected update command to succeed"

	{
		printf 'update\t%s\tbili23-downloader\t--flake\t--use-update-script\n' "$fake_repo"
		printf 'update\t%s\tcc-connect\t--flake\t--use-update-script\n' "$fake_repo"
		printf 'update\t%s\tzcode\t--flake\t--use-update-script\n' "$fake_repo"
		printf 'build\t--no-link\tpath://%s#bili23-downloader\tpath://%s#cc-connect\tpath://%s#zcode\n' \
			"$fake_repo" "$fake_repo" "$fake_repo"
	} >"$expected"
	assert_file_equals "$expected" "$call_log"
	tests_run=$((tests_run + 1))
}

test_missing_updater_fails_before_mutation() {
	new_fixture missing-updater
	FAKE_PACKAGE_STATUS_JSON='{"bili23-downloader":true,"cc-connect":false,"zcode":false}'
	FAKE_FAIL_PACKAGE=""
	FAKE_FAIL_ATTEMPTS=0

	if run_command; then
		fail "expected missing updater preflight to fail"
	fi

	[[ ! -s "$call_log" ]] || fail "preflight failure ran a mutating command"
	assert_contains "$stderr_log" "update_local_packages: packages missing updateScript: cc-connect zcode"
	tests_run=$((tests_run + 1))
}

test_empty_package_set_is_a_configuration_error() {
	new_fixture empty-package-set
	FAKE_PACKAGE_STATUS_JSON='{}'
	FAKE_FAIL_PACKAGE=""
	FAKE_FAIL_ATTEMPTS=0

	if run_command; then
		fail "expected an empty package set to fail"
	fi

	[[ ! -s "$call_log" ]] || fail "empty package preflight ran a mutating command"
	assert_contains "$stderr_log" "update_local_packages: the root flake exports no packages for x86_64-linux"
	tests_run=$((tests_run + 1))
}

test_transient_updater_failure_is_retried() {
	local expected

	new_fixture transient-updater-failure
	expected="$fixture/expected.log"
	FAKE_PACKAGE_STATUS_JSON='{"alpha":true}'
	FAKE_FAIL_PACKAGE="alpha"
	FAKE_FAIL_ATTEMPTS=2

	run_command || fail "expected updater to succeed on the third attempt"

	{
		printf 'update\t%s\talpha\t--flake\t--use-update-script\n' "$fake_repo"
		printf 'sleep\t2\n'
		printf 'update\t%s\talpha\t--flake\t--use-update-script\n' "$fake_repo"
		printf 'sleep\t4\n'
		printf 'update\t%s\talpha\t--flake\t--use-update-script\n' "$fake_repo"
		printf 'build\t--no-link\tpath://%s#alpha\n' "$fake_repo"
	} >"$expected"
	assert_file_equals "$expected" "$call_log"
	tests_run=$((tests_run + 1))
}

test_failed_updater_stops_remaining_work_after_three_attempts() {
	new_fixture updater-failure
	FAKE_PACKAGE_STATUS_JSON='{"alpha":true,"beta":true,"gamma":true}'
	FAKE_FAIL_PACKAGE="beta"
	FAKE_FAIL_ATTEMPTS=99

	if run_command; then
		fail "expected updater failure to propagate"
	fi

	assert_contains "$call_log" $'update\t'"$fake_repo"$'\talpha\t--flake\t--use-update-script'
	assert_line_count "$call_log" $'update\t'"$fake_repo"$'\tbeta\t--flake\t--use-update-script' 3
	assert_line_count "$call_log" $'sleep\t2' 1
	assert_line_count "$call_log" $'sleep\t4' 1
	assert_not_contains "$call_log" $'\tgamma\t'
	assert_not_contains "$call_log" $'build\t'
	assert_contains "$stderr_log" "update_local_packages: failed to update beta after 3 attempts"
	tests_run=$((tests_run + 1))
}

test_updates_in_sorted_order_then_builds_every_package
test_missing_updater_fails_before_mutation
test_empty_package_set_is_a_configuration_error
test_transient_updater_failure_is_retried
test_failed_updater_stops_remaining_work_after_three_attempts

echo "PASS: $tests_run update_local_packages tests"
