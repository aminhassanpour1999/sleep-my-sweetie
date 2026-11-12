#!/usr/bin/env python3
"""Safe integration tests use mocks; no real shutdown or GNOME action occurs."""

import getpass
import os
import pathlib
import signal
import socket
import subprocess
import tempfile
import time

ROOT = pathlib.Path(__file__).resolve().parents[1]
COMMAND = ROOT / "bin" / "sleep_my_sweetie"
INSTALLER = ROOT / "install.sh"
UNINSTALLER = ROOT / "uninstall.sh"
ALIASES = (
    "sleep_my_sweetie", "goodnight_my_love", "off_you_go", "night_night",
    "rest_in_peace", "bye_bye_baby", "shut_down_sweetheart", "time_to_sleep",
)


def run(args, env=None, check=True):
    result = subprocess.run(
        args, cwd=ROOT, env=env, text=True,
        stdout=subprocess.PIPE, stderr=subprocess.STDOUT, check=False,
    )
    if check and result.returncode:
        raise AssertionError(f"Command failed ({result.returncode}): {args}\n{result.stdout}")
    return result


def executable(path, contents):
    path.write_text(contents, encoding="utf-8")
    path.chmod(0o755)
    return path


def test_help_and_arguments():
    help_result = run(["sh", str(COMMAND), "--help"])
    assert "Usage:" in help_result.stdout
    assert "--dry-run" in help_result.stdout
    assert "goodnight_my_love" in help_result.stdout
    long_version = run(["sh", str(COMMAND), "--version"])
    short_version = run(["sh", str(COMMAND), "-V"])
    assert long_version.stdout.strip() == "Sleep, My Sweetie 1.1.4"
    assert short_version.stdout.strip() == long_version.stdout.strip()
    invalid = run(["sh", str(COMMAND), "--invalid"], check=False)
    assert invalid.returncode == 2
    extra = run(["sh", str(COMMAND), "--dry-run", "extra"], check=False)
    assert extra.returncode == 2


def test_dry_run_never_calls_shutdown():
    with tempfile.TemporaryDirectory() as directory:
        base = pathlib.Path(directory)
        log = base / "shutdown.log"
        mock = executable(base / "shutdown", '#!/bin/sh\nprintf "%s\\n" "$*" >> "$MOCK_LOG"\n')
        env = os.environ.copy()
        no_bus = base / "no-bus"
        no_bus.mkdir()
        env.update({
            "SLEEP_MY_SWEETIE_SHUTDOWN": str(mock),
            "SLEEP_MY_SWEETIE_RUNTIME_DIR": str(no_bus),
            "MOCK_LOG": str(log),
        })
        result = run(["sh", str(COMMAND), "--dry-run"], env)
        assert "Dry run" in result.stdout
        assert f"Would execute: {mock} -h now" in result.stdout
        assert not log.exists()


def test_normal_flow_uses_mock_shutdown():
    with tempfile.TemporaryDirectory() as directory:
        base = pathlib.Path(directory)
        log = base / "shutdown.log"
        mock = executable(base / "shutdown", '#!/bin/sh\nprintf "%s\\n" "$*" >> "$MOCK_LOG"\n')
        fake_sleep = executable(base / "sleep", "#!/bin/sh\nexit 0\n")
        env = os.environ.copy()
        env.update({
            "PATH": f"{base}:{env.get('PATH', '')}",
            "SLEEP_MY_SWEETIE_SHUTDOWN": str(mock),
            "SLEEP_MY_SWEETIE_TEST_MODE": "1",
            "SLEEP_MY_SWEETIE_RUNTIME_DIR": str(base / "no-bus"),
            "MOCK_LOG": str(log),
        })
        (base / "no-bus").mkdir()
        env.pop("SUDO_USER", None)
        result = run(["sh", str(COMMAND)], env)
        assert "Goodnight!" in result.stdout
        assert log.read_text(encoding="utf-8").strip() == "-h now"



def test_gnome_session_poweroff_uses_desktop_user_bus():
    with tempfile.TemporaryDirectory() as directory:
        base = pathlib.Path(directory)
        runtime = base / "runtime"
        runtime.mkdir()
        bus_path = runtime / "bus"
        with socket.socket(socket.AF_UNIX) as bus:
            bus.bind(str(bus_path))

        gnome_log = base / "gnome.log"
        shutdown_log = base / "shutdown.log"
        gnome_mock = executable(
            base / "gnome-session-quit",
            '#!/bin/sh\nprintf "%s|%s|%s\\n" "$*" "$XDG_RUNTIME_DIR" "$DBUS_SESSION_BUS_ADDRESS" >> "$GNOME_LOG"\nexit "${MOCK_EXIT:-0}"\n',
        )
        shutdown_mock = executable(
            base / "shutdown",
            '#!/bin/sh\nprintf "%s\\n" "$*" >> "$SHUTDOWN_LOG"\n',
        )
        fake_sleep = executable(base / "sleep", "#!/bin/sh\nexit 0\n")
        env = os.environ.copy()
        env.update({
            "PATH": f"{base}:{env.get('PATH', '')}",
            "SLEEP_MY_SWEETIE_TEST_MODE": "1",
            "SLEEP_MY_SWEETIE_GNOME_SESSION_QUIT": str(gnome_mock),
            "SLEEP_MY_SWEETIE_RUNTIME_DIR": str(runtime),
            "SLEEP_MY_SWEETIE_SHUTDOWN": str(shutdown_mock),
            "SUDO_USER": getpass.getuser(),
            "GNOME_LOG": str(gnome_log),
            "SHUTDOWN_LOG": str(shutdown_log),
        })

        result = run(["sh", str(COMMAND)], env)
        assert "Requesting power-off confirmation from GNOME" in result.stdout
        expected_bus = f"unix:path={bus_path}"
        assert gnome_log.read_text(encoding="utf-8").strip() == (
            f"--power-off|{runtime}|{expected_bus}"
        )
        assert not shutdown_log.exists(), "GNOME path must not fall back to direct shutdown"

        # A cancelled/failed GNOME request must not fall back to direct shutdown.
        env["MOCK_EXIT"] = "42"
        cancelled = run(["sh", str(COMMAND)], env, check=False)
        assert cancelled.returncode == 42
        assert "cancelled or failed" in cancelled.stdout
        assert len(gnome_log.read_text(encoding="utf-8").splitlines()) == 2
        assert not shutdown_log.exists()


