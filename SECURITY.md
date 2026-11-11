# Security Policy

## Scope

Sleep, My Sweetie is a local shell utility. By default, it installs one executable in:

- /usr/local/lib/sleep-my-sweetie/
- symbolic links in /usr/local/bin/

It does not intentionally collect data, communicate over a network, install a background service, or run automatically at startup.

## Safe use

**This program requests a real system power-off.**

- Save your work before running any shutdown alias.
- Read the scripts before running them with administrative privileges.
- Use --dry-run to preview the main command safely.
- Do not run the real shutdown command as part of automated tests.
- The test suite uses a mock systemctl executable and temporary directories.

## Test-only environment variables

SLEEP_MY_SWEETIE_SYSTEMCTL allows the test suite to substitute a harmless mock executable for systemctl.

SLEEP_MY_SWEETIE_TEST_MODE allows the test suite to exercise the normal command path without root privileges. It is intended only for automated tests and should not be set for normal use.

PREFIX selects an installation prefix. The default is /usr/local. Custom prefixes are used for packaging and isolated tests.

These variables are not a security boundary. Do not run scripts from untrusted sources as root.

## Reporting a vulnerability

Please do not publish sensitive exploit details in a public issue. Use GitHub's private vulnerability reporting feature if it is enabled for this repository. Otherwise, contact the repository owner privately through a channel listed on their GitHub profile.

Include the affected version, relevant command or file, reproduction steps, and potential impact.
