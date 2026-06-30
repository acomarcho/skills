---
name: pr-digest
description: Create a readable plain-English digest of what a pull request or branch diff is doing. Use when the user asks for a PR digest, pull request digest, PR summary, explain this PR, walk me through this PR, help me understand a branch, or summarize a diff without reviewing or critiquing it. Explains why the PR exists, what problem it addresses, what changed in digestible buckets, and a realistic walkthrough of how the change behaves, using minimal jargon with first-use definitions.
---

# PR Digest

Explain what a pull request is doing so the user can understand its direction. This is not a review. Do not lead with critique, nitpicks, or suggested fixes unless the user explicitly asks for them.

## Gather Context

Start by understanding the PR or diff:

1. Read the PR title, body, linked issue, screenshots, review description, and comments when available.
2. Inspect the diff and changed files enough to explain the behavior accurately.
3. If there is no PR, use the branch diff, commit messages, tests, fixtures, changed files, and nearby docs to infer the intent.
4. Identify the user-facing or system-facing problem the PR is trying to solve.
5. Keep uncertainty visible. If the PR description is missing or unclear, say what you inferred from the code.

## Writing Style

Write in day-to-day English.

- Use short, direct sentences.
- Avoid jargon when a normal word works.
- Define technical terms, product names, acronyms, internal service names, and domain-specific words the first time they appear.
- Keep exact code names, file names, API names, database names, and UI labels when they matter, but explain what they mean.
- Assume the reader has not been following the PR.
- Be complete enough that the reader understands the direction without reading the full diff.

## Digest Structure

Use this shape unless the user asks for something else:

```text
What this PR is about
- ...

Why it exists
- ...

What changed
1. Bucket name
   - Plain-English explanation.
   - Important files or areas, if useful.

Walkthrough
- A realistic example of what happens before and after this PR.

What to keep in mind
- Important limits, assumptions, rollout notes, or unclear parts.
```

## Bucketing the Changes

Group the work into digestible buckets: pieces of the feature or fix that belong together.

Good buckets usually follow one of these shapes:

- User flow: what changes from the user's point of view.
- Data flow: how input moves through validation, storage, processing, and output.
- UI/API/backend split: when layers changed separately.
- Setup and migration: config, schema, scripts, or rollout work.
- Tests and safety checks: what coverage or safeguards were added.

Avoid listing every file one by one unless the PR is small or file names are the clearest way to explain it.

## Walkthrough

Include a concrete walkthrough when it helps understanding.

- If the PR description has an example, use it.
- If tests or fixtures show a realistic case, use that.
- If no example exists, synthesize a plausible case from the changed behavior and label it as an example.

The walkthrough should answer:

- What happens before this PR?
- What happens after this PR?
- What does the system or user see at each important step?
- Which changed bucket is responsible for each part of the behavior?

## Boundaries

Stay explanatory.

- Do not turn the digest into a code review.
- Do not rank whether the PR is good or bad unless asked.
- Do not hide important uncertainty.
- Do not over-explain every implementation detail.
- Do not skip important behavior just because it is technical.

If you notice a serious correctness, security, or data-loss concern while preparing the digest, add a small clearly labeled note such as: `Potential concern noticed while reading: ...`. Keep the main digest explanatory.
