---
name: maven-generate-enforcer-convergence
description: GitHub copilot skill to generate maven enforcer convergence issue report
tools: ['editFiles']
authors: ["paul58914080@gmail.com"]
inputs:
  name:
    description: Name of the person to greet
    required: true
---

# maven-generate-enforcer-convergence

## Purpose

[//]: # (todo: Describe the persona of the skill and explain what the skill does.)

A minimal "hello world" style skill. Given a person's name, it renders a
friendly greeting from a template. Use this as a starting point — replace the
greeting logic with your own behavior.

## Inputs

[//]: # (todo: List the expected inputs for the skill. Be specific about the format and content of each input. This helps the agent prepare the necessary information before invoking the skill.). Use the input key in the metadata above to reference these inputs.

- `name` (string, required) — the person to greet (e.g. `"Ada"`).

## Execution

[//]: # (todo: Describe how the skill is executed. Include any necessary steps, conditions, or actions that the skill performs.)

Run the greeting script with the `name` input. It loads
`./template/output-template.md`, substitutes `` and ``, and
prints the result to stdout.

```bash
sh ./scripts/maven-generate-enforcer-convergence.sh "$name"
```

## Outputs

[//]: # (todo: List the expected outputs for the skill. Be specific about the format and content of each output. This helps the agent understand what to expect after the skill is executed.)

The generated output **must strictly follow**:

`./template/output-template.md`

### Example Output

```markdown
# Greeting

Hello, **Ada**!

Welcome to the `maven-generate-enforcer-convergence` skill.

_Generated on 2026-05-17._
```

## Post-Execution

[//]: # (todo: Describe any post-execution steps or actions that need to be taken after the skill has been executed. This could include cleanup tasks, notifications, or further processing of the outputs.)