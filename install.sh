#!/bin/sh
# Install Sleep, My Sweetie and its command aliases.
set -eu

PREFIX=${PREFIX:-/usr/local}
SYSTEMCTL=${SLEEP_MY_SWEETIE_SYSTEMCTL:-/usr/bin/systemctl}
MARKER_TEXT='Sleep, My Sweetie managed installation v1'

# Custom prefixes support packaging and safe integration tests.
if [ "$PREFIX" = "/usr/local" ] && [ "$(id -u)" -ne 0 ]; then
    printf 'Please run the installer with sudo:\n  sudo sh ./install.sh\n' >&2
    exit 1
fi
case "$PREFIX" in
    /*) ;;
    *) printf 'Error: PREFIX must be an absolute path: %s\n' "$PREFIX" >&2; exit 1 ;;
esac
while [ "$PREFIX" != "/" ] && [ "${PREFIX%/}" != "$PREFIX" ]; do
    PREFIX=${PREFIX%/}
done
if [ "$PREFIX" = "/" ]; then
    printf 'Error: refusing to install directly into filesystem root.\n' >&2
    exit 1
fi

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
SOURCE_SCRIPT="$SCRIPT_DIR/bin/sleep_my_sweetie"
LIB_PARENT="$PREFIX/lib"
LIB_DIR="$LIB_PARENT/sleep-my-sweetie"
INSTALLED_SCRIPT="$LIB_DIR/sleep_my_sweetie"
MARKER="$LIB_DIR/.sleep-my-sweetie-managed"
BIN_DIR="$PREFIX/bin"

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

[ -f "$SOURCE_SCRIPT" ] || { printf 'Error: cannot find %s\n' "$SOURCE_SCRIPT" >&2; exit 1; }
[ -x "$SYSTEMCTL" ] || { printf 'Error: systemctl executable not found: %s\n' "$SYSTEMCTL" >&2; exit 1; }

if [ -L "$PREFIX" ] || { [ -e "$PREFIX" ] && [ ! -d "$PREFIX" ]; }; then
    printf 'Error: PREFIX must be a real directory: %s\n' "$PREFIX" >&2
    exit 1
fi
if [ -L "$LIB_PARENT" ] || { [ -e "$LIB_PARENT" ] && [ ! -d "$LIB_PARENT" ]; }; then
    printf 'Error: refusing to use a non-directory or symbolic link: %s\n' "$LIB_PARENT" >&2
    exit 1
fi
if [ -L "$LIB_DIR" ] || { [ -e "$LIB_DIR" ] && [ ! -d "$LIB_DIR" ]; }; then
    printf 'Error: refusing non-directory or symlink: %s\n' "$LIB_DIR" >&2
    exit 1
fi
if [ -L "$BIN_DIR" ] || { [ -e "$BIN_DIR" ] && [ ! -d "$BIN_DIR" ]; }; then
    printf 'Error: refusing non-directory or symlink: %s\n' "$BIN_DIR" >&2
    exit 1
fi

# Trust an existing install directory only when our exact ownership marker
# proves that this project created it.
if [ -e "$LIB_DIR" ]; then
    if [ -L "$MARKER" ] || [ ! -f "$MARKER" ] || [ "$(cat "$MARKER")" != "$MARKER_TEXT" ]; then
        printf 'Error: refusing to modify unmanaged directory: %s\n' "$LIB_DIR" >&2
        exit 1
    fi
fi
if [ -e "$INSTALLED_SCRIPT" ] || [ -L "$INSTALLED_SCRIPT" ]; then
    if [ -L "$INSTALLED_SCRIPT" ] || [ ! -f "$INSTALLED_SCRIPT" ] || [ ! -f "$MARKER" ]; then
        printf 'Error: refusing to replace an unmanaged installed command: %s\n' "$INSTALLED_SCRIPT" >&2
        exit 1
    fi
fi

# Check every command name before changing any file.
for name in $ALIASES; do
    target="$BIN_DIR/$name"
    if [ -e "$target" ] || [ -L "$target" ]; then
        if [ -L "$target" ] && [ "$(readlink "$target")" = "$INSTALLED_SCRIPT" ]; then
            continue
        fi
        printf 'Error: refusing to overwrite existing path: %s\n' "$target" >&2
        exit 1
    fi
done

install -d -m 0755 "$LIB_DIR" "$BIN_DIR"
TEMP_SCRIPT="$LIB_DIR/.sleep_my_sweetie.tmp.$$"
cleanup() {
    [ ! -f "$TEMP_SCRIPT" ] || rm -f "$TEMP_SCRIPT"
}
trap cleanup EXIT
trap 'exit 1' HUP INT TERM
install -m 0755 "$SOURCE_SCRIPT" "$TEMP_SCRIPT"
mv -f "$TEMP_SCRIPT" "$INSTALLED_SCRIPT"
printf '%s\n' "$MARKER_TEXT" > "$MARKER"
chmod 0644 "$MARKER"

for name in $ALIASES; do
    target="$BIN_DIR/$name"
    if [ ! -L "$target" ]; then
        ln -s "$INSTALLED_SCRIPT" "$target"
    fi
done
trap - EXIT
trap - HUP INT TERM

printf '\nSleep, My Sweetie has been installed successfully. ❤️\n'
printf '\nAvailable commands:\n'
for name in $ALIASES; do printf '  sudo %s\n' "$name"; done
printf '\nInstallation prefix: %s\n' "$PREFIX"
