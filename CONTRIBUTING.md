# Contributing

Thank you for contributing to Clautrimite.

Clautrimite is intentionally narrow in scope. It is a routing layer for Claude Code that
keeps `gstack`, `GSD`, and `Superpowers` in the correct phase. The core product is the
behavior encoded in [SKILL.md](SKILL.md), supported by the installer and documentation.

## Contribution Priorities

Good contributions usually improve one of these areas:

- stronger phase boundaries
- clearer redirect messages
- more reliable installer behavior
- better installation and usage documentation
- execution guidance that improves quality without weakening routing discipline

## What Not To Expand

Please avoid turning Clautrimite into a general-purpose framework platform.

Out of scope by default:

- replacing upstream frameworks
- adding multi-agent orchestration layers
- adding editor-specific integrations for unrelated tools
- broad config surfaces that weaken the one-framework-per-phase rule
- features that make phase ownership ambiguous

## Design Standards

When proposing changes, preserve these principles:

1. Code quality and completeness come before speed.
2. Speed matters, but not at the cost of constraint fidelity.
3. `gstack` owns spec work.
4. `GSD` owns planning and plan-state transitions.
5. `Superpowers` owns execution.
6. Clautrimite should redirect misuse explicitly rather than silently tolerating it.

## Pull Request Guidance

A good pull request should:

- be narrow in scope
- explain the failure mode it fixes
- avoid unrelated wording churn
- preserve the product’s routing identity

If you change routing language, explain:

- what behavior changed
- which failure mode it addresses
- why the new wording is safer or clearer

If you change installer behavior, explain:

- what setup path changed
- whether the manual Superpowers step is still preserved
- what a user should expect after running `setup.sh`

## Testing Changes

Before opening a pull request:

1. Run `./setup.sh --check`.
2. Run `./setup.sh --reinstall`.
3. Confirm `~/.claude/skills/clautrimite/` contains `SKILL.md` and `plugin.json`.
4. Read [SKILL.md](SKILL.md) end to end and verify each phase still blocks the wrong frameworks correctly.
5. Re-read the install docs and confirm they still match the actual setup behavior.

## Documentation Changes

Documentation should stay honest about current limitations.

In particular:

- do not claim one-command setup if Claude Code still requires manual in-session commands
- do not imply Clautrimite replaces upstream projects
- do not overstate automation that the repo does not actually provide

## Security And Privacy

- Do not commit local Claude Code settings, logs, or session-specific artifacts.
- Do not include personal machine paths, tokens, or account-specific values in public docs.
- Follow [SECURITY.md](SECURITY.md) for security-sensitive reports.

## Questions

If a change would materially alter routing ownership or the product scope, discuss it
before implementing it.
