---
name: clautrimite
description: Routes gstack, GSD, and Superpowers to their correct phases in Claude Code. Activates automatically, enforces strict phase boundaries, and suppresses out-of-phase execution.
invocation: auto
---

# clautrimite

Core priority order:

1. Code quality and completeness
2. Speed
3. Elegance

## On activation

1. Determine the active phase before doing any framework-specific work.
2. If the user has already named the phase, use it.
3. If `SESSION_LOG.md` exists in the project root, read the last 10 entries, print `Resuming from last session:` followed by those entries, and use the framework/PHASE on the most recent entry as the active phase. Do not ask the user.
4. Only if both 2 and 3 fail to resolve a phase, ask: `Which phase are we in: DECISIONS & SPEC, PLANNING, or EXECUTION?`
5. Once known, print exactly:

`CURRENT PHASE: <PHASE> — next command: <COMMAND>`

Use this next-command mapping:

| Phase | Next command |
| --- | --- |
| DECISIONS & SPEC | `/office-hours` |
| PLANNING | `/gsd-new-project` |
| EXECUTION | `/gsd-execute-phase N` |

Do not skip phase detection. If phase is unknown, ask. Do not infer from vague intent when a direct question is needed.

Available clautrimite-level commands:

- `/clautrimite-workflow` to print the recommended operating loop
- `/context-saver` to persist session state into `SESSION_LOG.md`

## PHASE: DECISIONS & SPEC

Use ONLY gstack commands in this phase:

- `/office-hours`
- `/plan-ceo-review`
- `/plan-eng-review`
- `/review`
- `/qa`
- `/ship`

Rules:

- Hard stop: no GSD commands.
- Hard stop: no code writing.
- Hard stop: no execution planning disguised as implementation advice.
- Stay focused on requirements, constraints, tradeoffs, architecture, QA checkpoints, and ship decisions.
- If any Superpowers skill attempts to auto-activate (brainstorming, writing-plan, test-driven-development), dismiss it and say: `Superpowers is for EXECUTION phase. We are in DECISIONS & SPEC.`

Outputs expected from this phase:

- clarified requirements
- locked constraints
- approved product direction
- approved engineering direction
- review and QA decisions when returning here after execution

## PHASE: PLANNING

Use ONLY GSD commands in this phase:

- `/gsd-new-project` once at project start
- `/gsd-discuss-phase N`
- `/gsd-plan-phase N`
- `/gsd-verify-work N`
- `/gsd-ship N`
- `/gsd-progress --next`
- `/gsd-complete-milestone`
- `/gsd-new-milestone`

Rules:

- Hard stop: no gstack commands.
- Hard stop: no code writing.
- Hard stop: no implementation execution.
- NEVER use these commands. They do not exist: `/gsd-next`, `/gsd-auto`, `/gsd-status`, `/gsd-cleanup`, `/gsd-discuss`.
- Use this phase to initialize project planning, capture per-phase decisions, create verified plans, verify completed work, ship a verified phase, and manage milestone closeout.
- If any Superpowers skill attempts to auto-activate (brainstorming, writing-plan, test-driven-development), dismiss it and say: `Superpowers is for EXECUTION phase. We are in PLANNING.`

Outputs expected from this phase:

- a project roadmap
- pre-execution phase decisions
- verified phase plans
- manual acceptance results
- a PR handoff for the verified phase
- milestone completion or next-milestone setup

## PHASE: EXECUTION

Superpowers is now ACTIVE. Let all skills auto-activate normally.

Permitted behavior:

- Superpowers skills may auto-activate without suppression.
- `/gsd-status` is permitted as a check.
- `/gsd-execute-phase N` is the execution-phase GSD handoff command.

Rules:

- No gstack commands permitted.
- No GSD planning commands other than `/gsd-status` and `/gsd-execute-phase N`.
- Execute the current scoped phase only.
- Use Superpowers for worktree isolation, TDD, verification, and completion.
- Optimize for quality first, then speed.
- Prefer complete runnable artifacts over partial fragments across many files.
- Do not claim completion unless code, tests, and concise verification evidence are present for the scoped slice.
- Do not reopen planning unless the scoped slice is genuinely blocked.

Expected Superpowers behavior:

- `/using-git-worktree`
- `/test-driven-development`
- `/verification-before-completion`

Expected execution output:

- complete file bodies where possible
- tests for the scoped implementation
- concise statement of what was delivered
- explicit note of remaining gaps if anything is incomplete

## Hard Stops

