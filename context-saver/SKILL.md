---
name: context-saver
description: Save the current Clautrimite session into SESSION_LOG.md so the next session can resume from the last known phase.
invocation: manual
---

# context-saver

Use this command when the session has produced real decisions, plans, or implementation work and you want to preserve that state for the next session.

Append entries to `SESSION_LOG.md` in the project root. If the file does not exist, create it.

## Entry format

Write one line per decision or delivered artifact in this exact format:

```text
[YYYY-MM-DD HH:MM] framework | PHASE | what was decided or built
```

Where:

- `framework` is one of `gstack`, `GSD`, `Superpowers`
- `PHASE` is one of `DECISIONS & SPEC`, `PLANNING`, `EXECUTION`
- the final segment is a terse factual summary

## Behavior

1. Review the current session only.
2. Collect decisions and delivered work that actually happened.
3. Do not invent missing events.
4. Do not rewrite, reorder, or delete existing log entries.
5. Append only the new entries in chronological order.
6. After writing, print exactly:

```text
Saved N entries to SESSION_LOG.md.
```

## Rules

- Do not log the act of running `/context-saver`.
- Do not add headings, commentary, separators, or markdown.
- Do not duplicate entries already present at the end of the file.
- Prefer fewer precise entries over noisy summaries.
