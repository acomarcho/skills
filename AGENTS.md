# Repository Guidelines

## Project Structure & Module Organization

This repository publishes installable Agent Skills for `skills.sh`.

- `skills/<skill-name>/SKILL.md` is the required source for each skill.
- `skills/<skill-name>/agents/openai.yaml` holds optional OpenAI/Codex UI metadata.
- `skills.sh.json` controls grouping and display on skills.sh.
- `README.md` documents installation and publishing commands.

There is no application source tree, build output, or bundled test suite. Keep generated work logs out of Git; `.gitignore` excludes `logbooks/` and `skills/*/logbooks/`.

## Build, Test, and Development Commands

- `npx skills add . --list` checks local repository discovery and lists all skills.
- `npx skills use . --skill fresh-reviewer-loop` renders a skill prompt bundle without installing it.
- `python3 /home/marcho/.codex/skills/.system/skill-creator/scripts/quick_validate.py skills/<skill-name>` validates a skill folder’s required frontmatter and naming.
- `npx skills add acomarcho/skills --list` verifies the published GitHub repo is installable.

Run validation after every `SKILL.md` or metadata edit.

## Coding Style & Naming Conventions

Write skills in concise Markdown with YAML frontmatter containing `name` and `description`. Skill folder names and `name` values must be lowercase hyphen-case, for example `fresh-reviewer-loop`. Keep descriptions trigger-focused: what the skill does and when an agent should use it.

Use `agents/openai.yaml` only for product-facing metadata. Quote string values, keep `short_description` brief, and ensure `default_prompt` references the skill as `$skill-name`.

## Testing Guidelines

There are no unit tests. Treat validation as the test gate:

1. Run `quick_validate.py` on each edited skill.
2. Run `npx skills add . --list` and confirm the expected skill count.
3. For behavior-sensitive edits, run `npx skills use . --skill <skill-name>` and read the rendered instructions top to bottom.

## Commit & Pull Request Guidelines

History uses conventional commits such as `feat: add logbook skill`, `docs: clarify clean review criteria`, and `refactor: make fresh reviewer loop harness agnostic`.

For PRs, include a short summary, affected skill names, validation commands run, and any intentional scope limits. Link issues when relevant. Screenshots are not needed unless changing rendered marketplace or UI-facing metadata.

## Agent-Specific Instructions

Do not publish private logs, credentials, local machine paths, or generated artifacts. Keep skill instructions harness-neutral unless a skill explicitly targets one agent. Prefer focused edits over broad rewrites.
