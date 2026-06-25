---
name: explore-options
description: Generate diverse solution alternatives for a known problem instead of locking onto the first obvious fix. Use when the user asks to explore options, compare approaches, find alternatives, list several solutions, avoid tunnel vision, think from different angles, or evaluate obvious and radical ways to solve a root cause. Produces a balanced option set with practical, moderate, and more radical architectural choices, plus pros, cons, risks, effort, and when each option makes sense.
---

# Explore Options

Use this skill after the problem, root cause, or likely failure mode is understood enough to compare possible solutions. The goal is to avoid tunnel vision: do not present one answer as the only reasonable path unless the evidence truly supports that.

## Core Rule

Generate a diverse set of viable alternatives before recommending one. Include comfortable options and a small number of bigger or more radical options so the user can apply human judgment across a real decision space.

## Workflow

1. Restate the problem.
   - Name the root cause or current best understanding.
   - State the goal in plain terms.
   - Call out constraints that matter: time, risk, compatibility, data, team ownership, rollout, performance, security, and reversibility.

2. Pick the option count.
   - Use the user-requested count when given.
   - Otherwise provide 5 options by default.
   - Use 8-10 options for broad architecture, product, or strategy questions where the design space is large.

3. Build a diverse option set.
   - Include mostly practical options that fit the current system.
   - Include at least one low-effort minimal option when it is plausible.
   - Include at least one medium-scope option that addresses the root cause more directly.
   - Include one or two larger, more radical, or architectural options when they are technically plausible.
   - Avoid filling the list with tiny variations of the same idea.

4. Analyze each option.
   - Explain the idea in a few sentences.
   - List concrete pros and cons.
   - Estimate effort, risk, reversibility, and blast radius.
   - Say what new complexity it adds.
   - Say when this option is the right choice.
   - Say what would make this option a bad choice.

5. Compare and recommend.
   - Group similar options or point out shared tradeoffs.
   - Identify the safest default when one exists.
   - Identify the best long-term option when different from the safest default.
   - Identify which options should be rejected or deferred.
   - Give the user clear decision criteria, not just a favorite.

## Option Range

Aim for a spread like this unless the user asks otherwise:

- Minimal patch: smallest reasonable change; useful for urgent mitigation or low-risk issues.
- Targeted root-cause fix: addresses the actual source without broad redesign.
- Refactor within current architecture: improves shape while preserving the system boundary.
- Process or data fix: changes workflow, validation, migration, monitoring, or ownership instead of only code.
- Architectural change: changes boundaries, contracts, storage, queues, services, or ownership.
- Radical rethink: removes the problem by changing the product behavior, user flow, invariant, or assumption.

Not every problem needs every category. Do not invent unrealistic options just to fill slots.

## Quality Bar

Good options are distinct. Each should differ in mechanism, scope, risk, or philosophy.

Avoid:

- Repeating the same fix with small naming changes.
- Making every option comfortable and obvious.
- Making every option radical.
- Hiding costs to make an option look better.
- Recommending a big rewrite when a smaller root-cause fix is enough.
- Recommending a small patch when the root problem clearly needs a bigger change.

## Output Format

Use this structure:

```text
Problem
- ...

Decision criteria
- ...

Options
1. Option name
   Idea: ...
   Pros: ...
   Cons: ...
   Effort/risk: ...
   Choose this when: ...

Recommendation
- Safest default: ...
- Best long-term option: ...
- Options to avoid or defer: ...
```

Use a table when it makes comparison easier, but keep enough explanation under each option for the user to judge the tradeoffs.

## Evidence and Honesty

- Base options on the actual problem and context already gathered.
- If context is missing, say what assumptions the options depend on.
- If a radical option needs more discovery, label it as speculative.
- If all reasonable options point to the same answer, still explain why the alternatives are weaker.
- Do not pretend to know cost, risk, or team constraints that were not provided.
