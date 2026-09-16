#!/usr/bin/env bash
# Build dist/bee.plugin (a zip Cowork can install).
# Usage: bash scripts/package.sh [output-dir]
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OUT="${1:-$ROOT/dist}"
mkdir -p "$OUT"
rm -f "$OUT/bee.plugin"

cd "$ROOT"
zip -rq "$OUT/bee.plugin" . \
  -x ".git/*" -x ".github/*" -x "scripts/*" -x "dist/*" \
  -x "HANDOFF.md" -x "SNAPSHOT.md" -x "*.DS_Store"

VERSION="$(python3 -c 'import json;print(json.load(open(".claude-plugin/plugin.json"))["version"])')"
echo "built $OUT/bee.plugin (v$VERSION)"
