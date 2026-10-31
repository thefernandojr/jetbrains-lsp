# jetbrains-lsp

Runs JetBrains' `intellij-server` (IntelliJ IDEA's Java and Kotlin engine over LSP) as a Claude Code language server, through a local plugin at `~/.claude/skills/intellij-lsp`.

Needs a JDK (`JAVA_HOME` or `java` on `PATH`), `python3`, and an IntelliJ IDEA Ultimate license after the 30-day trial.

## Install

    ./install.sh

Downloads and verifies the server bundle, asks you to accept its EULA, signs you in to a JetBrains Account if the machine has no license, and writes the plugin. Restart Claude Code afterwards.

All Claude Code sessions share one server, which starts with the first session and stops after 10 minutes with none. Each project or worktree gets its own index under `~/.cache/intellij-server/claude/`. The first session in a new one builds that index in a separate process that exits when done, so the shared server never holds the memory peak of first-time indexing. Indexes unused for 14 days are deleted when a session starts.

The shared server logs to `~/.cache/intellij-server/claude/server/system/log/intellij-server.log`, and first-time indexing to `system/log/` inside that project's index folder. Grep for `LspClient` (sessions connecting and disconnecting), `Updated N files` (a warm index opened) and `Rejecting connection` (something other than an LSP client connected).

## Uninstall

    ./uninstall.sh

Stops running servers, deactivates the machine's server license and signs this machine out of your JetBrains Account (`license reset --account`, which also signs out any JetBrains IDE installed here), and removes:

- `~/.claude/skills/intellij-lsp`
- `~/.local/share/intellij-server`
- `~/.cache/intellij-server` (OpenCode's index included)
- `~/Library/Application Support/JetBrains/IntelliJServer`
- `~/Library/Logs/JetBrains/intellij-server*`
- `~/Library/Preferences/jetbrains.intellijserver.eula.plist`
- the `intellij-lsp` entry in `skillOverrides` of `~/.claude/settings.json`

OpenCode's `lsp.intellij` entry in `~/.config/opencode/opencode.jsonc` is left in place.
