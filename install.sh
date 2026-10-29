#!/bin/bash
set -euo pipefail

REPO="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
VERSION="263.7084.0"
BUNDLE="$HOME/.local/share/intellij-server/$VERSION"
SERVER="$BUNDLE/bin/intellij-server"
PLUGIN="$HOME/.claude/skills/intellij-lsp"
EULA_RECORD="$HOME/Library/Application Support/JetBrains/IntelliJServer/eula-accepted.hashes"

case "$(uname -m)" in
  arm64) SUFFIX="-aarch64"; SHA256="ea728da71e3511939b4cb8e4af4aa5e4dda6e0ab7c2bdd1830a5d110bdf2bbec" ;;
  x86_64) SUFFIX=""; SHA256="3b31cd867ce0e361bfc763ba78cf4fa1dcb1a5324b97c817a0ec045532278420" ;;
  *) echo "unsupported architecture: $(uname -m)" >&2; exit 1 ;;
esac

JAVA_HOME="${JAVA_HOME:-$(/usr/libexec/java_home 2>/dev/null || true)}"
if [ -z "$JAVA_HOME" ] && command -v java >/dev/null; then
  JAVA_HOME="$(dirname "$(dirname "$(command -v java)")")"
fi
if ! "$JAVA_HOME/bin/java" -version >/dev/null 2>&1; then
  echo "no JDK found; set JAVA_HOME and run again" >&2
  exit 1
fi

if [ ! -x "$SERVER" ]; then
  TMP="$(mktemp -d)"
  trap 'rm -rf "$TMP"' EXIT
  curl -fL --retry 3 -o "$TMP/bundle.sit" \
    "https://download.jetbrains.com/language-server/intellij-server/$VERSION/intellij-server-$VERSION$SUFFIX.sit"
  echo "$SHA256  $TMP/bundle.sit" | shasum -a 256 -c -
  mkdir "$TMP/bundle"
  unzip -q "$TMP/bundle.sit" -d "$TMP/bundle"
  mkdir -p "$(dirname "$BUNDLE")"
  mv "$TMP/bundle"/*/ "$BUNDLE"
fi

EULA_HASH="$(shasum -a 256 "$BUNDLE/EULA.txt" | cut -c1-16)"
if ! grep -qs "$EULA_HASH" "$EULA_RECORD"; then
  less "$BUNDLE/EULA.txt"
  read -r -p "Accept the intellij-server EULA? [y/N] " answer
  [ "$answer" = "y" ] || exit 1
fi

if [ "$("$SERVER" license status --json | jq -r '.activeLicense.status // empty')" != "Valid" ]; then
  "$SERVER" license login
fi

rm -rf "$PLUGIN"
cp -R "$REPO/plugin" "$PLUGIN"
sed -i '' "s|__SERVER__|$SERVER|" "$PLUGIN/launch"
sed -i '' "s|__JAVA_HOME__|$JAVA_HOME|g" "$PLUGIN/.lsp.json"
chmod +x "$PLUGIN/launch"
claude plugin validate "$PLUGIN" | tail -1

echo
echo "Installed intellij-server $VERSION (JDK: $JAVA_HOME)"
echo "Restart Claude Code to load the intellij-lsp plugin."
