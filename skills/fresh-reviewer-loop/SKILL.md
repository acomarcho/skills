---
name: fresh-reviewer-loop
description: Iterate plans or implementations through fresh Codex reviewer subagents until convergence. Use when the user explicitly asks for a "fresh reviewer loop", "plan iteration loop", "review and critique until clean", "spin up a reviewer to review my changes", or any phrasing where the goal is delegated adversarial review-then-fix cycles either (a) on a plan file BEFORE code, or (b) on a working implementation AFTER code is written. Each round spawns a NEW subagent so it has no groupthink with prior rounds.
---

# Fresh Reviewer Loop

The loop works in two modes. Pick the mode that matches the artifact being reviewed.

| Mode | Artifact | Trigger phrasing |
|---|---|---|
| **Plan** | a `.plan-{feature}.md` file | "review the plan", "iterate on the plan", "plan reviewer loop" |
| **Implementation** | working diff + changed files | "review my changes", "review the implementation", "is the impl clean and safe" |

Both modes share the same core mechanics: fresh subagent per round, BLOCKER/MAJOR/MINOR triage, cite paths and lines, explicit convergence signal, hard ceiling at 5 rounds.

Use Codex `spawn_agent` with `agent_type="explorer"` for reviewer rounds. Do not use `send_input` to continue a prior reviewer; fresh context is the point. Use `wait_agent` only when the reviewer result is needed for the next step. If the user says "while I test this, spin up a reviewer loop," spawn the reviewer and continue useful local work instead of blocking immediately.

## Mode A: Plan review (before code)

Use when the user is about to authorize a non-trivial implementation and wants the plan stress-tested first. Reserve for features that touch multiple files, new architecture decisions, or anything where a missed assumption costs hours. Skip for trivial changes.

### Workflow

1. **Write the plan to a file.** Save to `.plan-{feature-slug}.md` at the **repo root** (not a subfolder). First line is a version header: `# {Feature Name} - Plan v1`. The file is the source of truth across rounds.

2. **Spawn a fresh reviewer.** Each round = a new `spawn_agent` call with `agent_type="explorer"`. **Never** use `send_input` to continue a prior reviewer - fresh context is the point.

3. **Update the plan in place.** Bump the version header (`v1` to `v2`, etc.). Address every BLOCKER and MAJOR. Surface unresolved MINORs as known limits near the end of the plan.

4. **Loop until convergence** (see Convergence signal below).

5. **Hand off.** Tell the user: `Plan ready at {path}. Say the word to start implementing.`

### Prompt template

```
You are a fresh reviewer with no prior context on this conversation. Critique a feature
plan and surface ONLY MAJOR ISSUES: architecture, correctness, safety, completeness.
Skip nits, subjective style, and "you should add a comment." We want real flaws that
would derail real usage or compromise safety.

**Read in full:**

1. The plan: {absolute path to .plan-{feature}.md}
2. Project context: {absolute path to CLAUDE.md, AGENTS.md, or equivalent}
3. Verify the plan's claims against the actual code. At minimum read:
   - {list every file the plan references for behavior, schemas, or constraints}
4. Frontend/integration touchpoints (if applicable):
   - {list integration points}

**Context:**

- Feature summary: {2-3 sentences on what gets built and why}
- This is round {N}. Previous rounds found and addressed:
  - Round 1: {1-line summary}
  - Round 2: {...}
  (omit on round 1)
- Architecture: {key decision + key pattern}

**Return findings as:**

- **BLOCKERS** - must fix before code.
- **MAJOR** - should fix before code; would derail real usage.
- **MINOR / NIT / QUESTION** - worth noting; will not block.

Cite file paths and line numbers when calling out code-vs-plan mismatches. Be terse.
No filler.
```

## Mode B: Implementation review (after code)

Use when the implementation is written (possibly still rough) and the user wants it stress-tested before merge. Often runs in the background while the user smoke-tests in the browser.

### Workflow

1. **Confirm the diff scope.** Default in this repo: working tree vs the merge-base with `origin/master` (`git diff $(git merge-base HEAD origin/master)..HEAD` + uncommitted). If the repo uses `origin/main` instead, use that. Confirm with the user if ambiguous.

2. **Logbook integration.** If a logbook for this feature exists (see the `logbook` skill), record each round there: hypothesis, changes since last round, findings, decisions. The logbook survives compaction; the reviewer thread does not.

3. **Spawn a fresh reviewer.** Same rules: new `spawn_agent` call with `agent_type="explorer"` per round, never `send_input` to a prior reviewer.

4. **Apply the fixes.** Address every BLOCKER and MAJOR. Re-run the build / type-check / tests after each round so the next reviewer sees a working state, not a half-applied set of edits.

5. **Loop until convergence.**

### The four implementation criteria

