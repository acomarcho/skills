---
name: kickoff
description: Start and run one task with the user's standard process and reply shape. Use once per task when the user invokes /kickoff or says "kickoff" with a PR link, a ticket link, or a task. Modes - review (PR digest plus review), ticket (align, plan of 8 lines or fewer, build to an open PR), brief (turn an open-ended ticket into a goal-and-constraints hand-off for a new thread).
---

# Kickoff

One entry point per task. Pick the mode, run its process, and write every reply in this thread in the shape below, including after a compaction.

## Pick the mode

The user may name the mode as the first word. Otherwise:

- `review`: the input is a PR link or number.
- `brief`: the user says brief, explore or hand off, or the ticket has no clear fix yet.
- `ticket`: anything else.

Name the mode you picked in your first line.

## Writing to the user

If `~/personal/skill-data/kickoff/examples.md` exists, read it first. Copy the shape of those answers, not their content.

1. The first sentence is the answer, verdict or status.
2. Each reply stands alone. The user switches threads and will not scroll up. Re-introduce anything you mention in a few words. Never write a bare "phase 3", "#2", "option B", case ID or rule number.
3. Show it with one real case and its numbers, such as "40 runs last week, 6 failed; with the fix, 0 of 40 fail."
4. Describe a change as before and after. Number lists of several items so the user can answer "1/ 2/". Put comparisons and eval results in a table, and open each table with the decision it helps make.
5. Keep replies to about 3 short paragraphs, or a list of 8 lines or fewer. Give more only when asked. Leave out anything the user needn't act on or know, including non-concerns. A short answer still says what, why and what it means.
6. End with what happens next, or the one decision you need.
7. Sub-skill report formats are your working notes. The reply to the user uses this shape.
8. Hold a position that has evidence. Change it only for new evidence, and say what changed your mind.

For "where are we?" or a status report, answer in numbered points: goal, what we built, what we learned, what is still wrong because of our change, and next step.

## Mode: review

1. Run /pr-digest, then /custom-pr-review. Read earlier review comments on the PR too. Stay read-only: no comments, approvals or pushes.
2. Reply in two parts, each 3 short paragraphs. Digest: what the PR does, why, and one example of behaviour before and after. Review: verdict first, then the top issues with an example each.
3. Talk about behaviour. Never mention lines of code or file counts.

## Mode: ticket

1. Read the ticket, its linked docs and any logbook. Reply with your understanding: what is wrong today, what done looks like, and only the decisions the user must make. Then stop.
2. After the user answers, send a numbered plan of at most 8 lines. Include the change, how you'll test it (named tests only, never full suites), the dollar cap for paid runs, and the PR step. Then stop.
3. On "go", run /acowork to completion. If the repo has a cost limit, raise it to the agreed cap yourself. Stop only if you would pass the cap.
4. Open the PR with the repo's PR workflow (/pr when present). Fix review comments with /holistically-fix, plus /autofix-reviews-holistically when available.
5. Reply once, when the PR is open: the link, what changed, what you ran and what is left.

## Mode: brief

1. Research until you can state where we are, where we want to be, and the gap. Compare ways to close it with /explore-options, including rough cost.
2. Write a hand-off prompt for a fresh agent and show it to the user. Open questions go into the brief or ticket, not to the user. The prompt holds:
   - A goal the agent can check, so it knows when it is done.
   - Constraints made only of proven facts and user rules, never guesses. Say what may change, which evals to run, and the dollar cap.
   - The loop: make a change, and a fresh judge agent grades it as simple, general, in scope, free of contradictions, and patched rather than added. Run paid evals only after the judge passes it. Repeat until the goal is met or the cap is reached.
   - Work alone to the end with sane defaults. Break a constraint only with a written reason.
   - Finish with a PR through the repo's workflow and a report with numbers.
3. On "go", start a new thread with that prompt. Use acocrew `start_thread` when available, otherwise a sub-agent.

## Every mode

- After "go", never ask questions or "should I check X next?". Check it yourself and record your defaults in the logbook.
- Keep the goal and agreed constraints at the top of the logbook. Re-read them after a compaction and before each report. Each report says how the work fits them.
- If a design cannot be explained to a non-engineer in 5 sentences, simplify it before reporting.

## Save good answers

When the user says an answer is good, better or clear, or asks to save it, append it to `~/personal/skill-data/kickoff/examples.md`:

```
## <mode>: <what was asked, one line>
<the answer, with names, IDs and customer data removed>
Why it worked: <one line>
```

Keep at most 12 entries and drop the oldest. Never move this file into a git repository.
