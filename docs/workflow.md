# clautrimite workflow

clautrimite is a Claude Code routing skill. It does not replace gstack, GSD, or
Superpowers. It activates at session start, identifies the current phase, and keeps each
framework in its lane.

Priority order:

1. Code quality and completeness
2. Speed
3. Elegance

## Ralph Loop

```text
gstack (DECISIONS & SPEC)
    ↓
GSD (PLANNING)
    ↓
GSD /gsd-execute-phase N
    ↓
Superpowers (EXECUTION)
    ↓
Superpowers /verification-before-completion
    ↓
GSD /gsd-verify-work N and /gsd-ship N
    ↓
gstack /review and /qa
    ↓
GSD /gsd-progress --next
    ↓
repeat for the next phase
```

## 15-step workflow

1. `DECISIONS & SPEC` — `/office-hours`
   Produces clarified intent, constraints, and requirement discussion.
2. `DECISIONS & SPEC` — `/plan-ceo-review`
   Produces product-level sign-off on what should be built.
3. `DECISIONS & SPEC` — `/plan-eng-review`
   Produces engineering sign-off on architecture and implementation constraints.
4. `PLANNING` — `/gsd-new-project`
   Produces the initial roadmap from requirements and research.
5. `PLANNING` — `/gsd-discuss-phase N`
   Produces phase-specific implementation decisions before planning starts.
6. `PLANNING` — `/gsd-plan-phase N`
   Produces a researched, verified plan for phase `N`.
7. `EXECUTION` — `/using-git-worktree`
   Produces branch or worktree isolation for phase work.
8. `EXECUTION` — `/gsd-execute-phase N`
   Produces execution of the phase plan while Superpowers skills auto-activate for TDD.
9. `EXECUTION` — `/verification-before-completion`
   Produces the Superpowers verification gate for the current phase.
10. `DECISIONS & SPEC` — `/review`
   Produces role-based review feedback on what was built.
11. `DECISIONS & SPEC` — `/qa`
   Produces QA findings and acceptance decisions.
12. `PLANNING` — `/gsd-verify-work N`
   Produces manual acceptance testing results for the completed phase.
13. `PLANNING` — `/gsd-ship N`
   Produces a PR from the verified phase work.
14. `PLANNING` — `/gsd-progress --next`
   Produces the next required step by auto-detecting project state.
15. `DECISIONS & SPEC` then `PLANNING` — `/ship`, then `/gsd-complete-milestone`, then `/gsd-new-milestone` if continuing
   Produces final ship sign-off, milestone archive, release tagging, and optional next-version setup.

## Phase boundaries

- `DECISIONS & SPEC`: gstack only. No GSD commands. No code writing. Superpowers must be suppressed.
- `PLANNING`: GSD only. No gstack commands. No code writing. Superpowers must be suppressed. Do not use deprecated commands such as `/gsd-next`, `/gsd-auto`, `/gsd-status`, `/gsd-cleanup`, or `/gsd-discuss`.
- `EXECUTION`: Superpowers active. `/gsd-execute-phase N` is the execution handoff. `/gsd-status` is allowed only as a check. No gstack commands.

## Execution standard

When clautrimite routes into `EXECUTION`, the expected behavior is:

- finish the scoped slice completely before declaring success
- prefer complete file bodies over partial fragments
- preserve locked constraints over convenience
- emit tests and verification evidence, not just implementation claims
- avoid reopening planning unless the scoped phase is genuinely blocked

## Transition rules

- Move from `DECISIONS & SPEC` to `PLANNING` only after the spec is locked.
- Start planning with `/gsd-new-project`, then use `/gsd-discuss-phase N` and `/gsd-plan-phase N` for each phase.
- Move from `PLANNING` to `EXECUTION` only after phase `N` has a verified plan.
- Start execution with `/gsd-execute-phase N`.
- Move from `EXECUTION` back to `PLANNING` for `/gsd-verify-work N`, `/gsd-ship N`, and `/gsd-progress --next`.
- Move from `EXECUTION` back to `DECISIONS & SPEC` for `/review`, `/qa`, or `/ship`.
