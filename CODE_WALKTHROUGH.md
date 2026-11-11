# Code Walkthrough — Sleep, My Sweetie

This guide explains the project from the ground up. Read it beside the source files. The goal is to understand the decisions behind the code, not merely copy commands.

> Safety: this project can power off a real computer. Automated tests use a harmless mock shutdown executable and temporary directories. Never replace the mock with the real shutdown command during testing.

## 1. What does the project do?

Sleep, My Sweetie provides eight terminal command names:

- sleep_my_sweetie
- goodnight_my_love
- off_you_go
- night_night
- rest_in_peace
- bye_bye_baby
- shut_down_sweetheart
- time_to_sleep

All eight names are symbolic links to one executable. They are not eight separate programs.

When a user runs an alias with administrative privileges, the program prints a message, displays a five-second countdown, lets the user cancel with Ctrl+C, and finally asks systemd to power off the computer.

## 2. Project structure

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

| Path | Responsibility |
|---|---|
| bin/sleep_my_sweetie | The actual shutdown program |
| install.sh | Installs the program and aliases |
| uninstall.sh | Removes only a verified installation |
| tests/test_suite.py | Runs safe automated tests |
| Makefile | Provides short development commands |
| .github/workflows/ci.yml | Runs tests and ShellCheck on GitHub |
| README.md | User-facing installation and usage guide |
| CODE_WALKTHROUGH.md | Detailed explanation of the code |
| CONTRIBUTING.md | Contributor guidance |
| SECURITY.md | Security and safe-use policy |
| CHANGELOG.md | Version history |
| LICENSE | MIT License |

## 3. Shell scripting foundations

### 3.1 What is a shell?

A shell is a program that reads commands and asks the operating system to run them. Bash and Dash are examples.

A shell script is a text file containing shell commands. It saves a sequence of commands so they can be run together.

The first line of the main program is:

    #!/bin/sh

This is called a shebang. It tells the operating system which interpreter should run the file when it is executed directly. This project uses the system's POSIX-compatible sh.

### 3.2 Strict mode

    set -eu

- -e: stop when an unhandled command fails.
- -u: treat use of an unset variable as an error.

These options help the script fail early. They do not replace careful error handling.

### 3.3 Variables

A variable stores a value. The main script derives its displayed command name from the special shell parameter $0, which contains the script path. A shell parameter expansion removes the directory portion and leaves the final filename.

If the path is /usr/local/bin/sleep_my_sweetie, the resulting program name is sleep_my_sweetie.

There must not be spaces around the equals sign in a shell assignment.

### 3.4 Quoting

The scripts usually write variables inside double quotes:

    printf '%s\n' "$PROGRAM_NAME"

Quoting protects spaces and wildcard characters in a variable's value. This is why most variable expansions in the scripts are quoted.

### 3.5 Exit status

A command returns an exit status:

- 0 normally means success.
- A non-zero value means failure or a special outcome.

This project uses 1 for general errors, 2 for invalid command-line arguments, 130 for interruption with Ctrl+C, and 143 for termination by SIGTERM.

## 4. The main program: bin/sleep_my_sweetie

This is the only file that requests a power-off.

### 4.1 Interpreter and strict mode

    #!/bin/sh
    set -eu

The file uses sh and stops on many unexpected errors or unset variables.

### 4.2 Program name and shutdown path

The program derives PROGRAM_NAME from its script path. This value is used in the helpful sudo instruction.

SHUTDOWN normally points to /usr/sbin/shutdown. The environment override SLEEP_MY_SWEETIE_SHUTDOWN exists so automated tests can provide a harmless fake executable. It is not intended as a normal user configuration feature.

### 4.3 The help function

    show_help() {
        cat <<'HELP'
        ...
    HELP
    }

A shell function groups commands under a name. The function is called when the user requests --help or -h.

The text between the HELP markers is a here-document. It prints multiple lines without many separate printf commands.

The delimiter is quoted, so the shell does not expand variables or command substitutions inside the help text.

### 4.4 Validate command-line arguments

The script first checks the number of arguments:

    if [ "$#" -gt 1 ]; then
        ...
        exit 2
    fi

$# is the number of arguments supplied by the user. The program accepts no more than one argument.

The case statement recognizes four situations:

