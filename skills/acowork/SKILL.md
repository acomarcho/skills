---
name: acowork
description: Aco-style engineering workflow for root-cause fixes. Use when the user says "acowork", "work like aco", "aco workflow", asks for a fixture-first implementation, or wants a disciplined code fix that starts from production-shaped cases, learns from failing tests, generalizes the problem, compares alternatives, implements the simplest general solution, runs unslopify-simplify and fresh-reviewer-loop, fixes accepted issues holistically, and records the whole run in a logbook.
---

# Acowork

Work like Aco: start from real cases, prove the failure, understand the general problem, compare fixes, implement the simplest general solution, simplify it, review it independently, and leave a logbook that lets the next agent continue without rediscovery.

This skill is strict about method, not breadth. Do all relevant steps unless the user explicitly narrows the task, forbids coding, or a step is impossible. The original user goal and agreed behavioral scope stay fixed throughout the run. Review, simplification, and verification do not by themselves grant permission to add behavior, hardening, refactors, files, or subsystems; an accepted in-scope root cause may justify connected changes when their value is worth the complexity. When a step is skipped, record why in the logbook and in the final report.

## Required Companion Skills

- Use `logbook` from the start and keep it updated through every phase.
- Use `diligent` when gathering production cases, tracing code, investigating logs/data, or proving root cause.
- Use `explore-options` when comparing solution alternatives.
- Use `unslopify-simplify` after implementation.
- Use `fresh-reviewer-loop` after simplification and repeat until it converges.
- Use `holistically-fix` only after a finding passes the original-scope and evidence gates below. A reviewer's label does not make a finding accepted.
- Use `agent-browser` for UI flows when browser behavior matters.

If a companion skill is unavailable, follow the same behavior manually and note the fallback.

## Workflow

### 1. Create The Logbook First

Create or resume a `logbook` before code changes. Record:

- The user ask and what "done" means.
- Original problem, required behavior, accepted contracts or architecture, and explicit non-goals. Treat this behavioral scope as the lock for every later decision; do not confuse it with a fixed file list.
- Ticket links, production examples, IDs, screenshots, logs, payloads, and any known failing cases.
- Commands used to reproduce, test, browse, inspect logs/data, and validate final behavior.
- Every skipped step and why it was not possible.

Keep updating the logbook after each major finding, option comparison, implementation attempt, review pass, and final validation.

### 2. Build Test Fixtures Before Fixing

Start with fixtures, not code changes.

- If the ticket or user information mentions production cases, gather those cases first. Use `diligent` to inspect available production data, logs, payloads, traces, exports, screenshots, issue trackers, or support examples.
- Turn production-shaped cases into repeatable tests, fixtures, eval cases, browser scripts, or replay inputs before changing behavior.
- If production access or data is unavailable, say so and start with synthetic fixtures that match the reported shape as closely as possible.
- Keep fixture data safe: mask secrets and personal data, preserve the behavior-relevant structure, and record what was real vs synthetic.

### 3. Run The Baseline And Let It Fail

For existing behavior, run the fixtures before making the fix.

- Capture the exact failing command, expected result, actual result, logs, stack traces, screenshots, and relevant data changes.
- Treat the failure as evidence. Do not skip straight to the suspected fix.
- If the fixture unexpectedly passes, investigate the mismatch: wrong environment, stale branch, missing flag, incomplete fixture, test not exercising the path, or ticket already fixed.

For new features with no existing behavior, create the smallest meaningful fixture or acceptance check, then move directly to problem generalization.

### 4. Generalize The Problem

Use the failing fixture to learn, then step back.

1. Explain why this fixture fails.
2. Step back once: name the broader class of inputs, states, timing, data, permission, UI, or contract problem it represents.
3. Step back again: ask whether there is an even more general invariant or system boundary being violated.
4. Target the broader problem, not the single fixture. Reject whack-a-mole fixes that only special-case the example unless the product contract truly is that narrow.

Record the specific fixture failure, the first generalization, and the broader problem statement in the logbook.

