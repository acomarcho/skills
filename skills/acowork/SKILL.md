---
name: acowork
description: Aco-style engineering workflow for root-cause fixes. Use when the user says "acowork", "work like aco", "aco workflow", asks for a fixture-first implementation, or wants a disciplined code fix that starts from production-shaped cases, learns from failing tests, generalizes the problem, compares alternatives, implements the simplest general solution, runs unslopify-simplify and fresh-reviewer-loop, fixes accepted issues holistically, and records the whole run in a logbook.
---

# Acowork

Work like Aco: start from real cases, prove the failure, understand the general problem, compare fixes, implement the simplest general solution, simplify it, review it independently, and leave a logbook that lets the next agent continue without rediscovery.

This skill is strict. Do all steps unless the user explicitly narrows the task, forbids coding, or a step is impossible. When a step is skipped, record why in the logbook and in the final report.

## Required Companion Skills

- Use `logbook` from the start and keep it updated through every phase.
- Use `diligent` when gathering production cases, tracing code, investigating logs/data, or proving root cause.
- Use `explore-options` when comparing solution alternatives.
- Use `unslopify-simplify` after implementation.
- Use `fresh-reviewer-loop` after simplification and repeat until it converges.
- Use `holistically-fix` for every accepted issue from review or simplification.
- Use `agent-browser` for UI flows when browser behavior matters.

If a companion skill is unavailable, follow the same behavior manually and note the fallback.

## Workflow

### 1. Create The Logbook First

Create or resume a `logbook` before code changes. Record:

- The user ask and what "done" means.
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
2. Fix accepted issues using `holistically-fix`, stepping back to the root pattern instead of patching comments one by one.
3. Run `fresh-reviewer-loop`.
4. Fix accepted reviewer findings using `holistically-fix`.
5. Repeat simplification and fresh review until they converge or remaining items are explicitly non-blocking.

Do not call the work done from CI or one local pass alone. Check review findings, late failures, and known risky paths.

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