- -h or --help: show help and exit successfully.
- --dry-run: show the planned action without requesting shutdown.
- No argument: continue with the normal shutdown flow.
- Any other argument: print an error and exit with status 2.

Dry-run mode exits before the privilege check, countdown, and power-off request.

### 4.5 Print the message

The printf commands display the greeting. printf is used instead of echo because its formatting behavior is more predictable across shells.

The backslash-n sequence means a newline.

### 4.6 Dry-run mode

The dry-run branch prints what would happen and exits:

    if [ "$DRY_RUN" -eq 1 ]; then
        printf 'Dry run: no shutdown will be requested.\n'
        printf 'Would execute: %s --poweroff now\n' "$SHUTDOWN"
        exit 0
    fi

The exit command stops the script. It never reaches the countdown or shutdown.

### 4.7 Check administrative privileges

    if [ "$(id -u)" -ne 0 ] && [ "$SLEEP_MY_SWEETIE_TEST_MODE" != 1 ]; then
        ...
    fi

id -u prints the numeric user ID of the current process. On Linux, user ID 0 is root.

The normal command asks the user to run it with sudo. The test-mode exception is used only by automated tests with a fake shutdown executable. Do not set test mode for normal use.

### 4.8 Check shutdown

    if [ ! -x "$SHUTDOWN" ]; then
        ...
    fi

The -x test checks whether the path exists and is executable. If shutdown cannot be found, the script stops before beginning the countdown.

### 4.9 Signals and Ctrl+C

A signal is a notification sent to a process by the operating system or another process.

Ctrl+C normally sends SIGINT to the foreground process group. The script installs traps:

    trap 'cancel_shutdown' INT
    trap 'terminate_shutdown' TERM

A trap tells the shell to run a chosen function when it receives a signal.

The SIGINT trap prints a cancellation message and exits with status 130. The SIGTERM trap prints an interruption message and exits with status 143.

This prevents the script from continuing to shutdown after the user interrupts the countdown.

### 4.10 The countdown loop

    remaining=5
    while [ "$remaining" -gt 0 ]; do
        printf '  %s...\n' "$remaining"
        sleep 1
        remaining=$((remaining - 1))
    done

- remaining starts at 5.
- while repeats as long as remaining is greater than zero.
- sleep 1 pauses for one second.
- $((...)) performs integer arithmetic in the shell.
- Each loop subtracts one.

The visible sequence is 5, 4, 3, 2, 1.

### 4.11 Request the power-off

    trap - INT TERM
    printf 'Goodnight! ❤️\n'
    exec "$SHUTDOWN" --poweroff now

When the countdown finishes, the script removes its custom signal handlers and prints the final message.

exec replaces the current shell process with shutdown. The `--poweroff now` arguments ask the standard shutdown utility to request a normal system power-off through systemd/logind.

This is the real, potentially destructive operation. Save your work before running the command.

## 5. The installer: install.sh

The installer copies the command to a system location and creates symbolic links.

### 5.1 Installation prefix

The default installation prefix is /usr/local. The normal locations become:

- /usr/local/lib/sleep-my-sweetie/
- /usr/local/bin/

A prefix is the base directory under which software is installed. PREFIX can be changed for packaging and isolated tests. The test suite uses a temporary directory, not the real system directories.

### 5.2 Root check

A normal installation under /usr/local requires root privileges. A custom prefix is allowed for tests and staging.

This lets automated tests exercise the installer without modifying the real computer.

### 5.3 Validate paths

The installer checks that PREFIX is absolute and is not the filesystem root. It also refuses to use a symbolic link or a non-directory where the project library or binary directory should be.

These checks reduce the chance of writing into an unexpected location.

### 5.4 Ownership marker

The installer creates a file named:

    .sleep-my-sweetie-managed

Its content must match the expected project marker text.

A directory named sleep-my-sweetie might already belong to another program or person. A matching marker provides evidence that this installer created the directory. Without it, the installer refuses to overwrite the directory.

This is a safety guard, not a cryptographic security boundary. A local administrator can edit the marker.

### 5.5 Preflight alias checks

Before writing files, the installer checks all eight command names.

An existing path is accepted only when it is a symbolic link that already points to this project's installed executable. An unrelated file, directory, or link causes installation to stop.

Checking all names first avoids discovering a conflict only after some aliases have already been created.

