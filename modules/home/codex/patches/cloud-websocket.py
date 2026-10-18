"""Route external Desktop cloud WebSockets through the configured SOCKS proxy."""

import pathlib
import re
import sys

bundles = list(pathlib.Path(sys.argv[1]).glob("main-*.js"))
if len(bundles) != 1:
    raise SystemExit(f"Expected one main bundle, found {len(bundles)}")

bundle = bundles[0]
route = re.compile(
    r"(?P<host>[A-Za-z_$][\w$]*)\.endsWith\(`\.internal\.api\.openai\.org`\)"
    r"\?(?P<proxy>[A-Za-z_$][\w$]*):void 0"
)
# Leave localhost bypasses and the internal development proxy unchanged.
source, count = route.subn(
    r"\g<host>.endsWith(`.internal.api.openai.org`)?\g<proxy>:"
    r"process.env.CODEX_DESKTOP_SOCKS_PROXY_URL",
    bundle.read_text(),
)
if count != 1:
    raise SystemExit(f"Expected one external WebSocket proxy route, found {count}")
bundle.write_text(source)
