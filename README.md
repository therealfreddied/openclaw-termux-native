# openclaw-termux-native

Run **[OpenClaw](https://github.com/therealfreddied/openclaw-termux-native) natively on Termux** (Android · aarch64) — **no proot, no root, no battery drain.**

Standard OpenClaw install scripts on Android try to spin up delicate PRoot containers or dump bundled, hijacked Node environments into `~/.openclaw-android` that force broken `NODE_OPTIONS` and pollute your shell `$PATH`. This installer eliminates the container overhead, running OpenClaw directly on the native Termux layer with full hardware performance.

> Runtime only — no account data. Configure your keys and providers directly within OpenClaw.

## Demo — OpenClaw running native

Running directly on bare Android hardware without PRoot virtualization layers, ptrace overhead, or container file locks:

![OpenClaw native install](screenshots/openclaw-native.png)

## How it works

| Piece | Role |
|-------|------|
| **Native Bionic / Glibc Toolchain** | Bypasses slow `ptrace` system call emulation used by PRoot Ubuntu, executing directly against Android's native Linux kernel. |
| **Clean Process Execution** | Scrubs `LD_PRELOAD` during compilation and tool execution so child processes (like `git`, `bash`, and `ripgrep`) execute cleanly without library symbol collisions. |
| **Isolated Path Management** | Bypasses the broken `~/.openclaw-android` wrappers and places a clean launcher at `$PREFIX/bin/openclaw`. Temporary directories are routed directly to `$PREFIX/tmp`. |

No root, no proot, no container reboot — full filesystem access and instant sub-second boot times.

## Requirements
- Termux on **aarch64 / arm64**
- Internet on first run

## Install
```bash
git clone [https://github.com/therealfreddied/openclaw-termux-native](https://github.com/therealfreddied/openclaw-termux-native)
cd openclaw-termux-native
bash install.sh
```
or one-shot:
```bash
curl -fsSL [https://raw.githubusercontent.com/therealfreddied/openclaw-termux-native/refs/heads/main/install.sh](https://raw.githubusercontent.com/therealfreddied/openclaw-termux-native/refs/heads/main/install.sh) | bash
```
Then:
```bash
openclaw                # Start TUI / interactive session
openclaw run "..."      # Run a one-shot command
```

## Updating

```bash
openclaw update         # updates to the latest native release
```

**Do not use upstream's containerized installer script to update.** Upstream scripts drop modified Node wrappers into `~/.openclaw-android` and append broken paths to `~/.bashrc`, quietly breaking your Termux environment and reverting your setup to PRoot.

This launcher **intercepts `update`/`upgrade`** and handles it the native way: fetching and compiling the latest release cleanly against your Termux environment without modifying your global shell profile.

## Layout
```
~/agents/openclaw/
├── launcher.sh   # ← $PREFIX/bin/openclaw symlinks here
└── ...           # native build assets & local runtime
```

## Files
- `install.sh` — one-command installer (sets up native dependencies, compiles bindings, links launcher)
- `launcher.sh` → `$PREFIX/bin/openclaw` — clean environment wrapper & native `update` handler
- `uninstall.sh` — clean removal script

## Uninstall
```bash
bash uninstall.sh
```
or via curl:
```bash
curl -fsSL [https://raw.githubusercontent.com/therealfreddied/openclaw-termux-native/refs/heads/main/uninstall.sh](https://raw.githubusercontent.com/therealfreddied/openclaw-termux-native/refs/heads/main/uninstall.sh) | bash
```

## Part of the native-Termux CLI family

One-command **native, no-proot** installers for AI coding CLIs on Termux — same toolkit, one per agent:

- [claude-code-termux-native](https://github.com/Thr45hx/claude-code-termux-native) — Claude Code
- [antigravity-cli-termux-native](https://github.com/Thr45hx/antigravity-cli-termux-native) — Google Antigravity
- [grok-cli-termux-native](https://github.com/Thr45hx/grok-cli-termux-native) — xAI Grok Build
- [opencode-termux-native](https://github.com/therealfreddied/opencode-termux-native) — OpenCode
- [openclaw-termux-native](https://github.com/therealfreddied/openclaw-termux-native) — OpenClaw
- [copilot-cli-termux-native](https://github.com/Thr45hx/copilot-cli-termux-native) — GitHub Copilot

## Notes

- **AI-assisted:** built and reverse-engineered with AI help — a daily-driver, not a toy. Provided as-is.
- **Tested on:** Android 15 / 16 / 17, aarch64 hardware.
- **Root / no-root:** **No root required** — runs entirely in userland.
- **License:** [MIT](./LICENSE).

---

Unofficial — not affiliated with OpenClaw. Provided as-is, no warranty.
