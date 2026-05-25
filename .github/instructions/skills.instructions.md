---
description: "Use when creating or updating skill, skill metadata, or repository docs in this project. Enforces skill naming, frontmatter completeness, and generated structure conventions from README.md."
applyTo: ".github/skills/**/*.*"
---

# Copilot Instructions

These instructions apply to the entire repository. Follow them whenever you
author, edit, or extend a **GitHub Copilot Skill** here.

## Repository purpose

This repository hosts one or more GitHub Copilot Skills. Each skill lives
under `.github/skills/<skill-name>/` and is discovered by Copilot agents in
VS Code via its `SKILL.md`.

The currently scaffolded skill is **`maven-generate-enforcer-convergence`** —
GitHub copilot skill to generate maven enforcer convergence issue report

## Skill anatomy

Every skill **must** follow this layout:

```
.github/skills/<skill-name>/
├── SKILL.md                       # Instructions the agent reads
├── scripts/
│   └── <skill-name>.sh            # Executable entry point; emits raw data to stdout
└── templates/
    └── output-template.md         # Required shape of the final rendered output
```

- `SKILL.md` — frontmatter (`name`, `description`, `tools`, `authors`,
  `inputs`) followed by **Purpose**, **Inputs**, **Execution**, **Outputs**,
  and **Post-Execution** sections.
- `scripts/<skill-name>.sh` — the only entry point the agent invokes. Keep
  it deterministic and side-effect free unless the skill explicitly mutates
  state. Emit data to stdout; never to a file the agent did not ask for.
- `templates/output-template.md` — the **strict** shape the final agent
  response must follow. Treat it as a contract.

## Naming convention

Skill names follow **`<context>-<action>-<target>`**, all kebab-case.

| Segment   | Meaning                                   | Examples                                                        |
|-----------|-------------------------------------------|-----------------------------------------------------------------|
| `context` | Area, tech, or stage the skill applies to | `maven`, `ci`, `repo`, `git`, `docs`, `test`, `security`, `api` |
| `action`  | Imperative verb describing what it does   | `fix`, `generate`, `upgrade`, `debug`, `validate`, `scaffold`   |
| `target`  | The concrete artifact or problem          | `readme`, `workflow`, `dependencies`, `release-branch`          |

Rules for `target`:

- Be specific — prefer `legacy-java-code` over `code`, `cve-vulnerability`
  over `issue`.
- Use hyphens to compound — `release-branch`, `template-lint`, `unit-tests`.
- Match natural number — `dependencies` (plural), `readme` (singular).
- One logical target per skill, even if it spans multiple words.

When proposing a new skill, validate the name against this pattern **before**
creating files.

## Authoring rules

When creating or editing a skill:

1. **One skill, one job.** If a skill does two things, split it.
2. **Inputs are explicit.** Every input must be declared in the `SKILL.md`
   frontmatter under `inputs:` with `description` and `required`. Reference
   them by key in the **Inputs** and **Execution** sections.
3. **Outputs are templated.** The final agent response must conform to
   `templates/output-template.md`. Do not invent extra sections or omit
   required ones.
4. **Scripts emit raw data.** Keep `scripts/<skill-name>.sh` focused on
   producing the data the template needs — formatting is the agent's job.
5. **Tools are minimal.** Declare only the tools the skill actually uses in
   the `tools:` frontmatter list. Default set: `codebase`, `search`,
   `editFiles`, `runCommands`.
6. **Idempotency.** Re-running a skill with the same inputs should produce
   the same output (modulo timestamps).
7. **No hidden state.** Do not depend on env vars, network calls, or files
   outside the skill directory unless documented under **Execution**.

## Editing checklist

Before finishing a change, verify:

- [ ] `SKILL.md` frontmatter is valid YAML and lists every input.
- [ ] All `todo:` markers in `SKILL.md` have been resolved or intentionally
      left for the skill author.
- [ ] `scripts/<skill-name>.sh` is executable and runs end-to-end with the
      documented inputs.
- [ ] An example invocation appears in **Execution**.
- [ ] An example output appears under **Outputs** and matches
      `templates/output-template.md`.
- [ ] The skill name still matches `<context>-<action>-<target>`.

## Running locally

```bash
sh ./.github/skills/maven-generate-enforcer-convergence/scripts/maven-generate-enforcer-convergence.sh "Ada"
```

## Invoking from Copilot

Open Copilot Chat in VS Code and reference the skill by name, or use a
trigger phrase that matches its `description` in `SKILL.md`.

## Out of scope

- Do **not** add CI, lint, or build infrastructure unless the skill itself
  is about that.
- Do **not** introduce new top-level directories. Everything belongs under
  `.github/skills/<skill-name>/`.
- Do **not** edit generated files outside the skill directory without an
  explicit request.
