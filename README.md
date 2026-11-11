# Sleep, My Sweetie ❤️

> A tiny, playful set of Linux shutdown commands with one job: say goodnight to your computer.

Sleep, My Sweetie gives Ubuntu and other systemd-based Linux machines several memorable terminal commands. Every alias runs the same carefully maintained shutdown script.

## Quick look

```bash
sudo sleep_my_sweetie
sudo goodnight_my_love
sudo off_you_go
sudo night_night
sudo rest_in_peace
sudo bye_bye_baby
sudo shut_down_sweetheart
sudo time_to_sleep
```

The default message is:

```text
Goodnight, my sweetie. ❤️
You've worked hard today.
Time to rest.
```

The command waits five seconds before requesting a system power-off. Press **Ctrl+C** during the countdown to cancel.

## Features

- Eight memorable command names and one shared implementation.
- Visible, five-second cancellable countdown.
- Uses the standard `systemctl poweroff` command.
- No daemon, background service, network access, or automatic startup.
- Installer and uninstaller scripts.
- Refuses to overwrite unrelated files in `/usr/local/bin`.
- Lightweight shell-based tests.

## Requirements

- Linux with systemd.
- `/usr/bin/systemctl`.
- POSIX-compatible `sh`.
- Administrative privileges to install and power off the computer.

This project is intended for Ubuntu and other systemd-based distributions. It is not designed for macOS, Windows, WSL without systemd power management, or non-systemd Linux distributions.

## Installation

Clone the repository:

```bash
git clone https://github.com/aminhassanpour1999/sleep-my-sweetie.git
cd sleep-my-sweetie
```

Run the installer:

```bash
sudo ./install.sh
```

Verify the installation:

```bash
command -v sleep_my_sweetie
ls -l /usr/local/bin/sleep_my_sweetie
```

The installer places the canonical executable in `/usr/local/lib/sleep-my-sweetie/` and creates symbolic links in `/usr/local/bin/`. It checks for conflicts and stops rather than overwriting unrelated paths.

## Usage

Run any alias with `sudo`:

```bash
sudo sleep_my_sweetie
```

The script prints the goodnight message, counts down from five, and then executes:

```bash
/usr/bin/systemctl poweroff
```

Administrative privileges are required for the intended system-wide power-off operation.

## Available commands

| Command | Meaning |
| --- | --- |
| `sleep_my_sweetie` | Sleep, my sweetie |
| `goodnight_my_love` | Goodnight, my love |
| `off_you_go` | Off you go |
| `night_night` | Night-night |
| `rest_in_peace` | Rest in peace (dark humor) |
| `bye_bye_baby` | Bye-bye, baby |
| `shut_down_sweetheart` | Shut down, sweetheart |
| `time_to_sleep` | Time to sleep |

All aliases point to the same executable. They are not separate implementations.

## Cancel the countdown

Press **Ctrl+C** while the five-second countdown is running. The script will stop before requesting shutdown. Once systemd has accepted the power-off request, cancellation may no longer be possible.

## Uninstallation

From the cloned project directory:

```bash
sudo ./uninstall.sh
```

The uninstaller removes only symlinks that point to this project's installed executable, then removes the executable and its empty private directory. Unrelated files and commands are left untouched.

## Project structure

```text
sleep-my-sweetie/
├── bin/
│   └── sleep_my_sweetie
├── tests/
│   └── test-command.sh
├── .editorconfig
├── .gitignore
├── CHANGELOG.md
├── CONTRIBUTING.md
├── LICENSE
├── Makefile
├── README.md
├── SECURITY.md
├── install.sh
└── uninstall.sh
```

## Safety

**This program really powers off your computer.**

- Save your work before running any shutdown alias.
- The countdown is only a brief chance to cancel; it is not a substitute for saving files.
- Inspect scripts before running them with administrative privileges.
- The project does not schedule shutdowns or run automatically at startup.
- The installer deliberately refuses to replace existing unrelated commands.

## Tests and development

Run the test suite:

```bash
make test
```

The tests check help output and the expected power-off invocation. They do **not** perform a real shutdown.

Optional static analysis:

```bash
shellcheck bin/sleep_my_sweetie install.sh uninstall.sh tests/test-command.sh
```

ShellCheck is optional and is not installed automatically.

## Contributing

Contributions are welcome. Read [CONTRIBUTING.md](CONTRIBUTING.md) before opening a pull request.

## Security

See [SECURITY.md](SECURITY.md) for the security policy and safe-use notes.

## Changelog

See [CHANGELOG.md](CHANGELOG.md) for release history.

## License

MIT. See [LICENSE](LICENSE).
