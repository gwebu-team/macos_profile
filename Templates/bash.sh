#!/usr/bin/env bash

set -euo pipefail
shopt -s nullglob dotglob

# if [ "$(uname -s)" != "Linux" ]; then echo "This script only works on Linux!" >&2; exit 254; fi
# set -x # debug

# if ! command -v ls &>/dev/null; then ...; fi
# cd "$(dirname "$(readlink -f -- "${BASH_SOURCE[0]}")")" # mc highlight bug "
# IFS= read -rd '' a < <(echo -ne "123\n\n\n456\n\n\n"); echo "$a"

# Source directory even if it ends in new line. "${src%??}" drops the dot that guarded new lines and the last new line.
# src=$(readlink -f -- "${BASH_SOURCE[0]}"; echo .); src="${src%??}"; src=$(dirname "$src"; echo .); src="${src%??}"
src=$(readlink -f -- "${BASH_SOURCE[0]}"; echo .); src=${src%??}; src=$(dirname "$src"; echo .); src=${src%??}
cd "$src"

printf "We are in the %q directory.\n" "$src"

LOCK_FILE='/tmp/global.lock'
if ! (set -o noclobber; : > "$LOCK_FILE") 2>/dev/null; then
    echo "Already running..." 2>&1
    exit 1
fi

function cleanup {
    echo "Cleaning up..."
    trap - EXIT
    rm -f "$LOCK_FILE"
}

trap cleanup EXIT

function banner {
    local f='='; local s="$f$f$f $1 "; local needed=$(( 79 - ${#s} ))
    if [ $needed -gt 0 ]; then s="$s$(printf "%${needed}s" | tr ' ' "$f" )"; fi
    printf "%s\n" "$s" # can start with dashes
}

USAGE="Usage:
   $(basename "$0") SERVER [PORT/443]"

HOST="prefix://${1:?"Error. You must supply a host name.

${USAGE}"}"

PORT="${2:-443}"

banner "HOST=$HOST, PORT=$PORT."

cleanup

banner OK
