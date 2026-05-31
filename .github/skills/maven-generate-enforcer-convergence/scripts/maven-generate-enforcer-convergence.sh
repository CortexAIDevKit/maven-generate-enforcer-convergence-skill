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
RAW_LOG="${REPORT_DIR}/enforcer-convergence-raw.log"
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

# Raw Maven output is captured to RAW_LOG and then filtered into FINAL_LOG.
# -Denforcer.fail=false  => violations become warnings so every module is
#                           evaluated and the full set of issues is captured.
# -Denforcer.failFast=false => do not stop at the first failing rule/module.
set +e
mvn -B "${ENFORCER_GOAL}" \
  -Denforcer.rules="${RULES}" \
  -Denforcer.fail=false \
  -Denforcer.failFast=false > "$RAW_LOG" 2>&1
MVN_STATUS=$?
set -e

awk '
  /^\[INFO\] --- maven-enforcer-plugin:.* @ .* ---$/ {
    module_line = $0
    sub(/^.* @ /, "", module_line)
    sub(/ ---$/, "", module_line)
    next
  }
  /^\[WARNING\] Rule [0-9]+:/ {
    if (!printed_header) {
      print "Maven Enforcer issues"
      print "====================="
      print ""
      printed_header = 1
    }
    if (module_line != "") {
      print "Module: " module_line
    }
    print $0
    capture = 1
    found = 1
    next
  }
  capture {
    if ($0 ~ /^\[(INFO|WARNING|ERROR|DEBUG|TRACE)\]/) {
      print ""
      capture = 0
      if ($0 ~ /^\[WARNING\] Rule [0-9]+:/) {
        if (module_line != "") {
          print "Module: " module_line
        }
        print $0
        capture = 1
      }
      next
    }
    print
    next
  }
  END {
    if (!found) {
      print "No Maven Enforcer rule issues were reported."
    }
  }
' "$RAW_LOG" > "$FINAL_LOG"

echo
if [ "$MVN_STATUS" -ne 0 ]; then
  echo "Maven exited with status ${MVN_STATUS}. See ${RAW_LOG} for details." >&2
fi

echo "Enforcer convergence report written to: ${FINAL_LOG}"
echo "Raw Maven log written to: ${RAW_LOG}"
