#!/bin/bash
# Re-export skills from the installed Xcode into this plugin.
# Run after every Xcode update, then reinstall the plugin
# (/plugins install <this-directory>) so the managed copy picks the changes up.
set -euo pipefail

PLUGIN_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
EXPORTED="$(xcrun agent plugin path --plugin-format claude)"

if [ -z "$EXPORTED" ] || [ ! -d "$EXPORTED" ]; then
    echo "error: Xcode did not export a Claude-format plugin (need recent Xcode)" >&2
    exit 1
fi

echo "Source: $EXPORTED"

# Remove previously exported Apple skills (keep xcode-mcp), then copy fresh.
find "$PLUGIN_ROOT/skills" -mindepth 1 -maxdepth 1 -not -name xcode-mcp -exec rm -rf {} +
cp -R "$EXPORTED/skills/." "$PLUGIN_ROOT/skills/"

BUILD="$(defaults read /Applications/Xcode.app/Contents/version.plist CFBundleVersion 2>/dev/null || echo unknown)"
cat > "$PLUGIN_ROOT/export-info.json" <<EOF
{
  "exportedFrom": "$EXPORTED",
  "xcodeBuild": "$BUILD",
  "exportedAt": "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
}
EOF

echo "Updated skills in $PLUGIN_ROOT/skills (Xcode build $BUILD)"