def test_ctrl_c_cancels_before_shutdown():
    with tempfile.TemporaryDirectory() as directory:
        base = pathlib.Path(directory)
        log = base / "shutdown.log"
        mock = executable(base / "shutdown", '#!/bin/sh\nprintf "%s\\n" "$*" >> "$MOCK_LOG"\n')
        executable(base / "sleep", "#!/bin/sh\nexec /bin/sleep 2\n")
        env = os.environ.copy()
        env.update({
            "PATH": f"{base}:{env.get('PATH', '')}",
            "SLEEP_MY_SWEETIE_SHUTDOWN": str(mock),
            "SLEEP_MY_SWEETIE_TEST_MODE": "1",
            "SLEEP_MY_SWEETIE_RUNTIME_DIR": str(base / "no-bus"),
            "MOCK_LOG": str(log),
        })
        (base / "no-bus").mkdir()
        env.pop("SUDO_USER", None)
        process = subprocess.Popen(
            ["sh", str(COMMAND)], cwd=ROOT, env=env, text=True,
            stdout=subprocess.PIPE, stderr=subprocess.STDOUT, start_new_session=True,
        )
        try:
            deadline = time.monotonic() + 5
            output = ""
            while time.monotonic() < deadline and "5..." not in output:
                char = process.stdout.read(1)
                if not char:
                    break
                output += char
            assert "5..." in output, f"Countdown did not start: {output}"
            os.killpg(process.pid, signal.SIGINT)
            tail, _ = process.communicate(timeout=5)
            output += tail
            assert process.returncode != 0, "SIGINT did not cancel the command"
            assert not log.exists(), "shutdown ran after cancellation"
        finally:
            if process.poll() is None:
                os.killpg(process.pid, signal.SIGKILL)
                process.wait(timeout=5)


def test_install_reinstall_conflicts_and_uninstall():
    with tempfile.TemporaryDirectory() as directory:
        base = pathlib.Path(directory)
        prefix = base / "prefix"
        env = os.environ.copy()
        env.update({"PREFIX": str(prefix), "SLEEP_MY_SWEETIE_SHUTDOWN": "/bin/true"})

        run(["sh", str(INSTALLER)], env)
        installed = prefix / "lib/sleep-my-sweetie/sleep_my_sweetie"
        marker = prefix / "lib/sleep-my-sweetie/.sleep-my-sweetie-managed"
        assert installed.is_file() and marker.is_file()
        for name in ALIASES:
            link = prefix / "bin" / name
            assert link.is_symlink() and os.readlink(link) == str(installed)

        run(["sh", str(INSTALLER)], env)  # Idempotent reinstall.

        conflict_prefix = base / "conflict"
        conflict_bin = conflict_prefix / "bin"
        conflict_bin.mkdir(parents=True)
        protected = conflict_bin / "goodnight_my_love"
        protected.write_text("do not overwrite\n", encoding="utf-8")
        conflict_env = env.copy()
        conflict_env["PREFIX"] = str(conflict_prefix)
        result = run(["sh", str(INSTALLER)], conflict_env, check=False)
        assert result.returncode != 0
        assert protected.read_text(encoding="utf-8") == "do not overwrite\n"

        unmanaged_prefix = base / "unmanaged"
        unmanaged_dir = unmanaged_prefix / "lib/sleep-my-sweetie"
        unmanaged_dir.mkdir(parents=True)
        protected_file = unmanaged_dir / "important.txt"
        protected_file.write_text("keep me\n", encoding="utf-8")
        unmanaged_env = env.copy()
        unmanaged_env["PREFIX"] = str(unmanaged_prefix)
        result = run(["sh", str(INSTALLER)], unmanaged_env, check=False)
        assert result.returncode != 0
        assert protected_file.read_text(encoding="utf-8") == "keep me\n"

        unrelated = prefix / "bin" / "my_unrelated_command"
        unrelated.write_text("keep this\n", encoding="utf-8")
        run(["sh", str(UNINSTALLER)], env)
        assert not installed.exists() and not marker.exists()
        for name in ALIASES:
            assert not (prefix / "bin" / name).exists()
        assert unrelated.read_text(encoding="utf-8") == "keep this\n"


def main():
    cases = (
        test_help_and_arguments,
        test_dry_run_never_calls_shutdown,
        test_normal_flow_uses_mock_shutdown,
        test_gnome_session_poweroff_uses_desktop_user_bus,
        test_ctrl_c_cancels_before_shutdown,
        test_install_reinstall_conflicts_and_uninstall,
    )
    for case in cases:
        case()
        print(f"PASS: {case.__name__}")
    print(f"\nAll {len(cases)} test groups passed. No real shutdown was performed.")


if __name__ == "__main__":
    main()
