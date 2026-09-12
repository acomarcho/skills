---
name: holistically-fix
description: Triage review comments and fix accepted issues at the root across connected code instead of whack-a-mole patches. Use when the user says "holistically fix", "address review comments", "fix GH review", "read PR comments", "handle these comments", or "apply reviewer feedback".
---

# Holistically Fix

Use when review comments, PR threads, pasted critiques, or QA notes need triage and fixes.

## Workflow

1. **Hold the scope.** Re-read the original goal and non-goals first. Reviews do not grant permission to expand scope or add speculative code. Reject comments that are stale, wrong, subjective, already fixed, or asking for a different direction.
2. **Defend first.** For each comment, start by arguing why no action is needed. Only accept when that defense fails.
3. **Triage severity and realness.** Will this actually happen in the current flow, is it an unlikely edge case, or impossible? Accept only correct, in-scope issues worth their complexity. Speculative hardening only counts when the impact is severe, like security, data loss, or corruption.
4. **Generalize, then sweep.** Turn each accepted comment into the underlying class of problem. Then sweep the callsites and code touched by this change for similar cases. This step is mandatory. Group related comments under one root cause.
5. **Fix at the root.** One general fix per root cause. Never patch a single call site and leave the pattern broken.
6. **Test.** Add or update tests that prove the fix and the swept cases, then run them.

## Report

Account for every comment: accepted, rejected with reason, or deferred with reason. List what was verified.
