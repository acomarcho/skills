# Personal Agent Skills

This repository contains installable Agent Skills.

## Skills

### logbook

Creates and maintains persistent logbooks for multi-iteration engineering work, investigations, performance tuning, infrastructure changes, and agent handoffs.

## Local Validation

List skills from this repository:

```bash
npx skills add . --list
```

Install the logbook skill into Codex from this local checkout:

```bash
npx skills add . --skill logbook -a codex -g -y
```

## Publishing

Push this repository to GitHub, then install it from the published source:

```bash
npx skills add <owner>/<repo> --list
npx skills add <owner>/<repo> --skill logbook -a codex -g -y
```

Once the repository is installed through the `skills` CLI, skills.sh can discover it through CLI telemetry and create the public listing.
