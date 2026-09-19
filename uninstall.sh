#!/data/data/com.termux/files/usr/bin/bash
#
# uninstall.sh — Completely remove OpenClaw native install
#
set -euo pipefail

say(){ printf '\033[1;36m[openclaw-native]\033[0m %s\n' "$*"; }

PREFIX="${PREFIX:-/data/data/com.termux/files/usr}"
HOME_DIR="${HOME:-/data/data/com.termux/files/home}"

say "Stopping any running OpenClaw processes..."
pkill -9 -f "openclaw" 2>/dev/null || true

say "Removing launcher and agent directories..."
rm -f "$PREFIX/bin/openclaw"
rm -rf "$HOME_DIR/agents/openclaw"
rm -rf "$HOME_DIR/.openclaw"
rm -rf "$HOME_DIR/.openclaw-android"

say "Uninstalling global npm package..."
npm uninstall -g openclaw >/dev/null 2>&1 || true

say "Cleaning environment overrides in .bashrc..."
sed -i '/openclaw/d' "$HOME_DIR/.bashrc" "$HOME_DIR/.profile" 2>/dev/null || true

say "OpenClaw successfully removed."
