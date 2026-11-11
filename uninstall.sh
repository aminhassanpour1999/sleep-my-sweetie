#!/bin/sh
# Remove only a verified Sleep, My Sweetie installation.
set -eu

PREFIX=${PREFIX:-/usr/local}
MARKER_TEXT='Sleep, My Sweetie managed installation v1'
if [ "$PREFIX" = "/usr/local" ] && [ "$(id -u)" -ne 0 ]; then
    printf 'Please run the uninstaller with sudo:\n  sudo sh ./uninstall.sh\n' >&2
    exit 1
fi
case "$PREFIX" in
    /*) ;;
    *) printf 'Error: PREFIX must be an absolute path: %s\n' "$PREFIX" >&2; exit 1 ;;
esac
while [ "$PREFIX" != "/" ] && [ "${PREFIX%/}" != "$PREFIX" ]; do PREFIX=${PREFIX%/}; done
if [ "$PREFIX" = "/" ]; then
    printf 'Error: refusing to uninstall from filesystem root.\n' >&2
    exit 1
fi

LIB_PARENT="$PREFIX/lib"
LIB_DIR="$LIB_PARENT/sleep-my-sweetie"
INSTALLED_SCRIPT="$LIB_DIR/sleep_my_sweetie"
MARKER="$LIB_DIR/.sleep-my-sweetie-managed"
BIN_DIR="$PREFIX/bin"

if [ -L "$PREFIX" ] || { [ -e "$PREFIX" ] && [ ! -d "$PREFIX" ]; }; then
    printf 'Error: refusing unsafe PREFIX path: %s\n' "$PREFIX" >&2
    exit 1
fi
if [ -L "$LIB_PARENT" ] || { [ -e "$LIB_PARENT" ] && [ ! -d "$LIB_PARENT" ]; }; then
    printf 'Error: refusing unsafe library parent: %s\n' "$LIB_PARENT" >&2
    exit 1
fi
if [ -L "$BIN_DIR" ] || { [ -e "$BIN_DIR" ] && [ ! -d "$BIN_DIR" ]; }; then
    printf 'Error: refusing unsafe binary directory: %s\n' "$BIN_DIR" >&2
    exit 1
fi
if [ -L "$LIB_DIR" ]; then
    printf 'Error: refusing to follow a symbolic link at: %s\n' "$LIB_DIR" >&2
    exit 1
fi
ALIASES='
sleep_my_sweetie
goodnight_my_love
off_you_go
night_night
rest_in_peace
bye_bye_baby
shut_down_sweetheart
time_to_sleep
'

if [ ! -e "$LIB_DIR" ]; then
    printf 'Sleep, My Sweetie is not installed in %s.\n' "$PREFIX"
    exit 0
fi
if [ -L "$MARKER" ] || [ ! -f "$MARKER" ] || [ "$(cat "$MARKER")" != "$MARKER_TEXT" ]; then
    printf 'Error: ownership marker missing or invalid. Nothing was removed.\n' >&2
    exit 1
fi

for name in $ALIASES; do
    target="$BIN_DIR/$name"
    if [ -L "$target" ]; then
        if [ "$(readlink "$target")" = "$INSTALLED_SCRIPT" ]; then
            rm -- "$target"
            printf 'Removed alias: %s\n' "$target"
        else
            printf 'Left unrelated symlink untouched: %s\n' "$target"
        fi
    elif [ -e "$target" ]; then
        printf 'Left non-symlink path untouched: %s\n' "$target"
    fi
done

if [ -f "$INSTALLED_SCRIPT" ] && [ ! -L "$INSTALLED_SCRIPT" ]; then
    rm -- "$INSTALLED_SCRIPT"
fi
rm -f "$MARKER"
if ! rmdir "$LIB_DIR" 2>/dev/null; then
    printf 'The install directory is not empty; left it in place: %s\n' "$LIB_DIR"
fi
printf '\nSleep, My Sweetie has been uninstalled. Goodbye! ❤️\n'
