---
name: holistically-fix
description: Triage review comments and fix accepted issues by addressing the root problem across the connected system, not by whack-a-mole patches. Use when the user says "holistically fix", "loop through reviews and fix", "address review comments", "fix GH review", "read PR comments", "handle these comments", "apply reviewer feedback", or pairs review/comment triage with implementation. Emphasizes in-scope triage, direction-preserving fixes, diligent evidence gathering, connected code/schema/feature tracing, and complete-picture remediation.
---

# Holistically Fix

Use this skill when review comments, PR feedback, GH review threads, pasted critique, QA notes, or issue comments need to be triaged and fixed. The goal is not to satisfy each comment literally. The goal is to understand which comments reveal real problems inside the original user goal, then make the right coherent fix across the connected system.

## Core Rule

Review is advice, not permission to write more code. Preserve the original goal, required behavior, agreed architecture, and behavioral boundary. Step back enough to identify the underlying problem, then fix the pattern across every connected piece that boundary requires. Inspect broadly; edit coherently, and leave unrelated systems alone.

## Workflow

1. Collect the comments.
   - Read every provided comment, review thread, or linked GH review before editing.
   - If comments reference files, lines, commits, screenshots, logs, schemas, tickets, or deployments, inspect those sources directly when available.
   - Preserve enough context to know what each comment was reacting to.

2. Triage each comment.
   - Re-read the original user request, plan, issue, and current diff before accepting anything. Write down the original problem, required behavior, accepted contracts or architecture, and non-goals when they are not already explicit.
   - Start with four questions: Do we need this for the original goal? Is a real current failure or evidenced risk present rather than hypothetical? Is the value worth the added complexity and maintenance cost? Can the root cause be fixed holistically without unnecessary machinery or speculative future-proofing?
   - Accept comments only when every answer supports action: the issue is correct, in scope, aligned with the requested direction, evidenced, and worth its complexity.
   - Reject comments that are stale, wrong, already fixed, subjective, scope creep, or asking for a different product direction.
   - Reject speculative hardening and low-likelihood edge cases unless the original contract requires them or the concrete impact is severe, such as security, data loss, or irreversible corruption.
   - Defer comments only when they are valid but outside the current change, too risky for this pass, or require user/product input.
   - Track the reason for each reject or defer so the final response is accountable.

3. Generalize accepted comments.
   - Translate each accepted comment into the underlying class of problem.
   - Check nearby files, shared helpers, schemas, tests, generated types, API boundaries, UI states, jobs, permissions, migrations, docs, or runtime behavior only to understand whether the scoped fix is coherent.
   - Do not absorb sibling bugs, cleanup, or hardening that existed before this change. Record them separately if useful.
   - Group related comments under one root cause when possible.

4. Inspect connected pieces diligently.
   - Trace callers, consumers, data flow, configs, feature flags, database schemas, migrations, tests, logs, and external integrations that can affect the fix.
   - Use the available evidence sources before editing: code search, tests, project docs, Git history, database access, logs, cloud CLIs, issue trackers, and review metadata.
   - Keep the search proportional to the risk and blast radius.

5. Implement the holistic fix.
   - Fix the root cause, not only the reported symptom.
   - Keep the fix aligned with the existing architecture and the user's requested direction.
   - Once an issue is accepted, choose the correct general solution across every connected piece the original goal requires. Do not force a smaller local patch that leaves the pattern broken.
   - Add files, abstractions, public APIs, dependencies, config, schema, migrations, or behavior surfaces only when the accepted root cause needs them and their value justifies their complexity—not merely because a reviewer proposed them.
   - Avoid broad rewrites unless the accepted comments prove the current shape is wrong.
   - Avoid unrelated cleanup.
   - Add or update tests when they are the right way to prove the full issue is fixed.

6. Verify.
   - Run the smallest meaningful checks that cover the accepted fixes.
   - If a comment came from a specific reproduction, scenario, log, or review thread, verify that case directly when possible.
   - Search again only to confirm the scoped pattern is handled. Verification does not open a new implementation phase.
   - Track diff and changed-file growth as a drift signal, not a target. Map added surfaces to the accepted root cause; remove unrelated growth, but keep justified connected changes.

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
- Do not treat a BLOCKER or MAJOR label as authority. The finding still has to pass the scope, evidence, KISS, and YAGNI gates.
- Do not add code for a plausible but unproven edge case merely because the reviewer can describe it.
- Do not reject a comment because it is inconvenient to inspect.
- Do not change unrelated behavior to make a comment disappear.
- Do not claim a comment is fixed without checking the connected code path.

## Examples

Reviewer: "This null check is missing here."

Better response: First prove null can reach the changed path and that the original contract requires handling it. If so, inspect the relevant entry points and fix the contract at the right boundary across the affected flow. If not, reject the hypothetical instead of adding a defensive branch.

Reviewer: "This enum value is not handled in this component."

Better response: Prove the value can occur in the requested flow, then check only the connected consumers needed to keep that flow coherent. Record unrelated consumers separately instead of expanding the task.

Reviewer: "This query could leak data across orgs."

Better response: Trace authorization and tenant scoping from route to query to tests. Fix any leak introduced or exposed by the scoped change. Report pre-existing sibling-query risks separately unless the same fix is required to make this path safe.
