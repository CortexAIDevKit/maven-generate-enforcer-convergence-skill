#!/usr/bin/env bash
# Greeting example script for the maven-generate-enforcer-convergence skill.
#
# Usage:
#   sh ./scripts/maven-generate-enforcer-convergence.sh "<name>"
#
# Prints a friendly greeting to stdout. The agent is responsible for
# formatting the final output according to ./template/output-template.md.

set -euo pipefail

name="${1:-world}"
date="$(date +%Y-%m-%d)"

printf 'Hello, %s! Today is %s.\n' "$name" "$date"
