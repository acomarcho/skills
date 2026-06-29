---
name: unslopify-simplify
description: Review the current diff against the original intent and remove unnecessary complexity. Use when the user asks to unslopify, simplify, trim, minimize, clean up an agent-written change, remove slop, check whether a diff is minimal, or verify that introduced code, branches, fallbacks, parser utilities, general utilities, and tests are actually needed. Starts by finding the relevant diff from PR, uncommitted changes, or branch comparison, then judges every introduced part against the goal, plan, agreed thread intent, and local codebase patterns.
---

# Unslopify Simplify

Use this skill after an implementation exists and the next job is to make the change minimal, intentional, and easy to understand. Treat excess code as suspicious until it proves its value.

## Core Rule

Every line in the diff must earn its place. Keep code only when it directly supports the original intent, fixes a real case, preserves a required behavior, or proves value through existing usage or tests. Remove hypothetical, defensive, duplicated, or over-engineered work.

## Find the Diff First

Always begin by identifying the relevant diff:

1. If there is an open pull request, inspect the PR diff and PR context when available.
2. If the branch has uncommitted changes, inspect the working tree diff and staged diff.
3. If there is no PR and changes are committed, diff the current branch against the default or original base branch.
   - Prefer `origin/HEAD` when available.
   - Fall back to likely bases such as `origin/main`, `origin/master`, or `origin/develop`.
4. If the user names a base branch or commit, use that.
5. Read changed files in full when needed. Do not review only hunks if surrounding code affects whether a change is needed.

## Recover the Intent

Before deleting or rewriting anything, identify the intended scope:

- Current thread goal, plan, accepted design, or explicit user request.
- PR title, PR body, issue, review comments, commit messages, or test fixtures.
- Existing behavior and local patterns around the changed code.

Use that intent as the standard. Do not broaden the work because the diff happens to contain extra ideas.

## What to Challenge

### Fallbacks

Treat fallbacks as a red flag.

Keep a fallback only when:

- It was explicitly requested or agreed upfront.
- Existing callers or production data prove it is needed.
- It protects a real boundary such as untrusted input, external services, migration compatibility, or partial rollout.
- A test covers a real behavior, not an invented hypothetical.

Drop fallback code when it exists only because "maybe this could happen" and no evidence supports it.

### Utility Functions

Treat newly introduced utilities as a strong warning sign.

For every new helper, wrapper, mapper, parser, formatter, validator, hook, component, or constant:

- Search the codebase for an existing shared or local equivalent.
- Check whether it has more than one real caller.
- Ask whether the logic is clearer inline.
- Ask whether the helper hides a simple operation behind a vague name.
- Remove or inline it when it only serves one small call site and does not clarify intent.

Do not keep utility functions that appear out of nowhere without proving they simplify the real change.

### Parser and Normalizer Utilities

Treat `parseNumber`, `parseDate`, `normalizeDate`, `coerceValue`, `safeParse*`, and similar parser utilities as fallback logic unless proven otherwise.

AI agents often overbuild these helpers by assuming input can arrive in many formats when the real contract is narrow, such as one ISO date string, one enum shape, one numeric field, or one API response schema.

Ask:

- What exact input formats are promised by the source?
- Is the parser handling real production input or imaginary formats?
- Would strict validation, a schema, or direct use of the known format be clearer?
- Does the utility hide bad upstream data that should fail loudly?
- Are tests proving real accepted inputs, or only proving invented flexibility?

Prefer direct parsing at the boundary when the input contract is simple. Remove multi-format parsers unless the product, API, migration, or real data proves they are needed.

### Branches and Conditions

Inspect every introduced branch, mode, guard, option, flag, and conditional path.

Ask:

- Is this branch required by the original intent?
- Is it reachable from real inputs?
- Is it covering a real edge case or a hypothetical one?
- Can the input be normalized earlier instead?
- Can the code be collapsed to one clear path?

Remove branches that only support invented states.

### Tests

Tests must earn their place too.

Keep tests that prove real behavior, prevent a meaningful regression, or document an important contract.

Drop or rewrite tests that:

- Only assert implementation details.
- Exist only to justify unnecessary fallback code.
- Duplicate another test without improving coverage.
- Lock in accidental behavior.
- Are shaped around the agent's overbuilt implementation rather than the user goal.

No fallback should survive only because a new test was written for it.

### Casts, Invariants, and Defensive Checks

Challenge casts, assertions, deterministic invariants, extra validation, and defensive checks.

Ask whether they reveal a confused data model. Prefer clarifying the type, boundary, schema, or caller over piling on checks.

Keep checks only when they protect a real boundary or encode an important domain rule.

### Other AI Slop Patterns

Also challenge:

- Broad `try/catch` blocks, swallowed errors, default return values, and redundant logging that make failures quiet.
- Cargo-cult retries, circuit breakers, debounce layers, cache layers, or queues copied into places that do not need them.
- New dependencies for one-line operations or standard-library behavior.
- Generic config objects, option bags, adapters, factories, registries, or classes around a single use case.
- Comments that narrate obvious code, justify bad complexity, or explain history that should live in the commit or PR.
- Dead exports, unused parameters, unused types, and public APIs added for possible future use.
- Deprecated APIs, hallucinated APIs, or patterns that do not match the repo's current conventions.
- Large unrelated file churn, formatting-only edits, renamed symbols, or reorganized modules that are not required by the intent.

## Simplification Pass

For each changed file:

1. List the functions, helpers, branches, tests, and files introduced or materially changed.
2. Mark each as:
   - Keep: directly needed.
   - Inline: useful but too abstract.
   - Remove: not needed.
   - Replace: duplicate of existing code or wrong shape.
   - Needs evidence: cannot judge without checking callers, data, or tests.
3. Search for existing utilities before keeping new ones.
4. Remove speculative fallbacks and their tests together.
5. Collapse branches that only support hypothetical states.
6. Prefer small direct code over clever generalization.
7. Re-run focused checks after simplifying.

## Judgment Standard

The final diff should feel boring and inevitable:

- Minimal files changed.
- Minimal public API surface.
- Minimal new helpers.
- Minimal branches.
- Minimal tests that still prove the intended behavior.
- No speculative fallbacks.
- No unexplained utilities.
- No behavior outside the agreed scope.

If the diff is still hard to explain in a few sentences, keep simplifying or identify the real complexity that must remain.

## Reporting

Report what changed during unslopifying:

- Diff source used: PR, working tree, staged diff, or branch comparison.
- Original intent used as the standard.
- Removed fallbacks, helpers, branches, tests, or files.
- Existing utilities or patterns reused.
- Checks run.
- Any remaining complexity and why it is necessary.

Be direct. If part of the diff is slop, say so plainly and explain the smaller shape it should have.
