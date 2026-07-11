#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
repo_root="$(cd -- "$script_dir/../../../../.." && pwd -P)"
nix_update_path="$repo_root/spreadconfig/scripts/default/nix/nix_update"
nix_full_update_path="$repo_root/spreadconfig/scripts/default/nix/nix_full_update"
test_root="$(mktemp -d "${TMPDIR:-/tmp}/nix_update_local_packages_test.XXXXXX")"
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
		fail "unexpected command order"
	fi
}

new_update_fixture() {
	local name="$1"

	fixture="$test_root/$name"
	fake_bin="$fixture/bin"
	fake_repo="$fixture/repo"
	call_log="$fixture/calls.log"
	stdout_log="$fixture/stdout.log"
	stderr_log="$fixture/stderr.log"
	mkdir -p "$fake_bin" "$fake_repo"
	: >"$call_log"

	cat >"$fake_bin/nix" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail

if [[ "$1" == "eval" ]]; then
	printf '%s\n' '["alpha","beta"]'
	exit 0
fi

if [[ "$1" == "flake" && "$2" == "update" ]]; then
	printf '%s\n' "flake-update" >>"$CALL_LOG"
	exit 0
fi

echo "unexpected nix invocation: $*" >&2
exit 97
EOF

	cat >"$fake_bin/update_local_packages" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail

printf '%s\n' "local-packages" >>"$CALL_LOG"
if [[ "${FAKE_LOCAL_UPDATE_FAIL:-0}" == "1" ]]; then
	exit 42
fi
EOF

	cat >"$fake_bin/sns_until" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail

printf 'sns_until\t%s\n' "$1" >>"$CALL_LOG"
EOF

	chmod +x "$fake_bin/nix" "$fake_bin/update_local_packages" "$fake_bin/sns_until"
}

run_nix_update() {
	PATH="$fake_bin:$PATH" \
		CALL_LOG="$call_log" \
		FAKE_LOCAL_UPDATE_FAIL="${FAKE_LOCAL_UPDATE_FAIL:-0}" \
		NIX_RETRY_ATTEMPTS=1 \
		SPREADCONFIG_REPO="$fake_repo" \
		bash "$nix_update_path" --no-exclude-file "$@" >"$stdout_log" 2>"$stderr_log"
}

test_updates_local_packages_between_flake_and_rebuild() {
	local expected

	new_update_fixture normal
	expected="$fixture/expected.log"
	FAKE_LOCAL_UPDATE_FAIL=0

	run_nix_update switch || fail "expected nix_update to succeed"

	{
		printf '%s\n' "flake-update"
		printf '%s\n' "local-packages"
		printf 'sns_until\tswitch\n'
	} >"$expected"
	assert_file_equals "$expected" "$call_log"
	tests_run=$((tests_run + 1))
}

test_all_excluded_inputs_still_update_local_packages() {
	local expected

	new_update_fixture excluded
	expected="$fixture/expected.log"
	FAKE_LOCAL_UPDATE_FAIL=0

	run_nix_update boot --exclude alpha,beta || fail "expected excluded update to succeed"

	{
		printf '%s\n' "local-packages"
		printf 'sns_until\tboot\n'
	} >"$expected"
	assert_file_equals "$expected" "$call_log"
	tests_run=$((tests_run + 1))
}

test_local_package_failure_skips_rebuild() {
	new_update_fixture local-failure
	FAKE_LOCAL_UPDATE_FAIL=1

	if run_nix_update boot; then
		fail "expected local package failure to propagate"
	fi

	assert_contains "$call_log" "flake-update"
	assert_contains "$call_log" "local-packages"
	assert_not_contains "$call_log" "sns_until"
	tests_run=$((tests_run + 1))
}

test_full_update_failure_skips_cleanup() {
	local fixture="$test_root/full-update-failure"
	local fake_bin="$fixture/bin"
	local call_log="$fixture/calls.log"
	local stdout_log="$fixture/stdout.log"
	local stderr_log="$fixture/stderr.log"

	mkdir -p "$fake_bin"
	: >"$call_log"
	cat >"$fake_bin/nix_update" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
printf '%s\n' "nix_update" >>"$CALL_LOG"
exit 23
EOF
	cat >"$fake_bin/nix_clean" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
printf '%s\n' "nix_clean" >>"$CALL_LOG"
EOF
	chmod +x "$fake_bin/nix_update" "$fake_bin/nix_clean"

	if PATH="$fake_bin:$PATH" CALL_LOG="$call_log" \
		bash "$nix_full_update_path" boot >"$stdout_log" 2>"$stderr_log"; then
		fail "expected nix_full_update failure to propagate"
	fi

	assert_contains "$call_log" "nix_update"
	assert_not_contains "$call_log" "nix_clean"
	tests_run=$((tests_run + 1))
}

test_updates_local_packages_between_flake_and_rebuild
test_all_excluded_inputs_still_update_local_packages
test_local_package_failure_skips_rebuild
test_full_update_failure_skips_cleanup

echo "PASS: $tests_run nix update integration tests"
