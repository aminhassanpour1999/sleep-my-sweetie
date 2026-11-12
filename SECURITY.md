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
- Use --doctor to inspect the local environment; it does not request power-off.
- Do not run the real shutdown command as part of automated tests.
- The test suite uses a mock shutdown executable and temporary directories.

## Test-only environment variables

SLEEP_MY_SWEETIE_SHUTDOWN allows the test suite to substitute a harmless mock executable for the shutdown command.

SLEEP_MY_SWEETIE_GNOME_SESSION_QUIT allows tests to substitute a harmless mock for `gnome-session-quit`. SLEEP_MY_SWEETIE_RUNTIME_DIR allows tests to provide a temporary directory containing a mock Unix-domain session-bus socket.

SLEEP_MY_SWEETIE_TEST_MODE allows the test suite to exercise the normal command path without root privileges. It is intended only for automated tests and should not be set for normal use.

PREFIX selects an installation prefix. The default is /usr/local. Custom prefixes are used for packaging and isolated tests.

All SLEEP_MY_SWEETIE_* overrides above are intended only for automated tests and must not be used as normal configuration. These variables are not a security boundary. Do not run scripts from untrusted sources as root.

## Reporting a vulnerability

Please do not publish sensitive exploit details in a public issue. Use GitHub's private vulnerability reporting feature if it is enabled for this repository. Otherwise, contact the repository owner privately through a channel listed on their GitHub profile.

Include the affected version, relevant command or file, reproduction steps, and potential impact.
