---
name: clautrimite-workflow
description: Print the recommended Clautrimite operating loop, when to use each framework, and how to break out of the loop intentionally.
invocation: manual
---

# clautrimite-workflow

Print the recommended Clautrimite operator guide for the current user.

Always include:

1. The core loop:

```text
gstack -> GSD -> Superpowers -> GSD -> gstack
```

2. The default phase mapping:

- `gstack` for `DECISIONS & SPEC`
- `GSD` for `PLANNING`
- `Superpowers` for `EXECUTION`

3. A minimal example command flow:

```text
/office-hours
/plan-eng-review
/gsd-new-project
/gsd-discuss-phase 1
/gsd-plan-phase 1
/gsd-execute-phase 1
/test-driven-development
/verification-before-completion
/gsd-verify-work 1
/gsd-ship 1
/gsd-progress --next
```

4. The breakout rule:

- you may leave the loop deliberately when the task is trivial, blocked, or needs a review decision
- if you break out, say which phase you are moving to and why

5. The session-memory rule:

- use `/context-saver` before ending a meaningful session

Keep the output short and operator-focused. Do not restate the entire skill or repository history.
