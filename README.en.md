# Agent Environment Knowledge Pack (env-know-how)

> A **seed + self-learning protocol** for hands-on environment know-how for any AI coding tool. Install once and Codex / Claude Code / DeepSeek Harness automatically load the troubleshooting methodology and cross-machine mechanism facts at session start, and sediment the pitfalls you hit on this machine into a **local dynamic layer** that grows to fit your machine.
> Repo: https://github.com/kedeup/env-know-how (Public)
> 中文版见 [README.md](README.md)

## What it is

This pack does not pretend to be a "universal fact library" — we do not know or guess what versions or encodings another machine has. It has two layers:

- **Static layer (this repo)**: cross-tool / cross-platform troubleshooting methodology and a maintenance protocol, plus a few **cross-machine mechanism facts** (e.g., PowerShell 5.1 vs 7+ behavior differences, shell array indexing, command length limits), each tagged `[mechanism]` / `[verified]` / `[observed]`;
- **Local dynamic layer (created at install, not in the repo)**: `~/.<tool>/skills/local-ops/SKILL.md` — your agent appends problems and fixes actually reproduced on this machine, following the protocol (tagged `[observed]` by default; promoted to `[verified]` after ≥2 replications plus your confirmation).

**Result**: the pack grows into a different shape on every machine — your GBK mojibake and their pwsh 7 differences each live only in their own dynamic layer, without polluting each other.

## Support matrix

| Agent | User-level skill location | Status |
|---|---|---|
| Codex (CLI) | `~/.agents/skills/` (Codex personal skill shared root) + `~/.codex/AGENTS.md` pointer | ✅ Verified (binary contains `.agents/skills`) |
| DeepSeek Harness | `~/.dsh/skills/` (rank 400, DSH-only) | ✅ Verified (official rank table) |
| Claude Code | `~/.claude/skills/` + `~/.claude/CLAUDE.md` pointer | 🟡 Path matches official convention; in-session loading pending confirmation |
| WorkBuddy (Tencent) | No local file-based skill directory; installed via the Skill Market / created with "Create Skill" | ✅ Confirmed by official docs ([open.workbuddy.cn/docs/skill](https://open.workbuddy.cn/docs/skill)) |

## Quick start

1. Download/clone this repo: `git clone https://github.com/kedeup/env-know-how.git`
2. Run the installer (Windows: `powershell -ExecutionPolicy Bypass -File install.ps1`; macOS/Linux: `bash install.sh`); the installer also creates the local dynamic layer (local-ops)
3. In any new session, say: "Check my skills/instructions files — the env knowledge pack should be in place."

Or even simpler — **send this sentence to any agent**:
> Please read the INSTALL.md in this repo and install it for me step by step.

WorkBuddy users are different: it has no local skill directory. Open [workbuddy-pack/](workbuddy-pack/README.md) and follow its instructions to create it via the Skill Market or in a conversation.

## Repository layout

```
env-know-how/
├─ README.md / README.en.md    Bilingual docs
├─ INSTALL.md                  Universal install guide (single authoritative entry)
├─ AGENTS.md                   Project-level instructions: effective for any agent in this repo
├─ PUBLISH.md                  GitHub publish & update guide
├─ install.ps1 / install.sh    Probing installer (creates static layer + local dynamic layer)
├─ skills/                     Static layer: methodology / mechanism facts (local directory install)
│  ├─ common-ops/              Methodology + local knowledge maintenance protocol
│  ├─ windows-pwsh-ops/        Windows + PowerShell mechanism facts
│  └─ unix-shell-ops/          macOS/Linux mechanism facts
└─ workbuddy-pack/             WorkBuddy-specific adaptation (Market/conversation creation)

Created at install (not in repo):
  ~/.<tool>/skills/local-ops/SKILL.md   local dynamic layer, grows with your sessions
```

## Content principles

- **Three evidence tags**: `[mechanism]` (system/runtime behavior, holds across machines, verifiable in official docs), `[verified]` (reproduced on this machine, conclusion certain), `[observed]` (seen but not confirmed);
- **Machine-specific facts never enter the repo**: anything true on only one machine goes into that machine's local-ops;
- **Tool differences are more than install paths**: WorkBuddy's SKILL.md frontmatter also requires `display_name`/`description_zh` etc. and has no local skill directory — the installer does not cover it, see workbuddy-pack;
- **Security red line**: no secrets/tokens/internal addresses; the installer only writes to the user directory and needs no admin rights;
- **Maintenance protocol**: append-only, never overwrite old entries, `[observed]` by default, `[verified]` only after ≥2 replications plus user confirmation (see common-ops).

## Maintenance & contribution

- New **mechanism facts** must come from real reproduction with citable evidence; machine-specific experience should be sedimented into local-ops, never submitted to the repo;
- Editing a platform skill body = editing "cross-machine" knowledge: needs ≥2 different machines to reproduce plus user confirmation;
- PRs welcome: methodology goes into common-ops, mechanism facts into the matching platform skill; tool-specific details (e.g. reading an asar in DSH) must not leak into the general layer.

## License

- This repository is released under the [MIT License](LICENSE);
- Keep attribution when using its content; redistribution under modification is allowed — just note it is based on this repo.
