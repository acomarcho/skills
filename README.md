# Personal Agent Skills

This repository contains installable Agent Skills.

## Skills

### logbook

Creates and maintains persistent logbooks for multi-iteration engineering work, investigations, performance tuning, infrastructure changes, and agent handoffs.

### fresh-reviewer-loop

Iterates plans or implementations through fresh reviewer subagents until blockers and major issues converge.

## Local Validation

List skills from this repository:

```bash
npx skills add . --list
```

Install the logbook skill into Codex from this local checkout:

```bash
npx skills add . --skill logbook -a codex -g -y
```

Install the fresh reviewer loop skill into Codex from this local checkout:

```bash
npx skills add . --skill fresh-reviewer-loop -a codex -g -y
```

Replace `codex` with another supported agent target when installing for a different harness.

## Publishing

Push this repository to GitHub, then install it from the published source:

```bash
npx skills add <owner>/<repo> --list
npx skills add <owner>/<repo> --skill logbook -a codex -g -y
npx skills add <owner>/<repo> --skill fresh-reviewer-loop -a codex -g -y
```

Once the repository is installed through the `skills` CLI, skills.sh can discover it through CLI telemetry and create the public listing.

## Portable Agent Preferences

`USER_PREFERENCES.md` contains a compact summary of personal agent preferences distilled from these skills. Use it when setting up another machine or agent harness, for example by copying its contents into `~/.codex/AGENTS.md` or `~/.claude/CLAUDE.md`.
