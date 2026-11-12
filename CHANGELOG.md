# Changelog

Notable project changes are documented here.

## [1.1.2] - 2026-11-12

- Use `shutdown -h now` for the final power-off request, matching the command form verified on the target Ubuntu system.
- Updated dry-run output, safe tests, and documentation to use the `-h now` arguments.

## [1.1.1] - 2026-11-11

- Switched the final power-off request to the standard `shutdown --poweroff now` command, allowing systemd/logind to handle the normal shutdown sequence without systemctl's interactive inhibitor pre-check.
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
