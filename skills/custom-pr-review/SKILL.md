---
name: custom-pr-review
description: Review a pull request or branch diff with a bias toward simple, correct, root-cause fixes. Use when the user asks for a custom PR review, branch review, code review against the default branch, PR critique, or review of a diff before merge. Covers rebasing onto the latest origin default branch, reading PR intent, checking project instructions, tracing data flow, flagging over-complexity, YAGNI fallbacks/casts/checks, duplicate utilities, whack-a-mole fixes, security/performance risks, and whether the change can be explained simply.
---

# Custom PR Review

Review the current branch or pull request as if it is about to be merged. Prioritize real risks: correctness, simplicity, maintainability, security, performance, and whether the change solves the actual problem.

## Setup

1. Identify the comparison base.
   - If the user names a base branch, use it.
   - Otherwise detect the default branch from the remote. Prefer `origin/HEAD`; fall back to common names such as `origin/main`, `origin/master`, or `origin/develop`.
2. Fetch the latest remote refs.
3. Rebase the review branch onto the latest origin default branch unless the user says not to.
   - If rebasing is unsafe because of local uncommitted work, conflicts, protected workflow rules, or missing permissions, stop and explain the blocker.
4. Find the PR context when available.
   - Read the PR title, body, linked issue, review comments, and CI status when tools such as `gh` are available.
   - If there is no PR, infer intent from commits, tests, fixtures, changed files, issue references, and the diff.
   - Lock the original problem, required behavior, accepted contracts or architecture, and non-goals. Review against that behavioral scope rather than an idealized version of the whole system; do not treat the initial file list as the scope.
5. Read project instructions.
   - Search for `AGENTS.md`, `CLAUDE.md`, and nearby package or directory instructions.
   - Treat those rules as review criteria.
6. Inspect the full diff and the changed files in full, not just the hunks.

## Review Priorities

### 1. Simplicity

Ask whether the code is simple enough for what it is trying to do.

Flag:

- Too many branches, nested conditions, modes, or special cases.
- Hard-to-understand function, variable, file, or type names.
- Long function calls with many flags, options, casts, or inline conditionals.
- Deterministic invariants, checks, guards, or assertions that look excessive for the problem.
- Abstractions that make the flow harder to explain than the underlying behavior.

If a change needs a sentence like "if X then Y, but if Z then A, except when B", ask whether that complexity is truly required.

### 2. YAGNI

Look for code added for hypothetical future cases rather than the current problem.

Flag:

- Fallbacks with no known caller or product requirement.
- Casts or type escapes that hide an unclear model.
- Config knobs, feature flags, generic helpers, extension points, or exports that are not used now.
- Defensive branches that mask bad input instead of fixing the source of that input.
- Optional behavior not described by the PR, tests, fixtures, issue, or product need.

Ask: "Do we actually need this for the problem being solved now?"

### 3. Existing Utilities and Duplication

When the PR adds a helper, formatter, parser, mapper, validator, hook, component, query wrapper, or utility, search the codebase for similar existing code before accepting it.

Examples:

- If the PR adds `formatDate`, search for date formatting helpers and usages.
- If it adds request parsing, search for route middleware or schema parsers.
- If it adds money, enum, status, permission, slug, or URL logic, search for shared versions.

Flag duplicate behavior and suggest reusing or extending existing local patterns when that would make the code simpler.

### 4. Root-Cause Fit

Use the PR description, linked issue, tests, fixtures, review comments, and changed files to understand the original problem.

Judge whether the fix is:

- Actual fix: addresses the root cause and works for the general class of problem.
- Narrow fix: solves only the exact observed case but is acceptable because the scope is truly narrow.
- Whack-a-mole: patches one symptom while likely leaving sibling cases broken.
- Overfit: shaped around a test fixture, reviewer comment, log line, or single failing input.
- Defensive workaround: hides bad state instead of fixing how that state is created.
- Red herring: changes nearby code without solving the stated problem.

