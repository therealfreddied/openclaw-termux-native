#!/data/data/com.termux/files/usr/bin/bash
#
# install.sh — OpenClaw CLI, native on Termux (aarch64). No proot, no root.
#
set -euo pipefail

# 1. Clear preload hooks so clang and node builds don't collide
unset LD_PRELOAD

say(){ printf '\033[1;36m[openclaw-native]\033[0m %s\n' "$*"; }
die(){ printf '\033[1;31m[openclaw-native] ERROR:\033[0m %s\n' "$*" >&2; exit 1; }

PREFIX="${PREFIX:-/data/data/com.termux/files/usr}"
HOME_DIR="${HOME:-/data/data/com.termux/files/home}"
DIR="$HOME_DIR/agents/openclaw"

[ -d "$PREFIX" ] || die "Not a Termux environment."

case "$(uname -m)" in
  aarch64|arm64) ;;
  *) die "arm64/aarch64 only (found $(uname -m)).";;
esac

# 2. Clean up legacy hijacked paths from previous PRoot/wrapper attempts
if [ -d "$HOME_DIR/.openclaw-android" ]; then
  say "Cleaning up legacy .openclaw-android directory..."
  rm -rf "$HOME_DIR/.openclaw-android"
  sed -i '/\.openclaw-android/d' "$HOME_DIR/.bashrc" "$HOME_DIR/.profile" 2>/dev/null || true
fi

say "Installing base dependencies (nodejs-lts clang git ripgrep)…"
pkg update -y >/dev/null 2>&1 || true
pkg install -y nodejs-lts python make clang git ripgrep termux-tools >/dev/null 2>&1 || die "pkg install failed."

mkdir -p "$DIR"
export TMPDIR="$PREFIX/tmp"
mkdir -p "$TMPDIR"
export CC=clang
export CXX=clang++

say "Installing OpenClaw natively via npm (building native bindings)…"
npm install -g --build-from-source openclaw >/dev/null 2>&1 || {
  # If openclaw is scoped or needs local installation
  npm install --prefix "$DIR" --build-from-source openclaw >/dev/null 2>&1 || die "npm install failed."
}

# 3. Locate the installed binary and patch Android shebangs
TARGET_BIN="$(which openclaw 2>/dev/null || find "$PREFIX/lib/node_modules" "$DIR" -type f -name "openclaw" 2>/dev/null | head -1)"

if [ -z "$TARGET_BIN" ]; then
  die "Failed to locate installed openclaw binary."
fi

termux-fix-shebang "$TARGET_BIN" 2>/dev/null || true

# 4. Create launcher wrapper at $DIR/launcher.sh
cat << 'EOF' > "$DIR/launcher.sh"
#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail

PREFIX="${PREFIX:-/data/data/com.termux/files/usr}"
HOME_DIR="${HOME:-/data/data/com.termux/files/home}"
DIR="$HOME_DIR/agents/openclaw"

if [ "${1:-}" = "update" ] || [ "${1:-}" = "upgrade" ]; then
  printf '\033[1;36m[openclaw-native]\033[0m Updating OpenClaw...\n'
  export CC=clang
  export CXX=clang++
  npm install -g --build-from-source openclaw@latest >/dev/null 2>&1 || {
    npm install --prefix "$DIR" --build-from-source openclaw@latest >/dev/null 2>&1
  }
  printf '\033[1;32m[openclaw-native]\033[0m Updated successfully!\n'
  exit 0
fi

export TMPDIR="$PREFIX/tmp"
mkdir -p "$TMPDIR"
unset NODE_OPTIONS

TARGET_BIN="$(which openclaw 2>/dev/null || find "$PREFIX/lib/node_modules" "$DIR" -type f -name "openclaw" 2>/dev/null | head -1)"
exec node "$TARGET_BIN" "$@"
EOF

chmod 755 "$DIR/launcher.sh"
ln -sf "$DIR/launcher.sh" "$PREFIX/bin/openclaw"

say "Verifying…"
if openclaw --version >/dev/null 2>&1; then
  say "Installed OpenClaw $(openclaw --version 2>/dev/null | head -1) — native, no proot."
else
  say "Installed; run 'openclaw'."
fi

echo
say "Run:    openclaw (start CLI/TUI)"
say "Update: openclaw update (native npm update; never use PRoot/custom installers)"
