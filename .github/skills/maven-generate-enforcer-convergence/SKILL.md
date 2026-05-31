---
name: maven-generate-enforcer-convergence
description: Generate a timestamped maven enforcer report for the dependencyConvergence and requireReleaseDeps rules in markdown format.
argument-hint: "timestamp=<yyyymmdd-hhmmss>, outputPath=<directory-path>"
authors: ["paul58914080@gmail.com"]
---

# Generate Enforcer Convergence Report

Run the maven-enforcer-plugin rules `dependencyConvergence` and `requireReleaseDeps`. 

## Purpose

The purpose of this skill is to surface dependency hygiene problems in a Maven project:

- **`dependencyConvergence`** — fails when the same artifact is pulled in transitively at conflicting versions, helping you spot and resolve version divergence before it causes runtime issues.
- **`requireReleaseDeps`** — fails when the project depends on `-SNAPSHOT` (non-release) artifacts, which is important before cutting a release.

Both rules are run via the command line without modifying the project `pom.xml`. The skill works for **single-module** projects and **multi-module** projects (the rules are evaluated across the full reactor).

Use this skill when you need a clear view of convergence and release-dependency violations, with an output file path derived from:

- `timestamp`: A string in the format `yyyymmdd-hhmmss` representing the time when the report is generated.
- `outputPath`: A string representing the directory path where the generated report will be saved.

Trigger examples:

- `Run generate-enforcer-convergence with defaults`
- `Run generate enforcer convergence`
- `Run maven enforcer convergence report`
- `Run the enforcer convergence report with timestamp=20260526-153000`
- `Run enforcer convergence report with timestamp=20260526-153000 and outputPath=reports`

## Inputs

Optional inputs include:

- `timestamp`: A string in the format `yyyymmdd-hhmmss` representing the time when the report is generated. If not provided, the current timestamp is used.
- `outputPath`: A relative directory path where the generated report is saved. If not provided, the report is saved in the `maven-enforcer-convergence` directory.

## Execution order

1. Resolve the `timestamp` and `outputPath` inputs, using defaults if necessary.
2. Create the target directory `cortexaidevkit/<timestamp>/<outputPath>` if it does not exist.
3. Run this command in the root directory of the Maven project after resolving the inputs:
    ```
    sh ./.github/skills/maven-generate-enforcer-convergence/scripts/maven-generate-enforcer-convergence.sh -t <timestamp> -o <outputPath>
    ```

## Decision points

- If `timestamp` is invalid, stop and request a valid timestamp in the format `yyyymmdd-hhmmss`.
- If `outputPath` is invalid (absolute or contains `..`), stop and request a valid relative directory path.
- If maven i.e. `mvn` is unavailable, stop and report that Maven is required to run this skill.
- If no `pom.xml` is found in the current directory, stop and report that the skill must run from the Maven project root.
- If the command fails for reasons other than rule violations, stop and report the error code, message, and any relevant details to help diagnose the issue.

## Quality checks

- Verify that the report log file exists at `cortexaidevkit/<timestamp>/<outputPath>/enforcer-convergence.log`.
