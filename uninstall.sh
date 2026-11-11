#!/bin/sh
#
# Remove Sleep, My Sweetie and only its own command symlinks.
#
set -eu

if [ "$(id -u)" -ne 0 ]; then
    printf 'Please run the uninstaller with sudo:\n  sudo ./uninstall.sh\n' >&2
    exit 1
fi

LIB_DIR="/usr/local/lib/sleep-my-sweetie"
INSTALLED_SCRIPT="$LIB_DIR/sleep_my_sweetie"
BIN_DIR="/usr/local/bin"

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

for name in $ALIASES; do
    target="$BIN_DIR/$name"
    if [ -L "$target" ]; then
        link_target=$(readlink "$target")
        if [ "$link_target" = "$INSTALLED_SCRIPT" ]; then
            rm -- "$target"
            printf 'Removed alias: %s\n' "$target"
        else
            printf 'Left unrelated symlink untouched: %s\n' "$target"
        fi
    elif [ -e "$target" ]; then
        printf 'Left non-symlink path untouched: %s\n' "$target"
    fi
done

if [ -f "$INSTALLED_SCRIPT" ]; then
    rm -- "$INSTALLED_SCRIPT"
fi
if [ -d "$LIB_DIR" ]; then
    rmdir "$LIB_DIR" 2>/dev/null || {
        printf 'The install directory is not empty; left it in place: %s\n' "$LIB_DIR"
    }
fi

printf '\nSleep, My Sweetie has been uninstalled. Goodbye! ❤️\n'
