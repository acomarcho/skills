---
name: logbook
description: Creates and maintains logbooks for multi-iteration work — engineering tasks, issue investigations, infrastructure debugging. Use when work spans multiple iterations (prompt engineering, architecture redesigns, performance optimization, prod outage investigation, infrastructure changes), when context compaction would lose critical details like exact numbers or design decisions, or when handing off iterative work between agents. Complementary to other skills — combine with /db, /sentry, /doc-url etc. to investigate and record findings in one place.
---

# Logbook

A logbook is persistent memory for multi-iteration work. Context compaction loses exact numbers, design decisions, and edge case knowledge — the logbook externalizes these to a file that survives compaction. Any agent should be able to read the logbook and continue work without re-discovering what was already learned.

## Creating a Logbook

**File path:** `logbooks/YYMMDD_project_feature.md` (e.g., `logbooks/260307_henner_flat-extraction.md`)

1. Ask the user what problem we're solving and what "done" looks like
2. Explore the codebase — identify key files, test commands, current behavior
3. Establish a feedback loop — every logbook needs a repeatable way to measure progress. Use existing evals/tests if available, create new ones if not, or build a lightweight CLI/script for tasks where formal tests don't fit. Document in Commands section.
4. Create the logbook using the **Template** below, filling in all sections
5. Run the feedback loop and record as **Iteration 0 — Baseline** (use `-r 4` minimum for LLM steps)

## Resuming a Logbook

1. Read the **entire** logbook. Do not skim — every detail matters
2. Summarize to the user: status, last iteration results, suggested next step
3. Continue with **Iteration Discipline**

## Iteration Discipline

Every iteration follows the same cycle:

**Before:** Re-read Principles and recent iterations — don't repeat known mistakes.

**During:** Record every change with enough detail to reproduce — file paths, what changed, why, schema shapes, prompt fragments. Use `changing-llm-prompts` / `running-evals` skills for LLM steps.

**After:** Append an iteration entry and update living sections (Status, Design, Principles).

### Iteration Entry Format

```
### Iteration N — [short title]

**Date:** YYYY-MM-DD

**Hypothesis/Goal:** [what we're trying to achieve or fix]

**Changes:**
- `path/to/file.ts` — [what changed and why, detailed enough to reproduce]

**Test Results:**
| Case | Result | Baseline | Notes |
|------|--------|----------|-------|
| case-id | 4/4 ✅ | 2/4 | fixed by X |

**RCA:** [root cause of failures — WHY, not just what]

**Bugs Found:**
- Bug N — [title]: [description, affected cases, fix or deferral]

**Decision:** [next step — continue, pivot, or done. If stuck: options with pros/cons]
```

### Rules

- **Numbers matter** — record pass rates, expected values, tolerances precisely
- **When stuck, document options** — Context → Options with pros/cons → ask human
- **Logbook getting too long? Direction is probably wrong** — step back and rethink
- **Never delete iteration entries** — they're the audit trail

---

## Template

````markdown
# [Feature Name] — Logbook

## Status
NOT STARTED — baseline pending

## Problem
<!-- What's broken, why it matters, what "done" looks like. -->

## Key Files
- `path/to/file.ts` — [role]

## Commands
```bash
pnpm --filter @agmi/unified test:xxx --skip-ocr "pattern" -r N
pnpm typecheck
```

## Design
<!-- Architecture, approach chosen, alternatives considered. Mark: (CHOSEN), (REJECTED: reason). -->

## Principles
<!-- Numbered laws discovered through iteration. Append only, never delete. -->

## Iteration Log

### Iteration 0 — Baseline

**Date:** YYYY-MM-DD

**Current state:** [what exists today]

**Baseline results:**
| Case | Result | Notes |
|------|--------|-------|
| ... | ... | ... |

**Plan:** [what we'll try first and why]
````