### 5.6 Install the executable safely

The installer creates destination directories, writes the source to a temporary file, and renames the temporary file into place.

The install command sets permissions to 0755:

- Owner: read, write, execute.
- Group: read and execute.
- Others: read and execute.

The rename helps avoid leaving a partially written executable if the process is interrupted during the copy.

### 5.7 Create symbolic links

A symbolic link is a filesystem reference to another path. It behaves like an alias.

For each name, ln -s creates a link to the one canonical executable. There is only one implementation to maintain.

### 5.8 Cleanup trap

The installer records the temporary filename and registers a cleanup trap. If the script exits while the temporary file remains, the trap removes it.

This reduces leftover temporary files after an interrupted installation.

## 6. The uninstaller: uninstall.sh

The uninstaller follows the same PREFIX convention as the installer.

Its most important rule is that it checks the ownership marker before removing anything from the project installation directory.

For each command alias:

1. It checks whether the path is a symbolic link.
2. It reads the link destination.
3. It removes the link only if the destination exactly matches this project's installed executable.
4. It leaves unrelated files and links untouched.

After processing aliases, it removes the installed executable and marker, then tries to remove the now-empty project directory.

If other files remain, rmdir fails and the directory is left in place. This is intentional: the uninstaller should not recursively delete unknown files.

## 7. Automated tests: tests/test_suite.py

The test suite uses Python's standard library. It does not require third-party Python packages.

### 7.1 Why mock shutdown?

A test must never accidentally power off the developer's computer or a CI machine.

The tests create a temporary executable named shutdown. It only writes its arguments to a log file. The main script is told to use this mock through SLEEP_MY_SWEETIE_SHUTDOWN.

When the command reaches the power-off step during a test, the fake executable records the word poweroff instead of powering off the machine.

### 7.2 Temporary directories

tempfile.TemporaryDirectory creates a temporary directory and removes it when the test finishes.

The installer tests set PREFIX to a folder inside this temporary directory. They never install files into /usr/local.

### 7.3 Test groups

The suite checks:

1. Help text and invalid argument handling.
2. Dry-run mode does not call shutdown.
3. Normal execution reaches the mock shutdown with the `--poweroff now` arguments.
4. SIGINT during the countdown prevents shutdown from running.
5. Installation creates the executable and all aliases.
6. Reinstallation is idempotent.
7. Alias conflicts do not overwrite unrelated files.
8. An unmanaged library directory is not overwritten.
9. Uninstallation removes project-owned files and preserves unrelated files.

A passing test means the tested behavior worked in that test environment. It does not prove that every Linux distribution, filesystem, shell, or hardware setup behaves identically.

### 7.4 Run tests

From the repository root:

    make test

Or run the test file directly:

    python3 tests/test_suite.py

The expected final message reports that all test groups passed and no real shutdown was performed.

### 7.5 Python imports and shared paths

The test file imports only Python standard-library modules:

- os reads and modifies environment variables and sends signals.
- pathlib builds filesystem paths safely.
- signal provides signal names such as SIGINT and SIGKILL.
- subprocess starts programs and captures their output.
- tempfile creates temporary directories that are automatically cleaned up.
- time measures deadlines while waiting for the countdown to begin.

ROOT is calculated from the location of the test file. The other path constants point to the command, installer, and uninstaller. ALIASES is a tuple containing the eight expected command names.

Using pathlib instead of manually joining strings makes path handling clearer across operating systems.

### 7.6 The run helper

The run helper wraps subprocess.run. It:

1. Starts a command from the repository root.
2. Passes an optional environment dictionary.
3. Captures standard output and standard error together.
4. Returns the process result.
5. Raises an assertion with the captured output when check is enabled and the command fails.

This keeps each test shorter and makes failures easier to understand.

### 7.7 The executable helper

The executable helper writes text to a temporary file and changes its permissions to 0755.

The tests use it to create mock programs such as shutdown and sleep. These mock programs are small controlled substitutes for real operating-system commands.

### 7.8 What each test verifies

**test_help_and_arguments**

Runs the main script with --help and checks for important help text. It then supplies an unknown option and too many arguments, expecting exit status 2.

**test_dry_run_never_calls_poweroff**

Creates a fake shutdown program that would write its arguments to a log. It runs dry-run mode and verifies that the log was never created. This proves the dry-run branch exits before shutdown.

