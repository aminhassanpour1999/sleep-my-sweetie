# Changelog

Notable project changes are documented here.

## [1.1.4] - 2026-11-12

- Add `--version` and `-V` options to display the program version without starting the countdown or requesting power-off.
- Add automated tests for both version options.
- Update user and developer documentation for version reporting.

## [1.1.3] - 2026-11-12

- Use the active GNOME desktop session to request power-off and display GNOME's standard confirmation dialog when available.
- Keep the standard `shutdown -h now` fallback for environments without an active GNOME session bus.
- Ensure cancelling or failing the GNOME request never falls back to a direct shutdown request.
- Add safe automated coverage for GNOME session-bus routing and cancellation.
- Update user and developer documentation for the GNOME-aware shutdown flow.

## [1.1.2] - 2026-11-12

- Use `shutdown -h now` for the final power-off request, matching the command form verified on the target Ubuntu system.
- Updated dry-run output, safe tests, and documentation to use the `-h now` arguments.

## [1.1.1] - 2026-11-11

- Replaced the direct `systemctl poweroff` invocation with the standard `shutdown` utility. The initial `--poweroff now` argument form was subsequently refined in v1.1.2 after testing on Ubuntu.
- Updated safe tests and documentation to use a mocked shutdown executable.

## [1.1.0] - 2026-11-11

- Added a safe dry-run option to preview the main command.
- Added explicit SIGINT and SIGTERM handling during the countdown.
- Hardened installation with an ownership marker.
- Refused to overwrite unmanaged installation directories and unrelated alias paths.
- Made installation repeatable for an already managed installation.
- Hardened uninstallation to remove only verified project-owned links and files.
- Added safe integration tests using a mock systemctl and temporary prefixes.
- Added GitHub Actions continuous integration.
- Added ShellCheck through the Makefile lint target.
- Added CODE_WALKTHROUGH.md with a detailed explanation of the code.

## [1.0.0] - 2026-11-11

- Initial release.
- Added one canonical shutdown command.
- Added eight playful command names through symbolic links.
- Added a five-second countdown.
- Added installation and uninstallation scripts.
- Added basic tests and project documentation.
