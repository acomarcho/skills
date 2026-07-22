---
name: fresh-reviewer-loop
description: Iterate plans or implementations through fresh reviewer subagents until convergence. Use when the user explicitly asks for a "fresh reviewer loop", "plan iteration loop", "review and critique until clean", "spin up a reviewer to review my changes", or any phrasing where the goal is delegated adversarial review-then-fix cycles either on a plan before code or on a working implementation after code. Each round uses a new subagent so it has no prior-round context or groupthink.
---

# Fresh Reviewer Loop

Run repeated independent review rounds on a plan or implementation. Each round must use a newly started reviewer subagent, not a resumed conversation, so the reviewer has fresh context and can catch issues the main agent missed.

The loop reviews a fixed behavioral target. Before round 1, lock the original problem, required behavior, accepted contracts or architecture, and non-goals from the user's request, plan, issue, and current diff. Do not treat the initial file list as the scope: a holistic fix may need connected files, but a review cannot silently add new product goals.

## Core Rules

- Use the subagent mechanism provided by the current harness. Do not mention or depend on a specific product, API, tool name, or subagent type.
- If the harness supports background subagents and the user wants to keep testing or working, start the reviewer in the background and continue useful local work. Otherwise wait for the reviewer result before proceeding.
- Never continue a previous reviewer subagent for a later round. Start a new reviewer subagent every round.
- Do not leak your intended fix, diagnosis, or expected answer to the reviewer. Pass the artifact, relevant project context, and neutral task instructions.
- Reviewer output is critique, not authority or permission to write more code. A BLOCKER or MAJOR label still has to pass the scope and evidence gates in Applying Findings.
- Address every accepted BLOCKER and MAJOR before starting the next round. MINOR findings are not mandatory work. Record rejected findings and deferred MINOR findings when they matter.
- Stop after convergence or after 5 rounds. If new serious issues keep appearing after 5 rounds, step back and re-evaluate the plan or implementation shape.
- If no subagent mechanism is available, tell the user the independent loop cannot run as designed. Do not present a self-review as an independent reviewer round.

## Mode Selection

| Mode | Artifact | Use When |
|---|---|---|
| Plan | A `.plan-{feature}.md` file | The user wants a plan stress-tested before implementation. |
| Implementation | Working diff plus changed files | The user wants written code reviewed before merge or handoff. |

Both modes use the same loop: start fresh subagent, collect BLOCKER/MAJOR/MINOR findings, evaluate them, update the artifact for accepted findings, verify the result, then repeat until convergence.

## Mode A: Plan Review

Use plan mode when the user is about to authorize non-trivial implementation work and wants the approach checked first. It is most useful for multi-file changes, new architecture, schema or data-flow decisions, migrations, or expensive reversibility mistakes. Skip it for trivial edits.

### Workflow

1. Write or update the plan file at the repository root as `.plan-{feature-slug}.md`. The first line must be `# {Feature Name} - Plan vN`, where `N` is the current review version.
2. Start a fresh reviewer subagent for round `N`. Give it the plan path, project context paths, and the code files needed to verify the plan's claims.
3. Review the findings using the Applying Findings section. Fix every accepted BLOCKER and MAJOR in the plan. Bump the plan version header for each revised version.
4. Add unresolved MINORs or accepted tradeoffs near the end of the plan so later agents can see they were considered.
5. Repeat with a new subagent each round until the convergence signal is returned or the 5-round ceiling is reached.
6. When converged, tell the user: `Plan ready at {path}. Say the word to start implementing.`

### Reviewer Prompt Template

```text
You are a fresh reviewer with no prior context on this conversation. Critique a feature
plan and surface ONLY MAJOR ISSUES: architecture, correctness, safety, completeness.
Skip nits, subjective style, and comment requests. We want real flaws that would derail
real usage or compromise safety.

Read in full:

1. The plan: {absolute path to .plan-{feature}.md}
2. Project context: {absolute paths to relevant project or agent instruction files, if present}
3. Files the plan references for behavior, schemas, data flow, or constraints:
   - {absolute paths}
4. Integration touchpoints, if applicable:
   - {absolute paths}

Context:

- Feature summary: {2-3 sentences on what gets built and why}
- Original scope: {problem, required behavior, accepted contracts or architecture, and explicit non-goals}
- This is round {N}. Previous rounds found and addressed:
  - Round 1: {1-line summary}
  - Round 2: {...}
  (omit on round 1)
- Architecture: {key decision plus key pattern}

Filter every possible finding before reporting it: Is it required for the original scope?
Is there a concrete present failure or serious harm, not only a plausible hypothetical?
Is its value worth the likely complexity and maintenance cost? Can its root cause be fixed
holistically without unnecessary machinery or speculative future-proofing? Do not turn separate improvements,
pre-existing sibling bugs, speculative hardening, or low-likelihood edge cases into findings.

Return findings as:

- BLOCKERS - must fix before code.
- MAJOR - should fix before code; would derail real usage.
- MINOR / NIT / QUESTION - worth noting; will not block.

Cite file paths and line numbers when calling out code-vs-plan mismatches. Be terse.
No filler.
```