Rate actual root-cause fixes higher than defensive fixes. Defensive fixes are acceptable only when they are intentionally at a boundary, paired with source fixes, or required for safety.

### 5. Correctness and Data Flow

Trace the full flow from input to output.

Check:

- Where the data enters.
- How it is validated, normalized, transformed, stored, cached, queued, emitted, and displayed.
- Whether each transformation matches the intended direction and domain model.
- Whether async jobs, webhooks, caches, retries, migrations, generated types, feature flags, and permissions are updated consistently.
- Whether tests cover the meaningful paths, not only the easiest fixture.

Flag algorithms, transformations, and state changes that are too complex, overkill, or disconnected from the real problem.

### 6. Performance and Security

Look for performance and security risks introduced or affected by the diff.

Check:

- Database queries: indexes, filters, tenant scoping, pagination, joins, N+1 behavior, and transaction boundaries.
- Authorization and privacy: org/user scoping, data leaks, access checks, server/client trust boundaries, secrets, logs, and audit trails.
- External calls: retries, timeouts, idempotency, rate limits, error handling, and partial failure.
- Runtime cost: unnecessary loops, large payloads, repeated parsing, caching, memory growth, and expensive work on hot paths.

Ask whether the query is indexed and whether the data access is safe whenever the diff touches persistence or authorization.

### 7. Explainability

Ask whether the change can be explained clearly in a few sentences.

- If the explanation is short and direct, the design is probably understandable.
- If the explanation needs many nested conditions, check whether the code is carrying accidental complexity.
- If the complexity is legitimate, make sure the code structure, names, comments, and tests make that complexity visible and safe.

Prefer suggestions that remove branches, clarify names, collapse unnecessary layers, or move logic to the right boundary.

### 8. Project Instructions

Check whether the PR follows all relevant `AGENTS.md`, `CLAUDE.md`, package instructions, test conventions, architecture rules, and local style requirements.

Flag any violation that affects correctness, maintainability, safety, or expected workflow.

## Output Format

Lead with findings, ordered by severity.

Use this structure:

```text
Findings
- BLOCKER: ...
- MAJOR: ...
- MINOR: ...

Open Questions
- ...

What I Checked
- Base branch and diff command
- PR description / issue / fixtures used for intent
- Project instructions read
- Tests or commands run
```

Every finding must include:

- File path and line number when possible.
- Why it matters.
- The simpler or more correct direction.
- Whether the issue is correctness, simplicity, YAGNI, duplication, performance, security, instruction adherence, or root-cause fit.

If there are no actionable issues, say that clearly and mention residual risk or test gaps.

## Review Discipline

- Before reporting any finding, ask: Do we need this for the original goal? Is there evidence of a concrete current failure or serious harm, rather than a plausible hypothetical? Is its value worth the likely complexity and maintenance cost? Can its root cause be fixed holistically without unnecessary machinery or speculative future-proofing?
- Report a finding only when it passes those gates. Every comment can sound locally sensible; that does not make it useful or in scope.
- Do not turn separate improvements, pre-existing sibling bugs, speculative hardening, or low-likelihood edge cases into findings unless the original contract requires them or the concrete impact is severe, such as security, data loss, or irreversible corruption.
- For accepted findings, recommend the correct general fix across the connected flow. KISS and YAGNI challenge needless complexity; they do not justify a whack-a-mole patch. Treat extra files or lines as a reason to demand a clear root-cause/value explanation, not as a reason to reject a good fix.
- Do not nitpick style unless it hides a real issue.
- Do not ask for abstraction just because code repeats once.
- Do not accept abstraction just because code repeats if the abstraction makes the behavior harder to understand.
- Do not assume the PR description is correct. Verify it against the diff.
- Do not review only changed hunks. Read the surrounding code needed to understand behavior.
- Do not skip utility searches when a PR adds helper-like code.
- Do not confuse defensive programming with solving the actual problem.
