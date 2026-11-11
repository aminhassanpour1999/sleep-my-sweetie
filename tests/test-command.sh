#!/bin/sh
set -eu

ROOT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
COMMAND="$ROOT_DIR/bin/sleep_my_sweetie"

help_output=$(sh "$COMMAND" --help)
printf '%s\n' "$help_output" | grep -F 'Usage:' >/dev/null
printf '%s\n' "$help_output" | grep -F 'Ctrl+C' >/dev/null
printf '%s\n' "$help_output" | grep -F 'goodnight_my_love' >/dev/null
grep -F 'SYSTEMCTL=/usr/bin/systemctl' "$COMMAND" >/dev/null
grep -F 'exec "$SYSTEMCTL" poweroff' "$COMMAND" >/dev/null

printf 'All tests passed. No shutdown was performed.\n'
