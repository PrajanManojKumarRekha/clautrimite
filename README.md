# Clautrimite

Phase-routed orchestration for Claude Code.

[![MIT License](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)
![Claude Code](https://img.shields.io/badge/Claude%20Code-skill-blue)
![Routing](https://img.shields.io/badge/routing-gstack%20%E2%86%92%20GSD%20%E2%86%92%20Superpowers-black)
![Priority](https://img.shields.io/badge/priority-quality%20first-orange)
Clautrimite keeps the right framework in the right phase:

- `gstack` for spec lock
- `GSD` for plan decomposition
- `Superpowers` for execution

The goal is not more process. The goal is better output.

If you already know the pain:

- spec drift
- planning that collapses during execution
- execution that ships fast but incomplete

that is exactly what Clautrimite is trying to fix.

```text
gstack -> spec lock
GSD -> plan decomposition
Superpowers -> execution
```

## Why Clautrimite

Most AI coding workflows fail in one of three ways:

- they start coding before the spec is actually locked
- they create a plan but lose it during execution
- they execute fast but drift on quality, completeness, or constraints

Clautrimite fixes that by routing each phase to the framework that is strongest at that
phase.

## Included Commands

Clautrimite installs three Claude Code skills:

- `clautrimite`
  Auto skill that detects the active phase and enforces routing boundaries.
- `clautrimite-workflow`
  Manual helper command that prints the recommended operating loop.
- `context-saver`
  Manual helper command that appends the current session state into `SESSION_LOG.md`.

## Why This Loop Beats Single-Framework Use

Using one framework for the whole lifecycle creates a tradeoff:

- `gstack` is excellent at specification discipline, but that does not automatically make it the best execution engine
- `GSD` is excellent at decomposing work and preserving plan structure, but that does not mean it should own all implementation
- `Superpowers` is excellent at execution, but execution alone is weaker when the spec and plan are underdefined

Clautrimite wins by refusing that false choice.

It uses:

- `gstack` to reduce ambiguity early
- `GSD` to prevent plan collapse and context drift
- `Superpowers` to finish the actual build

That loop is stronger than any one of the three operating alone, because each framework
only owns the part it is actually best at.

## Core Thesis

Clautrimite is built on one simple belief:

> `gstack` is best at spec and constraint hardening, `GSD` is best at context-stable plan
> decomposition, and `Superpowers` is best at implementation.

That gives Clautrimite this priority order:

1. Code quality and completeness
2. Speed
3. Elegance

## How It Works

### 1. Spec Lock

Use `gstack` to lock:

- requirements
- constraints
- architecture direction
- acceptance criteria

No code writing here.

### 2. Plan Decomposition

Use `GSD` to turn the locked spec into:

- dependency-ordered execution slices
- phase-by-phase planning
- handoff-ready execution context

No code writing here either.

### 3. Execution

Use `Superpowers` to:

- implement
- test
- verify
- finish the scoped phase without reopening planning

## Installation

Clautrimite depends on external Claude Code ecosystems, so installation is partly
automatic and partly manual.

The short version:

### PowerShell

```powershell
New-Item -ItemType Directory -Force "$HOME\.claude\skills-src" | Out-Null
git clone https://github.com/PrajanManojKumarRekha/clautrimite "$HOME\.claude\skills-src\clautrimite"
Set-Location "$HOME\.claude\skills-src\clautrimite"
bash ./setup.sh
```

### bash / zsh

```bash
git clone https://github.com/PrajanManojKumarRekha/clautrimite ~/.claude/skills-src/clautrimite
cd ~/.claude/skills-src/clautrimite
./setup.sh
```

If you want your own install source, fork the repository first and clone your fork instead.

The important caveat:

- `gstack` can be installed by `setup.sh` if missing
- `GSD` can be installed by `setup.sh` if missing
- `Superpowers` still requires a manual Claude Code command in many setups
- `gstack` may require `bun` during its own upstream setup
- on Windows or mixed-shell setups, `setup.sh --check` prints the Claude root it selected

If `setup.sh` stops on Superpowers, open Claude Code and run:

```text
/plugin install superpowers@claude-plugins-official
```

Then run:

```text
/reload-plugins
```

Then rerun:

```powershell
bash ./setup.sh
```

or

```bash
./setup.sh
```

Recommended shell usage:

- Windows: clone in PowerShell, run the installer with `bash ./setup.sh`
- macOS / Linux: run `./setup.sh` normally from bash or zsh

Full setup guide:

- [docs/INSTALL.md](docs/INSTALL.md)

## What Setup Actually Does

`setup.sh`:

- installs `gstack` if missing
- installs `GSD` if missing
- checks whether `Superpowers` already exists
- installs `clautrimite`, `clautrimite-workflow`, and `context-saver` into the Claude Code skills directory

Dependency detection is intentionally more explicit now:

- `setup.sh --check` prints the Claude root it will target
- on Windows, it checks more than one possible `.claude` directory
- `Superpowers` is detected from Claude Code's plugin manifest as well as folder presence

It does **not** pretend to auto-install everything. If an upstream framework still needs
an interactive Claude Code command, the docs tell you that directly.

It also does not hide upstream prerequisites. If `gstack`'s installer requires `bun`, you
must install `bun` in the same shell environment before rerunning setup.

On Windows, the easiest path is usually to install `bun` from PowerShell first, then
return to `bash ./setup.sh`.

Clautrimite itself is installed into the Claude Code skill directory, not into each
project repository. Once installation succeeds, opening Claude Code in any project should
allow Clautrimite to auto-activate there.

## Quick Start

Once the three upstream frameworks are actually available inside Claude Code:

1. open Claude Code in your project
2. let `clautrimite` auto-activate
3. confirm the printed phase line
4. if needed, run `./setup.sh --check` to confirm the correct Claude root and dependencies
5. follow the routed command for the current phase

Important:

- you do **not** install Clautrimite separately inside every project folder
- you install it once into Claude Code's skill directory
- then Claude Code can use it in whichever project you open

Expected first output:

```text
CURRENT PHASE: <PHASE> — next command: <COMMAND>
```

Useful clautrimite-level commands:

- `/clautrimite-workflow` prints the recommended loop and example command order
- `/context-saver` appends the current session state into `SESSION_LOG.md`

Typical first commands by phase:

- `DECISIONS & SPEC` → `/office-hours`
- `PLANNING` → `/gsd-new-project`
- `EXECUTION` → `/gsd-execute-phase N`

## Example Flow

```text
gstack: /office-hours
gstack: /plan-ceo-review
gstack: /plan-eng-review
GSD: /gsd-new-project
GSD: /gsd-discuss-phase 1
GSD: /gsd-plan-phase 1
GSD: /gsd-execute-phase 1
Superpowers: /using-git-worktree
Superpowers: /test-driven-development
Superpowers: /verification-before-completion
GSD: /gsd-verify-work 1
GSD: /gsd-ship 1
```

Full workflow:

- [docs/workflow.md](docs/workflow.md)

## Session Example

```text
User: Build a small authenticated API. Use PostgreSQL only. JWT must come from env.

clautrimite:
CURRENT PHASE: DECISIONS & SPEC — next command: /office-hours

gstack:
- locks PostgreSQL, JWT env-only, bcrypt rounds, and acceptance criteria

clautrimite:
CURRENT PHASE: PLANNING — next command: /gsd-new-project

GSD:
- decomposes the work into schema, auth, routes, tests, and verification slices

clautrimite:
CURRENT PHASE: EXECUTION — next command: /gsd-execute-phase 1

Superpowers:
- writes the scoped files
- adds tests
- verifies the delivered slice before completion
```

## What Clautrimite Enforces

- `gstack` stays in spec and review work
- `GSD` stays in planning and verification handoff work
- `Superpowers` stays in implementation and completion work
- out-of-phase commands get redirected instead of being silently tolerated
- code quality and completeness are treated as more important than raw speed

## Why The Loop Is Good

The Clautrimite loop is useful because it gives the session a stable rhythm:

1. lock the spec
2. decompose the work
3. execute the slice
4. verify and transition cleanly

That rhythm reduces two common AI coding failure modes:

- late-turn drift after a decent start
- execution that moves fast but loses the original constraints

In practice, the loop is valuable because it creates separation of concerns inside one AI
workflow.

## What This Repository Contains

| File | Purpose |
|------|---------|
| [SKILL.md](SKILL.md) | The actual Clautrimite skill behavior |
| [setup.sh](setup.sh) | Installs Clautrimite and checks upstream dependencies |
| [clautrimite-workflow/](clautrimite-workflow) | Manual command that prints the recommended operator flow |
| [context-saver/](context-saver) | Manual command that saves session state into `SESSION_LOG.md` |
| [docs/INSTALL.md](docs/INSTALL.md) | Real installation flow and manual steps |
| [docs/workflow.md](docs/workflow.md) | Routed workflow and phase transitions |
| [CONTRIBUTING.md](CONTRIBUTING.md) | Contribution guide |
| [SECURITY.md](SECURITY.md) | Security reporting guidance |
| [LICENSE](LICENSE) | MIT license |

## Current Limitation

Clautrimite does not own or replace `gstack`, `GSD`, or `Superpowers`.

It orchestrates them.

That means successful setup still depends on the upstream frameworks being installed
correctly and being callable from inside a real Claude Code session.

This repository is intentionally narrow:

- it is a routing layer
- it is not a general-purpose agent framework
- it does not replace the upstream tools it orchestrates

## Publishing Notes

- local Claude Code artifacts are ignored via `.gitignore`
- upstream framework installation remains the responsibility of those projects
- do not commit session-specific secrets, logs, or local Claude settings

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md).

## Credits

Clautrimite is an orchestration layer built around the strengths of upstream Claude Code
framework ecosystems.

In particular, this workflow builds on the practical strengths of:

- `gstack` for specification and constraint hardening
- `GSD` for phase planning and context-stable decomposition
- `Superpowers` for execution and verification

Clautrimite does not replace those projects. It routes them.

## Note On `/context-saver`

`/context-saver` is now installed as a real helper command and documented in
[SKILL.md](SKILL.md), but it has **not** been end-to-end benchmark-validated in this
repository's public findings yet.

If you find this project useful, please consider giving it a ⭐ Star! It helps the project gain visibility and lets me know that my work is appreciated.