## Mode B: Implementation Review

Use implementation mode when the implementation is written and the user wants it stress-tested before merge, release, or handoff.

### Workflow

1. Confirm the diff scope. Prefer the working tree plus branch diff against the main integration branch. Use `origin/main` when present; use the repository's actual main branch if different.
2. If a logbook exists for this feature, append each round there: hypothesis, changes since last round, findings, fixes, tests, and decisions.
3. Start a fresh reviewer subagent for round `N`. Give it the repo path, diff command, relevant instruction files, plan path if one exists, logbook path if one exists, and enough adjacent files to evaluate the change end to end.
4. Review the findings using the Applying Findings section. Apply fixes only for findings that pass every gate. For accepted findings, solve the root cause holistically across the connected pieces required by the original goal.
5. Run the relevant build, type-check, tests, or smoke checks before starting the next round so the next reviewer sees a coherent state.
6. Repeat with a new subagent each round until the convergence signal is returned or the 5-round ceiling is reached.

### Review Criteria

Every implementation reviewer must evaluate these four axes:

1. Holistic - Does the change make sense end to end across all layers it touches? Are any callers, consumers, schemas, migrations, or UI states only partially updated?
2. Complete - Does it implement the intended behavior? Are there TODO branches, unhandled cases, half-wired call sites, missing tests, or missing data migrations?
3. Safe end to end - Does data flow correctly from entry point to persistence and back? Are failure modes handled? Any silent swallowing, stale state, security exposure, or adjacent-flow regression?
4. Clean - Is the code direct, minimal, and maintainable? Apply DRY/YAGNI/KISS against the actual codebase:
   - DRY: Before accepting a new helper, hook, component, type, schema wrapper, formatter, parser, or utility, check whether an equivalent already exists in nearby feature code, shared utility modules, framework helpers, or dependencies already in use. Flag duplicate implementations and copy-pasted logic.
   - YAGNI: Flag exported symbols, public APIs, feature flags, config knobs, generic extension points, new files, or new dependencies that are not consumed by current call sites or required by the requested behavior.
   - KISS: Prefer direct code over indirection. Flag factories, registries, polymorphic layers, async wrappers, dependency injection, state machines, or broad abstractions that only serve one current use case.
   - API surface: Keep functions, types, constants, components, and modules private unless outside consumers need them now. Do not export for hypothetical reuse.
   - Local fit: Follow existing naming, file placement, error handling, test style, and data-flow patterns. Flag unrelated refactors, style churn, or dependency changes bundled into the feature.
   - Comments: Keep comments for non-obvious rationale and constraints. Flag comments that narrate obvious code or encode PR history.

### Reviewer Prompt Template

```text
You are a fresh reviewer with no prior context on this conversation. Review a working
implementation and surface ONLY ACTIONABLE ISSUES along four axes. Skip nits and
subjective style preferences. If your only findings are renames or comment requests,
return no findings; we want real problems.

Read in full:

1. The diff: from {absolute repo path}, run `{diff command}` and `git status`.
   Read every changed file in full, not just the hunks; the diff is a guide, not the
   whole story.
2. Project context: {absolute paths to relevant project or agent instruction files, if present}
3. The plan, if it exists: {absolute path to .plan-{feature}.md}
4. The logbook, if it exists: {absolute path to the logbook file}
5. Adjacent files needed to evaluate callers, consumers, schemas, routes, tests, or UI states:
   - {absolute paths}

Context:

- Feature summary: {2-3 sentences}
- Original scope: {problem, required behavior, accepted contracts or architecture, and explicit non-goals}
- This is round {N}. Previous rounds found and addressed:
  - Round 1: {1-line summary}
  - Round 2: {...}
  (omit on round 1)
- The user is or has been testing manually; we want issues caught before merge.

Filter every possible finding before reporting it: Is it required for the original scope?
Is there evidence of a concrete current failure or serious harm, rather than a plausible
hypothetical? Is its value worth the likely complexity and maintenance cost? Can its root
cause be fixed holistically without unnecessary machinery or speculative future-proofing?
Do not report separate improvements, pre-existing sibling bugs,
speculative hardening, or low-likelihood edge cases unless the original contract requires
them or the impact is severe, such as security, data loss, or irreversible corruption.

Evaluate along four axes:

1. Holistic. End-to-end coherence across all changed layers. Any layer partially updated?
2. Complete. Missing cases, half-wired call sites, missing migrations, missing tests?
3. Safe end to end. Trace data flow from entry point to persistence and back. Failure
   modes handled or explicitly accepted? Silent error swallowing? Adjacent regressions?
4. Clean. Apply DRY/YAGNI/KISS against the actual codebase:
   - DRY: Search/read nearby feature code, shared utility modules, framework helpers,
     and existing dependencies before accepting a new helper, hook, component, type,
     schema wrapper, formatter, parser, or utility. Flag duplicates and copy-paste.
   - YAGNI: Flag exports, public APIs, feature flags, config knobs, generic extension
     points, new files, or new dependencies that no current call site consumes or the
     requested behavior does not require.
   - KISS: Flag factories, registries, polymorphic layers, async wrappers, dependency
     injection, state machines, or broad abstractions that only serve one current use case.
   - API surface: Keep functions, types, constants, components, and modules private unless
     outside consumers need them now. Do not export for hypothetical reuse.
   - Local fit: Follow existing naming, file placement, error handling, test style, and
     data-flow patterns. Flag unrelated refactors, style churn, or dependency changes.
   - Comments: Keep comments for non-obvious rationale and constraints. Flag comments
     that narrate obvious code or encode PR history.

Return findings as:

- BLOCKERS - must fix before merge; breaks the feature or introduces a regression.
- MAJOR - should fix; derails real usage or pollutes the codebase meaningfully.
- MINOR / NIT - only include if it is a real problem, not a preference.

Cite file paths and line numbers for every finding. Be terse. No filler.
```

