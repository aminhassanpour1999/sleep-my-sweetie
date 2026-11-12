# Contributing

Thank you for considering a contribution to Sleep, My Sweetie.

## Project principles

- Keep the project small, understandable, and easy to audit.
- Maintain one canonical implementation; aliases should point to it.
- Do not add telemetry, network access, background services, or automatic startup behavior.
- Keep a visible countdown before a real shutdown.
- Never let automated tests power off a developer's or CI machine.
- Protect unrelated files during installation and uninstallation.

## Development setup

Requirements:

- A POSIX-compatible shell.
- Python 3.
- ShellCheck (recommended).

Clone the repository and run:

    make test
    make lint

Check the local shutdown environment safely with:

    sh bin/sleep_my_sweetie --doctor

The test suite uses mock shutdown and GNOME-session executables, a temporary Unix-socket path, and temporary installation prefixes. It also checks diagnostic-only execution, version/changelog consistency, and that installation does not depend on systemctl. It must never call the real system power-off command.

## Pull requests

Please include:

1. A clear explanation of the problem and proposed change.
2. The behavior users will observe.
3. Test results.
4. Documentation updates when commands, options, installation, or behavior change.

Keep pull requests focused and avoid adding features that make this small utility unnecessarily complicated.

## Security-sensitive changes

Changes to install paths, symbolic links, privilege checks, signal handling, or shutdown-command execution require particular care. Explain how the change avoids overwriting unrelated files and how it is tested safely.

Thank you for helping improve the project.
