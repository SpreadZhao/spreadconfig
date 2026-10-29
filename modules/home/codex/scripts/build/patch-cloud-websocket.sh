#!/usr/bin/env bash

resources="$1/opt/codex-desktop/resources"
patch_script=$2
layout_helper=$3
extracted="$TMPDIR/cloud-websocket-asar"
asar list --is-pack "$resources/app.asar" >"$TMPDIR/cloud-websocket-layout"
asar extract "$resources/app.asar" "$extracted"
cp -a "$resources/app.asar.unpacked/." "$extracted/"
chmod -R u+w "$extracted"
python3 "$patch_script" "$extracted/.vite/build"
node --check "$extracted"/.vite/build/main-*.js

node "$layout_helper" "$TMPDIR/cloud-websocket-layout" "$extracted" \
    "$TMPDIR/cloud-websocket-ordering" "$TMPDIR/cloud-websocket-unpack"
unpack_args=()
unpack_pattern="$(cat "$TMPDIR/cloud-websocket-unpack")"
if [[ -n "$unpack_pattern" ]]; then
    unpack_args=(--unpack-dir "$unpack_pattern")
fi
asar pack "$extracted" "$TMPDIR/cloud-websocket.asar" \
    --ordering "$TMPDIR/cloud-websocket-ordering" \
    --unpack '{*.node,*.so,*.dylib}' "${unpack_args[@]}"
asar list --is-pack "$TMPDIR/cloud-websocket.asar" >"$TMPDIR/cloud-websocket-output-layout"
node "$layout_helper" verify "$TMPDIR/cloud-websocket-layout" "$TMPDIR/cloud-websocket-output-layout"
mv "$TMPDIR/cloud-websocket.asar" "$resources/app.asar"