## Applying Findings

Treat reviewer output as critique to evaluate, not commands to obey blindly.

1. Triage each finding before editing:
   - Re-read the scope lock. Begin with these questions: Do we need this for the original goal? Is a real current failure or evidenced risk present rather than hypothetical? Is its value worth the added complexity and maintenance cost? Can the root cause be fixed holistically without unnecessary machinery or speculative future-proofing?
   - Accept findings only when every answer supports action: the finding is correct, in scope, aligned with the current direction, evidenced, and worth its complexity.
   - Reject findings that are false positives, subjective preferences, scope creep, requests for a different product direction, or fixes that would introduce more complexity than the problem justifies.
   - Reject plausible but unproven edge cases. Rare cases justify code only when the original contract requires them or the concrete impact is severe, such as security, data loss, or irreversible corruption.
   - Defer MINOR findings only when they do not block correctness, safety, or maintainability. Record the reason if the finding is likely to come up again.
2. Fix root causes, not just examples:
   - Step back from the specific failing line or case and identify the underlying pattern.
   - Check other parts of the changed plan, diff, nearby call sites, tests, schemas, or UI states only to understand whether the scoped fix is coherent.
   - Prefer one coherent fix that addresses the class of issue introduced by the work over several whack-a-mole patches.
   - Do not overgeneralize beyond current needs; generalize only to the extent needed by the accepted finding and the existing codebase shape.
3. Keep the fix aligned:
   - Preserve the user's requested direction and the chosen architecture unless the finding proves that direction is flawed.
   - Review does not grant permission to add more code. Passing the triage gates does: use the code and complexity needed for a correct general fix, and avoid unrelated refactors, opportunistic cleanup, speculative hardening, and unjustified abstractions.
   - Use KISS and YAGNI to remove unnecessary complexity, not to force an incomplete local patch. Track changed-file count and diff size as drift signals; when they grow, map every added surface to the accepted root cause and remove only unrelated growth.
   - If a valid finding implies a major direction change or large complexity increase, pause and present the tradeoff instead of silently expanding scope.
4. Verify the fix:
   - Run the tests, type-checks, builds, linters, evals, smoke checks, or manual checks that cover the touched behavior.
   - If a relevant check does not exist or cannot run, state that explicitly and use the closest meaningful verification available.
   - Do not start the next reviewer round until accepted BLOCKER and MAJOR fixes have been applied and the relevant checks have been run or consciously accounted for.

## Convergence Signal

For the round expected to be final, usually round 3 or later, append this to the reviewer prompt:

```text
IMPORTANT: We are trying to determine if {the plan|the implementation} has converged.
If you find no blockers or majors, say so explicitly with the exact sentence:
"No blockers or majors found - {plan is ready for implementation|implementation is ready for merge}."
Do not invent findings to justify another round.
```

Do not accept paraphrases. If the reviewer hedges or returns only unclear caveats, run one more fresh round unless the loop has hit the 5-round ceiling.

## Round Count Heuristic

Substantial work usually converges in 3-5 rounds.

- If plan review keeps finding new blockers, the architecture is probably wrong. Step back, propose a different approach, and restart the loop from plan v1 for the new shape.
- If implementation review keeps finding new blockers, the implementation likely drifted from the plan or the plan missed the user's intent. Stop iterating, re-read the plan and user request, then decide whether to restart or narrow the scope.
- Do not run "just one more round" after round 5. The loop is for convergence on a target, not infinite refinement.

## Reviewer Hygiene

- Always tell the reviewer the round number and what prior rounds caught.
- Always require path and line citations for code-vs-plan or code-vs-spec mismatches.
- Always require explicit BLOCKER/MAJOR/MINOR triage.
- Always tell the reviewer to skip nits.
- Always translate each useful finding into a triage result. For accepted findings, name the coherent in-scope plan edit, root-cause code change, test, or explicit tradeoff; otherwise reject or defer it without changing the artifact.

## What This Skill Is Not

- Not a substitute for main-agent judgment. You still decide whether each finding is correct and how to fix it.
- Not appropriate when the review loop would cost more than the change itself.
- Not a security audit, performance audit, accessibility audit, or domain-specific review. Use specialized skills or reviewers for those.
