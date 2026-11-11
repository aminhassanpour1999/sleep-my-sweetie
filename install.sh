#!/bin/sh
#
# Install Sleep, My Sweetie and its command aliases.
#
set -eu

if [ "$(id -u)" -ne 0 ]; then
    printf 'Please run the installer with sudo:\n  sudo ./install.sh\n' >&2
    exit 1
fi

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
SOURCE_SCRIPT="$SCRIPT_DIR/bin/sleep_my_sweetie"
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

if [ ! -f "$SOURCE_SCRIPT" ]; then
    printf 'Error: cannot find %s\n' "$SOURCE_SCRIPT" >&2
    exit 1
fi
if [ ! -x /usr/bin/systemctl ]; then
    printf 'Error: /usr/bin/systemctl was not found. systemd is required.\n' >&2
    exit 1
fi

# Preflight all alias paths before changing anything.
for name in $ALIASES; do
    target="$BIN_DIR/$name"
    if [ -e "$target" ] || [ -L "$target" ]; then
        if [ -L "$target" ] && [ "$(readlink "$target")" = "$INSTALLED_SCRIPT" ]; then
            continue
        fi
        printf 'Error: refusing to overwrite existing path: %s\n' "$target" >&2
        printf 'Inspect it manually, then rerun the installer if appropriate.\n' >&2
        exit 1
    fi
done

install -d -m 0755 "$LIB_DIR" "$BIN_DIR"
install -m 0755 "$SOURCE_SCRIPT" "$INSTALLED_SCRIPT"

for name in $ALIASES; do
    target="$BIN_DIR/$name"
    if [ ! -L "$target" ]; then
        ln -s "$INSTALLED_SCRIPT" "$target"
    fi
done

printf '\nSleep, My Sweetie has been installed successfully. ❤️\n\n'
printf 'Try:\n  sudo sleep_my_sweetie\n  sudo goodnight_my_love\n'
printf '\nTo see all aliases, run:\n'
printf '  ls -l /usr/local/bin/{sleep_my_sweetie,goodnight_my_love,off_you_go,night_night,rest_in_peace,bye_bye_baby,shut_down_sweetheart,time_to_sleep}\n'
