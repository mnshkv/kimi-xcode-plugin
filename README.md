# kimi-xcode-plugin

**Use Xcode from [Kimi Code](https://www.kimi.com/code) — builds, tests, SwiftUI previews, simulators, device interaction, build logs, and Apple docs, through Xcode's own MCP server.**

The same integration Apple ships for Claude Code as `xcode@claude-plugins-official`, repackaged as a Kimi Code plugin. Zero Apple code is redistributed here: the plugin activates the Xcode already installed on your Mac.

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Platform: macOS](https://img.shields.io/badge/Platform-macOS-black.svg)]()
[![Kimi Code](https://img.shields.io/badge/Kimi%20Code-plugin-orange.svg)](https://www.kimi.com/code/docs/en/kimi-code-cli/customization/plugins.html)

## Why

On November 6, 2026, Apple merged an official Xcode plugin into Anthropic's Claude Code marketplace. It gives the agent direct access to Xcode: build and test schemes, render SwiftUI previews, drive simulators and devices, read build logs — 54 tools over MCP. The catch: it only works in Claude Code.

This plugin wires the **exact same machinery** into Kimi Code and Kimi Code Desktop: `xcrun mcpbridge`, the MCP server built into Xcode itself.

## Features

| Area | What you can ask your agent to do |
|---|---|
| Build & run | Build schemes, run and stop the app, read console output |
| Testing | List tests, run all or a subset, modernize XCTest suites |
| SwiftUI | Render previews and iterate on the result visually |
| Devices | Start sessions, install & launch on simulators and devices, synthesize taps and input |
| Diagnostics | Build logs, crash logs, field performance issues, debugger commands |
| Project files | Sandbox-scoped read/write/glob/grep/ls/mv/rm that keeps Xcode's index in sync |
| Configuration | Build settings, entitlements, Info.plist, per-file compiler flags |
| Localization | Read/edit String Catalogs (`.xcstrings`), translation planning |
| Documentation | Search Apple developer documentation directly |

Plus the **Apple-authored agent skills** that Xcode exports for coding assistants (SwiftUI best practices, App Intents, accessibility audits, security-settings audits, and more) — pulled from *your* Xcode, never from this repo.

## Install

In any Kimi Code session:

```
/plugins install https://github.com/mnshkv/kimi-xcode-plugin
```

Then `/plugins reload` (or start a new session).

Optional — also pull Apple's skills from your local Xcode into the plugin:

```sh
git clone https://github.com/mnshkv/kimi-xcode-plugin
cd kimi-xcode-plugin
./scripts/export-from-xcode.sh
/plugins install ./kimi-xcode-plugin   # from the Kimi Code session
```

## Usage

Open your project in Xcode, allow external agents in **Xcode Settings → Intelligence**, then just ask:

- "Build the app and fix any errors"
- "Run the tests for the Networking target"
- "Render the preview for `ContentView` and make the padding look right"
- "Boot the iPhone 17 simulator, install the app, and tap through onboarding"

The bundled `xcode-mcp` skill documents all 54 tools and typical workflows.

## How it works

```
Kimi Code ──MCP (stdio)──▶ bin/xcode-mcp.sh ──▶ xcrun mcpbridge ──▶ Xcode
                                                              └─▶ simulators, devices,
                                                                  builds, logs, docs
```

- `xcrun mcpbridge` is Apple's own MCP server (server name `xcode-tools`); it ships with Xcode 26.3+, and the agent-plugin export requires Xcode 27+.
- The launcher resolves the right Xcode (`DEVELOPER_DIR` → `/Applications/Xcode*.app` → `xcode-select` → `PATH`).
- Apple's skills are exported from your Xcode via `xcrun agent plugin path --plugin-format claude`; the repo itself contains only the wrapper.

## Requirements

- macOS with Xcode (26.3+; the skills export needs 27+)
- The project/workspace open in Xcode, with external agents allowed (Xcode shows an alert while an agent is connected)

## FAQ

**Is this an official Apple or Kimi product?**
No — it's a community wrapper. The MCP server and the skills belong to Apple and come from the Xcode installed on your machine; this repo only packages them for Kimi Code's plugin format.

**Why aren't Apple's skills committed to the repo?**
They are Apple's content, shipped inside Xcode. Redistribution could get the repo taken down; exporting them from your own Xcode keeps everything clean and always up to date.

**What if I use Claude Code too?**
Keep Apple's official plugin — both consume the same Xcode underneath and don't conflict.

## Contributing

Issues and PRs welcome — especially launcher robustness, docs, and new workflow skills.

## License

MIT for the wrapper. The MCP server and exported skills are © Apple Inc. and ship with Xcode.
