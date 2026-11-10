#!/bin/bash
# Launcher for Xcode's built-in MCP server (xcrun mcpbridge).
# Resolves the Developer directory in order:
#   1. $DEVELOPER_DIR, if set and containing usr/bin/xcrun
#   2. Xcode.app at well-known locations
#   3. `xcode-select -p`, if it points to a full Xcode
#   4. xcrun from PATH as a last resort
set -u

find_xcrun() {
    if [ -n "${DEVELOPER_DIR:-}" ] && [ -x "${DEVELOPER_DIR}/usr/bin/xcrun" ]; then
        echo "${DEVELOPER_DIR}/usr/bin/xcrun"
        return 0
    fi
    local app
    for app in /Applications/Xcode.app /Applications/Xcode-beta.app /Applications/Xcode-*.app; do
        if [ -x "${app}/Contents/Developer/usr/bin/xcrun" ]; then
            echo "${app}/Contents/Developer/usr/bin/xcrun"
            return 0
        fi
    done
    local dev
    dev="$(xcode-select -p 2>/dev/null || true)"
    if [ -n "$dev" ] && [ -x "${dev}/usr/bin/xcrun" ]; then
        echo "${dev}/usr/bin/xcrun"
        return 0
    fi
    if command -v xcrun >/dev/null 2>&1; then
        echo "xcrun"
        return 0
    fi
    return 1
}

XCRUN="$(find_xcrun)" || {
    echo "xcode plugin: Xcode not found. Install Xcode from the App Store or https://developer.apple.com/downloads, then re-enable the plugin MCP server." >&2
    exit 1
}

exec "$XCRUN" mcpbridge