Every implementation-mode reviewer is briefed on the same four axes. Phrase them explicitly in the prompt so the reviewer doesn't drift into stylistic nits:

1. **Holistic** - does the change make sense end-to-end across all the files it touches? Are there layers that received a partial update?
2. **Complete** - does it implement what was intended? Any TODO branches, unhandled cases, half-wired callsites, missing migrations, missing tests for new behavior?
3. **Safe end-to-end** - does the data flow actually work from entry point to persistence and back? Failure modes handled? No silent swallowing? No regressions in adjacent flows?
4. **Clean** - YAGNI (no speculative abstractions, no flags for features not yet asked for), KISS (no clever indirection when a straight call would do), no over-commenting (no explaining what well-named code already says, no "added for issue #123" rot), self-explanatory naming.

### Prompt template

```
You are a fresh reviewer with no prior context on this conversation. Review a working
implementation and surface ONLY ACTIONABLE ISSUES along four axes. Skip nits and
subjective style preferences. If your only findings are "you could rename this" or
"add a comment here," return nothing; we want real problems.

**Read in full:**

1. The diff: run `git diff $(git merge-base HEAD origin/{base_branch})..HEAD` and
   `git status` from {absolute repo path}. Read every changed file in full, not just
   the hunks; the diff is a guide, not the whole story.
2. Project context: {absolute path to CLAUDE.md, AGENTS.md, or equivalent}.
3. The plan (if exists): {absolute path to .plan-{feature}.md}.
4. Logbook (if exists): {absolute path to the logbook file}.
5. Adjacent files the changes touch but the diff doesn't show; re-read enough
   surrounding context to evaluate whether callers and consumers stay consistent.

**Context:**

- Feature summary: {2-3 sentences}
- This is round {N}. Previous rounds found and addressed:
  - Round 1: {1-line summary}
  - Round 2: {...}
  (omit on round 1)
- The user is/has been testing manually; we want issues caught before merge.

**Evaluate along four axes:**

1. **Holistic.** End-to-end coherence across all changed layers. Any layer received a
   partial update? Any leftover dead branches from a refactor?
2. **Complete.** Does it actually implement what was intended? Missing cases, half-
   wired callsites, missing migrations, missing tests for new behavior?
3. **Safe end-to-end.** Trace the data flow from entry point to persistence and back.
   Failure modes handled (or explicitly accepted)? Silent error swallowing? Any
   regressions in adjacent flows the change touched?
4. **Clean.** YAGNI (no speculative abstractions, no flags for unrequested features),
   KISS (no clever indirection where a straight call would do), no over-commenting
   (no narrating what good names already say, no PR-history comments), self-
   explanatory naming.

**Return findings as:**

- **BLOCKERS** - must fix before merge; breaks the feature or introduces a regression.
- **MAJOR** - should fix; derails real usage or pollutes the codebase meaningfully.
- **MINOR / NIT** - only include if it's a real problem, not a preference.

Cite file paths and line numbers for every finding. Be terse. No filler.
```

## Convergence signal (both modes)

For the round you expect to be the final one (typically round 3+), append to the prompt:

```
**IMPORTANT: We are trying to determine if {the plan|the implementation} has
converged. If you find no blockers or majors, say so explicitly with the exact
sentence: "No blockers or majors found - {plan is ready for implementation|
implementation is ready for merge}." Do not invent findings to justify your existence.**
```

Don't accept paraphrases of that sentence. If the reviewer hedges, run one more round.

## Round count heuristic (both modes)

Substantial work converges in **3-5 rounds**. If round count grows past 5:

- **Plan mode**: the plan's architecture is likely wrong, not its details. New blockers each round = wrong shape. Step back, propose a different approach, start the loop over from v1 of the new shape.
- **Implementation mode**: the implementation is fundamentally off-target. New blockers each round = the plan didn't actually capture what the user wanted, or the implementation drifted from the plan. Stop iterating, re-read the plan / re-confirm the user's intent, possibly revert and restart.

Do not "just one more round" past 5. The pattern is iteration toward an existing target, not infinite refinement.

## Reviewer hygiene (both modes)

- Always tell the reviewer the round number and what prior rounds caught. Without this, round N+1 re-flags everything round N already fixed.
- Always require **path + line citations** on code-vs-{plan|spec} mismatches. Without citations, false-positives slip through.
- Always require explicit BLOCKER/MAJOR/MINOR triage. Mixed bullet lists hide what actually matters.
- Always tell the reviewer to skip nits. Unconstrained reviewers find work because finding work is what they were spawned to do.

## What this skill is not

- Not a substitute for thinking. Each round must yield a real artifact update; findings you can't translate into a concrete diff or plan delta are unactionable.
- Not appropriate for one-shot tasks where iteration cost > implementation cost.
- Not a security audit, perf audit, or any specialized review; those are domain skills. This is general engineering review.