| If the user tries this | While in this phase | Respond with exactly this redirect |
| --- | --- | --- |
| any gstack command | PLANNING | `That's a DECISIONS & SPEC command. We are in PLANNING. Finish planning with GSD before returning to gstack.` |
| any gstack command | EXECUTION | `That's a DECISIONS & SPEC command. You're in EXECUTION. Finish this phase with /verification-before-completion first.` |
| `/gsd-new-project`, `/gsd-discuss-phase N`, `/gsd-plan-phase N`, `/gsd-verify-work N`, `/gsd-ship N`, `/gsd-progress --next`, `/gsd-complete-milestone`, or `/gsd-new-milestone` | DECISIONS & SPEC | `That's a PLANNING command. We are in DECISIONS & SPEC. Finish the spec with gstack before moving to GSD.` |
| `/gsd-new-project`, `/gsd-discuss-phase N`, `/gsd-plan-phase N`, `/gsd-verify-work N`, `/gsd-ship N`, `/gsd-progress --next`, `/gsd-complete-milestone`, or `/gsd-new-milestone` | EXECUTION | `That's a PLANNING command. You're in EXECUTION. Complete the current implementation phase, then return to GSD.` |
| `/gsd-next`, `/gsd-auto`, `/gsd-status`, `/gsd-cleanup`, or `/gsd-discuss` | PLANNING | `That GSD command does not exist. Use only /gsd-new-project, /gsd-discuss-phase N, /gsd-plan-phase N, /gsd-verify-work N, /gsd-ship N, /gsd-progress --next, /gsd-complete-milestone, or /gsd-new-milestone.` |
| `/gsd-next`, `/gsd-auto`, `/gsd-cleanup`, or `/gsd-discuss` | EXECUTION | `That GSD command does not exist. Stay in EXECUTION and continue with /gsd-execute-phase N or finish with /verification-before-completion.` |
| `/gsd-execute-phase N` | DECISIONS & SPEC | `That's an EXECUTION handoff command. We are in DECISIONS & SPEC. Finish the spec with gstack before starting execution.` |
| `/gsd-execute-phase N` | PLANNING | `That's an EXECUTION handoff command. We are in PLANNING. Finish planning for this phase before starting execution.` |
| `/gsd-status` | DECISIONS & SPEC | `That check is not available in DECISIONS & SPEC. Use gstack until the spec is locked.` |
| any Superpowers skill or command | DECISIONS & SPEC | `Superpowers is for EXECUTION phase. We are in DECISIONS & SPEC.` |
| any Superpowers skill or command | PLANNING | `Superpowers is for EXECUTION phase. We are in PLANNING.` |
| any request to write code | DECISIONS & SPEC | `Code writing is blocked in DECISIONS & SPEC. Use gstack to finish decisions first.` |
| any request to write code | PLANNING | `Code writing is blocked in PLANNING. Finish phase setup in GSD first.` |

## /context-saver

A phase-agnostic command that persists session activity to `SESSION_LOG.md` in the project root so a future session can resume without asking the user which phase is active.

### What it captures

Every decision made or artifact built during the current session, attributed to the framework that produced it. One line per decision/build, in this exact format:

```
[YYYY-MM-DD HH:MM] framework | PHASE | what was decided or built
```

- `framework` is one of: `gstack`, `GSD`, `Superpowers`.
- `PHASE` is one of: `DECISIONS & SPEC`, `PLANNING`, `EXECUTION`.
- The trailing text is a terse description of the decision or built artifact, no trailing period required.

Examples:

```
[2026-05-09 14:32] gstack | DECISIONS & SPEC | Recommended PostgreSQL, JWT via env var, bcrypt rounds=12
[2026-05-09 14:45] GSD | PLANNING | Phase 1 plan approved — auth schema + migrations
[2026-05-09 15:10] Superpowers | EXECUTION | Built POST /auth/register, 3 tests passing
```

### Behavior on `/context-saver`

1. Collect every framework-attributed decision or build from the current session that is not already in `SESSION_LOG.md`.
2. Format each as one line in the format above, using the local timestamp at which the decision/build occurred (or session-end time if not separately tracked).
3. If `SESSION_LOG.md` does not exist in the project root, create it.
4. Append the new lines to `SESSION_LOG.md` in chronological order. Do not rewrite or reorder existing lines. Do not insert headings, blank separators, or commentary — entries only.
5. After append, print a one-line confirmation: `Saved N entries to SESSION_LOG.md.`

### Behavior on next session start

This is the resume path referenced in step 3 of "On activation":

1. If `SESSION_LOG.md` exists in the project root, read the last 10 entries (or all entries if fewer than 10).
2. Print exactly:

   ```
   Resuming from last session:
   <entry 1>
   <entry 2>
   ...
   ```
3. Treat the framework and PHASE on the most recent entry as the active phase. Proceed to the standard `CURRENT PHASE:` print line.
4. If `SESSION_LOG.md` is missing or empty, fall back to asking the user.

### Rules

- `/context-saver` is permitted in all phases. It is not a gstack, GSD, or Superpowers command — it is a clautrimite-level command and is exempt from the per-phase command hard stops.
- Never delete or edit existing entries. The log is append-only.
- Do not invent entries. Only log decisions and builds that actually occurred this session.
- Do not log the act of running `/context-saver` itself.

## /clautrimite-workflow

A clautrimite-level helper command that prints the recommended operating loop and a minimal example of how to move through the phases.

Rules:

- Keep it short.
- Show the default loop.
- Show the recommended commands in order.
- Explain that the user may break out of the loop deliberately when the task is trivial, blocked, or needs a review decision.

## Phase Transition Rules

1. Start in DECISIONS & SPEC when requirements, scope, constraints, architecture, QA expectations, or ship decisions are still open.
2. Move from DECISIONS & SPEC to PLANNING only after gstack has locked the spec.
3. Start PLANNING with `/gsd-new-project` once at project start.
4. For each phase, use `/gsd-discuss-phase N` before `/gsd-plan-phase N`.
5. Move from PLANNING to EXECUTION only after phase `N` has a verified plan.
6. Start EXECUTION with `/gsd-execute-phase N`.
7. During EXECUTION, allow `/gsd-status` only as a check. Do not use deprecated GSD commands in its place.
8. Return from EXECUTION to PLANNING for `/gsd-verify-work N`, `/gsd-ship N`, or `/gsd-progress --next`.
9. Return from EXECUTION to DECISIONS & SPEC when `/review`, `/qa`, or `/ship` decisions are required.
10. End a milestone with `/gsd-complete-milestone`, then use `/gsd-new-milestone` if work continues.
