#!/usr/bin/env sh
set -eu

usage() {
  cat <<EOF
Usage: $0 [-o outputPath] [-t timestamp]

  -o outputPath     Sub-directory name for the report (default: maven-enforcer-convergence)
  -t timestamp      Timestamp in yyyymmdd-hhmmss (default: current time)
  -h                Show this help

Runs the maven-enforcer-plugin rules 'dependencyConvergence' and
'requireReleaseDeps' across the project (single-module or multi-module
reactor). Violations are reported, not fatal, so the full report is captured.

Output is written to: cortexaidevkit/<timestamp>/<outputPath>/enforcer-convergence.log
EOF
}

OUTPUT_PATH=""
TIMESTAMP=""

while getopts ":o:t:h" opt; do
  case "$opt" in
    o) OUTPUT_PATH="$OPTARG" ;;
    t) TIMESTAMP="$OPTARG" ;;
    h) usage; exit 0 ;;
    \?) echo "Unknown option: -$OPTARG" >&2; usage; exit 2 ;;
    :)  echo "Option -$OPTARG requires an argument" >&2; usage; exit 2 ;;
  esac
done

OUTPUT_PATH="${OUTPUT_PATH:-maven-enforcer-convergence}"
TIMESTAMP="${TIMESTAMP:-$(date +%Y%m%d-%H%M%S)}"
PLUGIN_VERSION="3.6.3"

if ! printf '%s' "$TIMESTAMP" | grep -Eq '^[0-9]{8}-[0-9]{6}$'; then
  echo "Invalid timestamp '$TIMESTAMP'. Expected format: yyyymmdd-hhmmss" >&2
  exit 1
fi

case "$OUTPUT_PATH" in
  /*|*".."*)
  echo "Invalid outputPath '$OUTPUT_PATH'. Must be a relative path without '..'" >&2
  exit 1
  ;;
esac

if ! command -v mvn >/dev/null 2>&1; then
  echo "Maven ('mvn') is not available on PATH. It is required to run this skill." >&2
  exit 1
fi

if [ ! -f pom.xml ]; then
  echo "No pom.xml found in the current directory." >&2
  exit 1
fi

REPORT_DIR="cortexaidevkit/${TIMESTAMP}/${OUTPUT_PATH}"
FINAL_LOG="${REPORT_DIR}/enforcer-convergence.log"
mkdir -p "$REPORT_DIR"

ENFORCER_GOAL="org.apache.maven.plugins:maven-enforcer-plugin:${PLUGIN_VERSION}:enforce"
RULES="dependencyConvergence,requireReleaseDeps"

is_multi_module() {
  grep -q '<modules>' pom.xml
}

if is_multi_module; then
  echo "Multi-module project detected. Running enforcer across the full reactor..."
else
  echo "Single-module project detected. Running enforcer..."
fi

echo "Rules: ${RULES}"
echo "Plugin: ${ENFORCER_GOAL}"
echo "Report: ${FINAL_LOG}"
echo

# -l $FINAL_LOG          => write the raw Maven output to the report log.
# -Denforcer.fail=false  => violations become warnings so every module is
#                           evaluated and the full set of issues is captured.
# -Denforcer.failFast=false => do not stop at the first failing rule/module.
set +e
mvn -B -l "$FINAL_LOG" "${ENFORCER_GOAL}" \
  -Denforcer.rules="${RULES}" \
  -Denforcer.fail=false \
  -Denforcer.failFast=false
MVN_STATUS=$?
set -e

echo
if [ "$MVN_STATUS" -ne 0 ]; then
  echo "Maven exited with status ${MVN_STATUS}. See ${FINAL_LOG} for details." >&2
fi

echo "Enforcer convergence report written to: ${FINAL_LOG}"
