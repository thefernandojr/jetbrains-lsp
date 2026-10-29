# jetbrains-lsp

Runs JetBrains' `intellij-server` (IntelliJ IDEA's Java and Kotlin engine over LSP) as a Claude Code language server, through a local plugin at `~/.claude/skills/intellij-lsp`.

Needs a JDK (`JAVA_HOME` or `java` on `PATH`) and an IntelliJ IDEA Ultimate license after the 30-day trial.

## Install

    ./install.sh

Downloads and verifies the server bundle, asks you to accept its EULA, signs you in to a JetBrains Account if the machine has no license, and writes the plugin. Restart Claude Code afterwards.

Each project gets its own index under `~/.cache/intellij-server/claude/`. A second Claude Code session on the same project gets a second index, because the server locks its index.

## Uninstall

    ./uninstall.sh

Stops running servers, deactivates the machine's server license (`license reset`, without signing out of your JetBrains Account), and removes:

- `~/.claude/skills/intellij-lsp`
- `~/.local/share/intellij-server`
- `~/.cache/intellij-server` (OpenCode's index included)
- `~/Library/Application Support/JetBrains/IntelliJServer`
- `~/Library/Logs/JetBrains/intellij-server*`
- `~/Library/Preferences/jetbrains.intellijserver.eula.plist`
- the `intellij-lsp` entry in `skillOverrides` of `~/.claude/settings.json`

OpenCode's `lsp.intellij` entry in `~/.config/opencode/opencode.jsonc` is left in place.
