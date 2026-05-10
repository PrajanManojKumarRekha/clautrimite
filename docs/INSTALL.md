# Installation

Clautrimite is an orchestration layer for Claude Code. It does not bundle or replace the
three upstream frameworks it routes between.

You are installing two things:

1. the Clautrimite skill
2. the upstream frameworks Clautrimite depends on

## Dependencies

Clautrimite expects these to exist:

- `gstack`
- `GSD`
- `Superpowers`

You should also expect these local tools to be available:

- `git`
- `npx`
- `bash`

And in some environments:

- `bun` because the upstream `gstack` installer may require it

## Important Setup Reality

This repo can automate some of the setup, but not all of it.

Current behavior:

- `setup.sh` can install `gstack` if it is missing
- `setup.sh` can install `GSD` if it is missing
- `Superpowers` may still require a manual install inside Claude Code
- `Superpowers` may be installed with project scope, depending on Claude Code's plugin handling
- `gstack` may fail during its own installer if `bun` is not present
- on Windows, `setup.sh` checks more than one possible `.claude` directory and prints the root it selected
- `Superpowers` detection checks Claude Code's plugin manifest, not just a folder name

Also, some slash-command ecosystems do not fully become available until Claude Code is
actually open in a real project and the relevant install/bootstrap command has been run in
that session.

## Recommended Install Flow

### 1. Clone This Repository

#### PowerShell

```powershell
New-Item -ItemType Directory -Force "$HOME\.claude\skills-src" | Out-Null
git clone https://github.com/PrajanManojKumarRekha/clautrimite "$HOME\.claude\skills-src\clautrimite"
Set-Location "$HOME\.claude\skills-src\clautrimite"
```

#### bash / zsh

```bash
git clone https://github.com/PrajanManojKumarRekha/clautrimite ~/.claude/skills-src/clautrimite
cd ~/.claude/skills-src/clautrimite
```

If you prefer to maintain your own copy, fork the repository and clone your fork instead.

### 2. Run Setup

#### Windows

Use `bash` to run the installer:

```powershell
bash ./setup.sh
```

#### macOS / Linux

```bash
./setup.sh
```

### 3. If Superpowers Is Missing

Open Claude Code and run:

```text
/plugin install superpowers@claude-plugins-official
```

Then rerun:

```powershell
bash ./setup.sh
```

or

```bash
./setup.sh
```

### 4. Open Claude Code In A Real Project

This matters. Some frameworks are only fully usable after Claude Code has loaded the
project context and their slash commands are available in-session.

Important scope note:

- Clautrimite, `gstack`, and `GSD` are intended to be installed once
- `Superpowers` may need to be installed from inside the specific Claude Code project session where you want to use it

Platform note:

- Windows users will usually clone from PowerShell and run the installer through `bash`
- macOS and Linux users can run the installer directly from their normal shell

### 5. Verify Command Availability

Before relying on Clautrimite, verify that these commands are actually callable:

- gstack spec commands such as `/office-hours`
- GSD planning commands such as `/gsd-new-project`
- Superpowers execution commands such as `/verification-before-completion`

## Health Check

You can inspect dependency status without installing:

```bash
./setup.sh --check
```

The health check prints:

- `Claude root: ...` for the directory Clautrimite will target
- `Detected Claude directories:` for every `.claude` directory it found

This matters most on Windows or mixed PowerShell/Git Bash setups, where Claude Code may
use `C:\Users\<you>\.claude` while a bash shell might otherwise default to a separate
Unix-style home directory.

## What Success Looks Like

After setup:

- `SKILL.md` is installed into `~/.claude/skills/clautrimite/`
- Claude Code can auto-activate Clautrimite
- the required upstream commands are actually available in the session

What “installed” means in practice:

- Clautrimite is installed once into the Claude Code skill directory
- `context-saver` and `clautrimite-workflow` are installed alongside it as manual helper commands
- it is **not** installed per project
- when you later open Claude Code inside a project repository, Claude Code should be able to see and auto-activate that installed skill

If you later pull new Clautrimite changes, rerun `setup.sh` once to refresh the installed
skills in Claude Code.

If you are on Windows and mix PowerShell with Git Bash, the installer may discover more
than one `.claude` directory. It now prints the Claude root it is targeting plus every
candidate it found so you can see exactly where it is installing the skill and checking
for frameworks.

## If Installation Still Fails

The most common cause is not Clautrimite itself. It is one of:

- upstream framework not installed
- upstream slash commands not loaded in Claude Code yet
- Superpowers not installed interactively
- installer is checking the wrong Claude root for your environment
- `bun` missing while `gstack` is trying to install

In those cases, install or initialize the upstream framework first, then rerun Clautrimite
setup.

### Common Case: `Superpowers` shows installed in Claude Code but `setup.sh` says missing

This usually means one of two things:

1. Claude Code has not finalized the plugin yet. Run:

```text
/reload-plugins
```

Then reopen Claude Code and rerun:

```bash
./setup.sh --check
```

2. Your machine has more than one `.claude` directory, and the installer was checking the
wrong one before. The current installer prints both the selected Claude root and all
detected candidates so you can verify the path.

If `Superpowers` is installed correctly, `setup.sh --check` will treat the plugin as
present either when it finds a folder or when it finds
`superpowers@claude-plugins-official` in `plugins/installed_plugins.json`.

### Common Case: `gstack` fails with `bun is required`

That error comes from the upstream `gstack` installer, not from Clautrimite.

If you see that message:

1. install `bun`
2. verify with:

```bash
bun --version
```

3. rerun Clautrimite setup:

```bash
./setup.sh
```

#### Recommended Bun install path on Windows

Installing Bun through PowerShell is usually easier than trying to bootstrap it through
the bash installer chain.

Preferred Windows options:

```powershell
winget install Oven-sh.Bun
```

or

```powershell
powershell -c "irm bun.sh/install.ps1 | iex"
```

Then restart your shell and verify:

```powershell
bun --version
```

After that, return to Clautrimite and rerun:

```powershell
Set-Location "$HOME\.claude\skills-src\clautrimite"
bash ./setup.sh
```

#### macOS / Linux

Install `bun` in your normal shell environment, then rerun:

```bash
./setup.sh
```