Generalize the cause, not the product scope. A broader invariant is useful only when it explains the requested failure and can be fixed within the agreed change. If it reveals a separate bug or improvement, record it as follow-up instead of absorbing it into this task.

### 5. Read The Code Until Placement Is Clear

Do not write plans or code until the current system is understood well enough to know where the change belongs.

Trace the connected path:

- Entry points, callers, callees, data models, schema, config, flags, jobs, queues, API contracts, UI flows, error handling, persistence, and tests.
- Existing helpers and sibling flows that already solve similar problems.
- Public contracts vs internal names so the fix does not rename or reshape external behavior accidentally.

State the old path from input to output in plain terms. Include what changes at each step and which facts are proven by code/tests/data vs still assumptions.

### 6. Compare At Least Three Alternatives

Before choosing a fix, produce at least three distinct alternatives.

For each option, include:

- What it changes.
- Pros and cons.
- Complexity added.
- Simplicity or maintenance cost.
- Generality: whether it fixes the broader problem or only the fixture.
- Regression risk and blast radius.
- Test plan.

If alternatives are cheap to try, implement or prototype all of them enough to compare real behavior. Rank them by test results, simplicity, generality, and risk.

If alternatives are not cheap, choose the sane default: the simplest option that solves the generalized problem without whack-a-mole branches.

### 7. Implement Through Passing Tests

Implement the chosen option, or multiple cheap options if comparison is useful.

- Keep the diff small and intentional.
- Prefer existing local patterns over new abstractions.
- Search before adding helpers, parser utilities, dependencies, fields, metadata, casts, or defensive branches.
- Code until the fixture tests pass and the surrounding regression tests still pass.
- If tests need long-running services, run them in `tmux` sessions or panes with clear names so agents and humans can monitor them.
- If UI behavior matters, use `agent-browser` or an equivalent browser workflow to prove the real path.

When multiple alternatives were tried, keep only the winning approach unless the user asks to preserve comparison artifacts.

### 8. Simplify And Review Until Clean

After implementation passes tests:

1. Run `unslopify-simplify`.
2. Re-read the scope lock. For each simplification or review finding, ask in this order:
   - Do we need this to satisfy the original goal?
   - Is there evidence of a real current failure, or is this hypothetical?
   - Is the behavior or safety value worth the added complexity and maintenance cost?
   - Can the root cause be fixed holistically without unnecessary machinery or speculative future-proofing?
3. Reject or defer findings that fail any gate. A plausible review comment is not permission to write more code.
4. Fix accepted issues using `holistically-fix`. Once a finding passes the gates, solve the root pattern across the connected pieces required by the original goal, even when that justified fix is not the smallest patch.
5. Run `fresh-reviewer-loop` and keep looping through fresh reviews until it converges.
6. Apply the same scope, evidence, value, KISS, and YAGNI gates in every round. KISS and YAGNI reject unnecessary complexity; they do not justify a local patch that leaves the root cause broken. Repeated review is welcome; repeated review does not broaden the behavioral goal.
7. Track changed files and diff size as drift signals, not targets. When the diff grows, map each added surface to the accepted root cause and its value. Remove unrelated growth, but keep connected changes that the holistic fix genuinely needs.

Do not write more code merely to make a reviewer quiet or cover a low-likelihood scenario. Code and complexity are justified when an accepted, in-scope issue needs them for a correct general fix. Rare cases justify code only when the original contract requires them or their concrete impact is severe, such as security, data loss, or irreversible corruption. Verification is proof of the scoped change, not a search for more work.

### 9. Re-run The Same Validation

Run the same tests from the implementation phase again after simplification and review fixes.

At minimum, rerun:

- The production-shaped or synthetic fixtures from the beginning.
- The focused regression tests around the changed path.
- Browser checks for UI changes.
- Any typecheck/build/lint command expected by the repo for touched code.

Record exact commands and results in the logbook.

### 10. Final Report

Report in plain English:

- Problem solved and generalized root cause.
- Fixture source: production-derived, synthetic, or unavailable.
- Old behavior vs new behavior.
- Alternatives considered and why the chosen option won.
- Tests and checks run, with results.
- Simplification/review loop status and any remaining risk.
- Logbook path.
