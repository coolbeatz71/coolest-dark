#!/usr/bin/env bash
#
# Bash language tour.
#
# Covers: strict mode, functions, arrays, associative arrays,
# parameter expansion, traps, here-docs, arithmetic and case.
#
# Usage:
#   ./23-bash.sh <command> [args...]
#
# Exit codes:
#   0  success
#   1  invalid arguments
#   2  not found

set -euo pipefail
IFS=$'\n\t'

readonly SCRIPT_NAME="${0##*/}"
readonly -A SEVERITY=( [debug]=1 [info]=2 [warning]=3 [error]=4 )
declare -a MESSAGES=()

# Prints a formatted log line.
#
# Globals: SEVERITY
# Arguments:
#   $1 - severity name
#   $2 - message text
# Outputs: the line on stdout
log() {
  local level="${1:-info}" message="${2:?message required}"
  local rank="${SEVERITY[$level]:-2}"
  printf '[%s:%d] %s\n' "$level" "$rank" "$message"   # inline comment
}

# Returns the most severe messages.
recent() {
  local take="${1:-5}" count=0
  for msg in "${MESSAGES[@]}"; do
    (( count++ >= take )) && break
    printf '%s\n' "${msg^^}"
  done
}

describe() {
  local count="$1" severity="$2"
  case "$severity" in
    error)            echo "failing" ;;
    warning|info)     (( count > 100 )) && echo "busy" || echo "ok" ;;
    *)                [[ $count -eq 0 ]] && echo "empty" || echo "ok" ;;
  esac
}

cleanup() {
  local code=$?
  [[ $code -ne 0 ]] && echo "${SCRIPT_NAME}: failed with ${code}" >&2
  return $code
}
trap cleanup EXIT
trap 'echo interrupted >&2; exit 130' INT TERM

main() {
  (( $# < 1 )) && { echo "usage: ${SCRIPT_NAME} <command>" >&2; exit 1; }

  MESSAGES+=( "hello" "world" )

  cat <<-EOT
	severity table: ${!SEVERITY[*]}
	entries:        ${#MESSAGES[@]}
	EOT

  log error "something broke"
  recent 2
  describe "${#MESSAGES[@]}" error
}

main "$@"