**test_normal_flow_uses_mock_shutdown**

Creates a fake sleep command that returns immediately, so the five countdown iterations do not take five seconds. It also creates a fake shutdown command that records its arguments. The test enables the test-only privilege bypass and verifies that the recorded arguments are `--poweroff now`.

No actual system shutdown is requested.

**test_ctrl_c_cancels_before_shutdown**

Creates a fake sleep command that waits long enough for the test to interrupt the process. The test starts the shell script in a new process session, waits until the first countdown number appears, and sends SIGINT to the process group.

It then verifies that the process stops and that the fake shutdown log was never created. The process-group approach sends the interrupt to the shell and its waiting child process, similar to how a terminal delivers Ctrl+C to a foreground command group.

**test_install_reinstall_conflicts_and_uninstall**

Creates a temporary PREFIX and runs the real installer against that isolated location.

It checks that the canonical executable, ownership marker, and eight symbolic links are created. It runs the installer a second time to verify repeatability.

Next, it creates an unrelated file using one of the alias names and verifies that the installer refuses to overwrite it. It also creates an unmanaged project directory and verifies that its contents are preserved.

Finally, it runs the uninstaller and checks that project-owned links and files are removed while an unrelated command remains.

### 7.9 The test runner

The main function stores the test functions in a tuple and calls them one by one. After each successful test, it prints a PASS line. If an assertion fails, Python stops and reports the failure.

The final message is printed only after every test group succeeds.

The tests are integration tests: they check how several parts of the project work together. They are not a substitute for testing on every supported Linux distribution.

## 8. Makefile

The Makefile provides short commands:

- make test runs the Python test suite.
- make lint runs ShellCheck.
- make install invokes the installer with sudo.
- make uninstall invokes the uninstaller with sudo.

A Makefile target is a named task. Commands under a target must begin with a real tab character.

## 9. ShellCheck

ShellCheck is a static analysis tool for shell scripts. It looks for common mistakes and suspicious patterns without running the shutdown command.

Run:

    make lint

ShellCheck does not prove a script is bug-free. It is an additional review tool.

## 10. GitHub Actions continuous integration

The workflow lives at .github/workflows/ci.yml.

It runs when a commit is pushed, a pull request is opened or updated, or someone manually starts the workflow.

The workflow checks out the repository, prepares Python, installs ShellCheck, runs the tests, and runs the linter.

This is called continuous integration (CI): every proposed change receives the same automated checks.

A green workflow means those configured checks passed. It does not mean the project has been tested on every possible Linux system.

## 11. Versioning and releases

The changelog records user-visible changes. Semantic Versioning uses three numbers:

- MAJOR: incompatible changes.
- MINOR: new backward-compatible features.
- PATCH: backward-compatible bug fixes.

For example, 1.1.0 means the first minor feature update after 1.0.0.

A Git tag such as v1.1.0 can point to the commit representing that release. A changelog entry and a Git tag are related but are not the same thing.

## 12. Safe manual workflow

Before a real installation:

1. Read the README.
2. Read this walkthrough.
3. Inspect the shell scripts.
4. Run make test.
5. Run make lint if ShellCheck is installed.
6. Review the GitHub Actions result.
7. Only then consider a real installation.

For a safe preview:

    sh bin/sleep_my_sweetie --dry-run

To install system-wide:

    sudo sh ./install.sh

To remove the installation:

    sudo sh ./uninstall.sh

To request an actual power-off:

    sudo sleep_my_sweetie

Do not run the final command until your work is saved and you genuinely intend to power off the computer.

## 13. What you should understand after this guide

You should now be able to explain:

- What a shell script and shebang are.
- Why variables are quoted.
- What conditions, functions, loops, and exit codes do.
- How the countdown works.
- How signal traps handle Ctrl+C.
- Why the standard shutdown utility is used for the real power-off operation.
- How an installer checks paths and creates symbolic links.
- Why the ownership marker protects unrelated files.
- How the uninstaller avoids recursive deletion.
- How mock executables make dangerous commands testable.
- How temporary directories isolate installer tests.
- How GitHub Actions runs tests and ShellCheck automatically.

The best next step is to open each source file and explain it in your own words. If you can do that, you are learning the engineering decisions behind the program—not just copying commands.
