#!/bin/bash
set -euo pipefail

SHARE="$HOME/.local/share/intellij-server"
SUPPORT="$HOME/Library/Application Support/JetBrains"
LOGS="$HOME/Library/Logs/JetBrains"
SETTINGS="$HOME/.claude/settings.json"

pkill -f "$SHARE/" 2>/dev/null || true

for server in "$SHARE"/*/bin/intellij-server; do
  if [ -x "$server" ]; then
    "$server" license reset --account || true
    break
  fi
done

rm -rf "$HOME/.claude/skills/intellij-lsp" \
  "$SHARE" \
  "$HOME/.cache/intellij-server" \
  "$SUPPORT/IntelliJServer" \
  "$LOGS"/intellij-server*
rmdir "$SUPPORT" "$LOGS" 2>/dev/null || true

defaults delete jetbrains.intellijserver.eula 2>/dev/null || true
rm -f "$HOME/Library/Preferences/jetbrains.intellijserver.eula.plist"

if [ -f "$SETTINGS" ] && jq -e '.skillOverrides["intellij-lsp"]' "$SETTINGS" >/dev/null; then
  jq 'del(.skillOverrides["intellij-lsp"])' "$SETTINGS" > "$SETTINGS.tmp"
  mv "$SETTINGS.tmp" "$SETTINGS"
fi

echo "Removed intellij-server and the intellij-lsp Claude Code plugin."
echo "Restart Claude Code to unload it."
