# Sleep, My Sweetie ❤️

> A tiny, playful set of Linux shutdown commands with one job: say goodnight to your computer.

Sleep, My Sweetie provides eight memorable terminal commands for Ubuntu and other systemd-based Linux distributions. All command names point to one shared implementation.

## Quick start

    git clone https://github.com/aminhassanpour1999/sleep-my-sweetie.git
    cd sleep-my-sweetie
    sudo sh ./install.sh

Then run any alias:

    sudo sleep_my_sweetie
    sudo goodnight_my_love
    sudo off_you_go
    sudo night_night
    sudo rest_in_peace
    sudo bye_bye_baby
    sudo shut_down_sweetheart
    sudo time_to_sleep

The command displays a friendly message, counts down from five, and requests a system power-off through the standard `shutdown -h now` command. Press Ctrl+C during the countdown to cancel.

## Safe preview

    sh bin/sleep_my_sweetie --dry-run

Dry-run mode does not require root and never calls the shutdown command.

## Features

- Eight command names with one canonical implementation.
- Five-second visible countdown.
- Ctrl+C and SIGTERM handling during the countdown.
- Dry-run mode for safe preview.
- Uses the standard shutdown command so systemd/logind can coordinate the normal shutdown sequence.
- Installer and uninstaller with ownership-marker checks.
- Refuses to overwrite unrelated command aliases or unmanaged install directories.
- Safe integration tests using a mock shutdown command and temporary directories.
- GitHub Actions workflow for tests and ShellCheck.

## Requirements

- Linux with systemd.
- POSIX-compatible sh.
- /usr/sbin/shutdown for normal use.
- Python 3 for the automated test suite.
- ShellCheck for static analysis (optional locally; installed in GitHub Actions).

The project is intended for Ubuntu and other systemd-based distributions. It is not designed for macOS, Windows, or non-systemd Linux distributions.

## Installation

    git clone https://github.com/aminhassanpour1999/sleep-my-sweetie.git
    cd sleep-my-sweetie
    sudo sh ./install.sh

The default installation locations are:

- /usr/local/lib/sleep-my-sweetie/
- /usr/local/bin/

The installer creates a managed-installation marker and checks for conflicts before creating aliases. It refuses to overwrite an unrelated file, symbolic link, or unmanaged project directory.

### Custom installation prefix

For packaging and isolated testing, the installer supports an absolute PREFIX:

    PREFIX="$HOME/.local" sh ./install.sh

This installs under the selected prefix. A custom prefix does not automatically add its bin directory to your PATH.

## Usage

Run an installed alias with sudo:

    sudo sleep_my_sweetie

The program runs `/usr/sbin/shutdown -h now` only after the countdown finishes. This uses the standard shutdown utility and requests an immediate halt/power-off. The system still applies its normal session, authorization, and inhibitor policies. Save your work before running it.

### Dry run

    sh bin/sleep_my_sweetie --dry-run

This displays the planned action and exits without requesting shutdown.

### Cancel

Press Ctrl+C during the countdown. The script handles SIGINT and exits before calling the shutdown command.

## Available commands

| Command | Meaning |
|---|---|
| sleep_my_sweetie | Sleep, my sweetie |
| goodnight_my_love | Goodnight, my love |
| off_you_go | Off you go |
| night_night | Night-night |
| rest_in_peace | Rest in peace (dark humor) |
| bye_bye_baby | Bye-bye, baby |
| shut_down_sweetheart | Shut down, sweetheart |
| time_to_sleep | Time to sleep |

All aliases are symbolic links to the same executable.

## Uninstallation

    sudo sh ./uninstall.sh

The uninstaller checks the ownership marker and removes only symbolic links that point to this project's installed executable. It does not recursively delete the installation directory. If unexpected files remain, the directory is left untouched.

For a custom prefix, use the same PREFIX value:

    PREFIX="$HOME/.local" sh ./uninstall.sh

## Tests

Run the safe integration tests:

    make test

The test suite uses a mock shutdown executable and temporary installation prefixes. It checks help output, argument validation, dry-run behavior, normal command flow, Ctrl+C cancellation, installation, reinstall, conflicts, and uninstallation.

**The tests never invoke the real system power-off command.**

## Static analysis

Install ShellCheck using your distribution's package manager, then run:

    make lint

ShellCheck reviews the shell scripts for common mistakes. It is not proof that the program is bug-free.

## Continuous integration

GitHub Actions runs the test suite and ShellCheck on pushes, pull requests, and manual workflow dispatches. See the Actions tab in the repository for results.

## Project structure

    sleep-my-sweetie/
    ├── .github/
    │   └── workflows/
    │       └── ci.yml
    ├── bin/
    │   └── sleep_my_sweetie
    ├── tests/
    │   └── test_suite.py
    ├── .editorconfig
    ├── .gitignore
    ├── CHANGELOG.md
    ├── CODE_WALKTHROUGH.md
    ├── CONTRIBUTING.md
    ├── LICENSE
    ├── Makefile
    ├── README.md
    ├── SECURITY.md
    ├── install.sh
    └── uninstall.sh

## Learn the code

New to shell scripting? Start with [CODE_WALKTHROUGH.md](CODE_WALKTHROUGH.md). It explains the project structure, shell basics, the main command, installation, uninstallation, tests, and GitHub Actions.

## Contributing

Read [CONTRIBUTING.md](CONTRIBUTING.md) before opening a pull request.

## Security

Read [SECURITY.md](SECURITY.md) before using the program or reporting a vulnerability.

## Changelog

See [CHANGELOG.md](CHANGELOG.md).

## License

MIT. See [LICENSE](LICENSE).
