# maven-generate-enforcer-convergence

GitHub copilot skill to generate maven enforcer convergence issue report

## What this skill does

This is a **GitHub Copilot Skill**. Copilot agents in VS Code discover it via
`.github/skills/maven-generate-enforcer-convergence/SKILL.md` and follow the instructions there
to perform the task on demand.

The bundled example takes a `name` input and prints a dated greeting —
replace the script and output template with your own behavior.

## Structure

```
maven-generate-enforcer-convergence/
└── .github/
    └── skills/
        └── maven-generate-enforcer-convergence/
            ├── SKILL.md                  # Instructions the agent reads
            ├── scripts/
            │   └── maven-generate-enforcer-convergence.sh   # Entry point the skill runs
            └── template/
                └── output-template.md    # Required shape of the final output
```

- **`SKILL.md`** — frontmatter (name, description, tools, authors, inputs)
  plus sections describing purpose, inputs, execution, and expected outputs.
- **`scripts/maven-generate-enforcer-convergence.sh`** — the executable the skill invokes;
  emits raw data to stdout.
- **`template/output-template.md`** — the format the agent must render the
  final response in.

## Running locally

```bash
sh ./.github/skills/maven-generate-enforcer-convergence/scripts/maven-generate-enforcer-convergence.sh "Ada"
```

## Invoking from Copilot

Open Copilot Chat in VS Code and reference the skill by name, or use a
trigger phrase that matches its description.
