---
name: holistically-fix
description: Triage review comments and fix accepted issues by addressing the root problem across the connected system, not by whack-a-mole patches. Use when the user says "holistically fix", "loop through reviews and fix", "address review comments", "fix GH review", "read PR comments", "handle these comments", "apply reviewer feedback", or pairs review/comment triage with implementation. Emphasizes in-scope triage, direction-preserving fixes, diligent evidence gathering, connected code/schema/feature tracing, and complete-picture remediation.
---

# Holistically Fix

Use this skill when review comments, PR feedback, GH review threads, pasted critique, QA notes, or issue comments need to be triaged and fixed. The goal is not to satisfy each comment literally. The goal is to understand which comments reveal real in-scope problems, then fix those problems in the right shape across the connected system.

## Core Rule

Do not patch only the exact line or example mentioned by a reviewer unless the issue is truly local. Step back, identify the underlying problem, find its connected pieces, and fix the pattern once.

## Workflow

1. Collect the comments.
   - Read every provided comment, review thread, or linked GH review before editing.
   - If comments reference files, lines, commits, screenshots, logs, schemas, tickets, or deployments, inspect those sources directly when available.
   - Preserve enough context to know what each comment was reacting to.

2. Triage each comment.
   - Accept comments that are correct, in scope, aligned with the requested direction, and worth fixing.
   - Reject comments that are stale, wrong, already fixed, subjective, scope creep, or asking for a different product direction.
   - Defer comments only when they are valid but outside the current change, too risky for this pass, or require user/product input.
   - Track the reason for each reject or defer so the final response is accountable.

3. Generalize accepted comments.
   - Translate each accepted comment into the underlying class of problem.
   - Ask whether the same issue exists in nearby files, shared helpers, schemas, tests, generated types, API boundaries, UI states, jobs, permissions, migrations, docs, or runtime behavior.
   - Group related comments under one root cause when possible.

4. Inspect connected pieces diligently.
   - Trace callers, consumers, data flow, configs, feature flags, database schemas, migrations, tests, logs, and external integrations that can affect the fix.
   - Use the available evidence sources before editing: code search, tests, project docs, Git history, database access, logs, cloud CLIs, issue trackers, and review metadata.
   - Keep the search proportional to the risk and blast radius.

5. Implement the holistic fix.
   - Fix the root cause, not only the reported symptom.
   - Keep the fix aligned with the existing architecture and the user's requested direction.
   - Avoid broad rewrites unless the accepted comments prove the current shape is wrong.
   - Avoid unrelated cleanup.
   - Add or update tests when they are the right way to prove the full issue is fixed.

6. Verify.
   - Run the smallest meaningful checks that cover the accepted fixes.
   - If a comment came from a specific reproduction, scenario, log, or review thread, verify that case directly when possible.
   - Search again for the same pattern after fixing so sibling cases are not left behind.

7. Report back.
   - Summarize accepted, rejected, and deferred comments.
   - Explain the holistic fix in terms of the root cause and connected pieces changed.
   - List verification commands and results.
   - Be honest about anything not checked or still uncertain.

## Triage Standards

Use these labels internally or in the final answer when useful:

- Accepted: correct, in scope, and fixed.
- Rejected: not correct, not applicable, stale, subjective, or scope creep.
- Deferred: valid but intentionally not handled in this pass.
- Needs user input: valid-looking but requires a product, design, security, or business decision.

Do not silently ignore comments. If there are many comments, group them by root cause or subsystem, but still account for all meaningful ones.

## Anti-Patterns

- Do not make one-off patches for every review bullet when one system-level fix is better.
- Do not satisfy wording literally while leaving the bug pattern intact.
- Do not accept scope creep just because it appears in a review.
- Do not reject a comment because it is inconvenient to inspect.
- Do not change unrelated behavior to make a comment disappear.
- Do not claim a comment is fixed without checking the connected code path.

## Examples

Reviewer: "This null check is missing here."

Better response: Search for all entry points that can pass the value, understand whether the type/schema should allow null, update validation or normalization at the boundary if that is the real issue, and add coverage for the relevant path.

Reviewer: "This enum value is not handled in this component."

Better response: Find all consumers of the enum, check generated types, backend schema, API responses, UI states, tests, and fallback behavior. Fix the shared handling or all affected consumers, not only the mentioned component.

Reviewer: "This query could leak data across orgs."

Better response: Trace authorization and tenant scoping from route to query to database indexes and tests. Fix the access-control pattern and search for sibling queries with the same risk.
