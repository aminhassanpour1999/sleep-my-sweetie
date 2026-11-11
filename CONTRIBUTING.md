# Contributing

Thanks for your interest in contributing to Sleep, My Sweetie!

## Project principles

- Keep the project small, understandable, and easy to audit.
- Preserve the single-implementation design: aliases point to one canonical command.
- Do not add telemetry, network access, background services, or automatic startup behavior.
- Keep a visible countdown before shutdown.
- Never make tests power off the developer's machine.

## Development workflow

1. Fork the repository.
2. Create a focused branch.
3. Make your change.
4. Run `make test`.
5. If available, run ShellCheck:

   ```bash
   shellcheck bin/sleep_my_sweetie install.sh uninstall.sh tests/test-command.sh
   ```

6. Explain user-visible behavior and system changes in your pull request.

## Pull requests

Include a clear description, the reason for the change, test results, and documentation updates when commands or behavior change.

Thank you!
