---
description: Use Xcode's built-in MCP tools (server `xcode`, command `xcrun mcpbridge`) to build, run, test, preview, and inspect Apple-platform projects. Covers prerequisites, the 54 tools grouped by task, and typical workflows.
name: xcode-mcp
---

# Xcode MCP integration

This plugin exposes Xcode itself as an MCP server named `xcode`. The server is
`xcrun mcpbridge` — the same integration Apple ships for Claude Code
(`xcode@claude-plugins-official`). All Xcode operations go through Xcode, so
Xcode's own rules apply.

## Prerequisites (check before starting work)

1. **macOS with Xcode installed** (Xcode 26.3+; full agent/plugin tooling is in
   Xcode 27). The plugin's launcher resolves Xcode automatically.
2. **Open the project or workspace in Xcode first.** Apple's documented flow
   for external agents requires the project to be open in the IDE.
3. **External agents allowed**: Xcode Settings → Intelligence → allow external
   agents. Xcode shows an alert when an agent connects and while it is active.
4. If a tool errors with "no workspace", open the workspace in Xcode
   (`XcodeOpenWorkspace` can do it) and retry.

## Tool groups (54 tools)

- **Workspace / project structure**: `XcodeListWorkspaces`, `XcodeOpenWorkspace`,
  `XcodeCloseWorkspace`, `XcodeListSchemes`, `XcodeListTargets`,
  `XcodeListTestPlans`, `XcodeListRunDestinations`, `XcodeListTemplates`,
  `XcodeSwitchScheme`, `XcodeSwitchTestPlan`, `XcodeSwitchRunDestination`,
  `XcodeNewProject`, `XcodeNewTarget`, `XcodeUpdate`
- **Project file access** (sandboxed to the project): `XcodeRead`, `XcodeWrite`,
  `XcodeLS`, `XcodeGlob`, `XcodeGrep`, `XcodeMV`, `XcodeRM`, `XcodeMakeDir`
  — prefer these over raw shell access so Xcode stays in sync; use `XcodeRefreshCodeIssuesInFile`
  after writing Swift/Obj-C sources
- **Build / run / test**: `BuildProject`, `RunProject`, `StopProject`,
  `RunAllTests`, `RunSomeTests`, `GetTestList`, `RunCodeSnippet`,
  `GetBuildLog`, `GetConsoleOutput`
- **SwiftUI previews**: `RenderPreview`
- **Simulators / devices**: `DeviceInteractionStartSession`,
  `DeviceInteractionStartWorkspaceSession`, `DeviceInteractionInstallAndRun`,
  `DeviceInteractionSynthesize` (touch/input events), `DeviceInteractionEndSession`
- **Diagnostics**: `GetCrashIssueLogs`, `GetTopCrashIssues`,
  `GetFieldPerformanceIssueLogs`, `GetTopFieldPerformanceIssues`,
  `InvokeDebuggerCommand`
- **Configuration**: `GetTargetBuildSettings`, `UpdateTargetBuildSetting`,
  `GetFileCompilerFlags`, `UpdateFileCompilerFlags`, `AddEntitlement`,
  `AddInfoPlist`
- **Localization**: `StringCatalogRead`, `StringCatalogEdit`,
  `StringCatalogContext`, `LocalizationPlanner`
- **Documentation**: `DocumentationSearch` — search Apple developer
  documentation; prefer it over web search for Apple APIs

## Typical workflows

**Fix a build error**: `BuildProject` → `GetBuildLog` → read the failing file
with `XcodeRead` → edit with `XcodeWrite` → `XcodeRefreshCodeIssuesInFile` →
`BuildProject` again.

**Run the app on a simulator**: `XcodeListRunDestinations` →
`XcodeSwitchRunDestination` → `RunProject` → `GetConsoleOutput`. For deeper
interaction (taps, screenshots): `DeviceInteractionStartWorkspaceSession` →
`DeviceInteractionInstallAndRun` → `DeviceInteractionSynthesize`.

**Run a subset of tests**: `GetTestList` → `RunSomeTests` (or `RunAllTests`).

**Add a capability**: check whether it really needs an entitlement (most Apple
APIs do not) before calling `AddEntitlement`; privacy usage descriptions are
Info.plist keys — use `AddInfoPlist`.

## Notes

- Tools that mutate the project (write, move, settings) should go through the
  Xcode* tools, not shell commands, so Xcode's index and UI stay consistent.
- The 15 Apple-authored skills bundled with this plugin (`swiftui-specialist`,
  `app-intents-specialist`, `modernize-tests`, etc.) carry Apple's current
  best practices and supersede older training on those topics — consult them
  when doing matching work.
