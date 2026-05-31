# maven-generate-enforcer-convergence

GitHub Copilot Skill to generate a timestamped Maven enforcer report for the
`dependencyConvergence` and `requireReleaseDeps` rules, for single and
multi-module Maven projects.

## What this skill does ?

This repository contains a **GitHub Copilot Skill**. Copilot agents in VS Code
discover it via `.github/skills/maven-generate-enforcer-convergence/SKILL.md`
and execute its script on demand.

The skill runs the maven-enforcer-plugin rules 

- **`dependencyConvergence`** — flags artifacts pulled in transitively at
  conflicting versions.
- **`requireReleaseDeps`** — flags `-SNAPSHOT` (non-release) dependencies.

and writes its output under:

```
cortexaidevkit/<timestamp>/<outputPath>/
```


Two files are produced in that directory:

- `enforcer-convergence.log` — a filtered, human-readable report listing only
  the enforcer rule violations (grouped by module). If no violations are found,
  it records `No Maven Enforcer rule issues were reported.`
- `enforcer-convergence-raw.log` — the full, unfiltered Maven build output,
  useful for diagnosing failures unrelated to rule violations.

It supports:

- `timestamp` in `yyyymmdd-hhmmss` format (defaults to current time)
- `outputPath` as a relative directory (defaults to `maven-enforcer-convergence`)

For multi-module projects, the rules are evaluated across the full reactor and
all violations are captured in a single report. Violations are reported as
warnings (not fatal) so the complete set of issues is collected.

## Structure

```
maven-generate-enforcer-convergence/
└── .github/
    └── skills/
        └── maven-generate-enforcer-convergence/
            ├── SKILL.md  
            └── scripts/
                └── maven-generate-enforcer-convergence.sh  
```

- `SKILL.md`: skill metadata and execution instructions for Copilot.
- `scripts/maven-generate-enforcer-convergence.sh`: entry point that validates
  inputs and runs the enforcer rules.

## Requirements

- Maven available on `PATH` (`mvn`)
- A `pom.xml` in the current working directory

## Invoking from Copilot

Open Copilot Chat in VS Code and reference the skill name
`maven-generate-enforcer-convergence`, for example:

- "Run generate maven enforcer convergence"
- "Run the enforcer convergence report with timestamp=20260526-153000"
- "Run enforcer convergence report with timestamp=20260526-153000 and outputPath=reports"

## Running scripts locally

From the Maven project root:

```bash
sh ./.github/skills/maven-generate-enforcer-convergence/scripts/maven-generate-enforcer-convergence.sh
```

With explicit inputs:

```bash
sh ./.github/skills/maven-generate-enforcer-convergence/scripts/maven-generate-enforcer-convergence.sh \
  -t 20260526-153000 \
  -o maven-enforcer-convergence
```
