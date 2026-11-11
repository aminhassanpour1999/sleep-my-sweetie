# Changelog

Notable project changes are documented here.

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
