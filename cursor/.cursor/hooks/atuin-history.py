#!/usr/bin/env python3
"""Record Cursor shell tool calls in Atuin history."""

import hashlib
import json
import os
import pathlib
import shutil
import subprocess
import sys
import tempfile


def emit(value):
    sys.stdout.write(json.dumps(value) + "\n")


def atuin_path():
    binary = shutil.which("atuin")
    if binary:
        return binary
    fallback = pathlib.Path.home() / ".atuin" / "bin" / "atuin"
    return str(fallback) if fallback.is_file() else None


def read_payload():
    try:
        return json.load(sys.stdin)
    except Exception:
        return {}


def state_file(tool_use_id):
    state_home = pathlib.Path(
        os.environ.get("XDG_STATE_HOME", pathlib.Path.home() / ".local" / "state")
    )
    directory = state_home / "atuin" / "cursor-hooks"
    directory.mkdir(parents=True, exist_ok=True, mode=0o700)
    os.chmod(directory, 0o700)
    digest = hashlib.sha256(tool_use_id.encode()).hexdigest()
    return directory / digest


def start(payload, atuin):
    tool_input = payload.get("tool_input") or {}
    command = tool_input.get("command")
    tool_use_id = payload.get("tool_use_id")
    cwd = tool_input.get("working_directory") or payload.get("cwd")
    if not command or not tool_use_id or not cwd or not pathlib.Path(cwd).is_dir():
        return

    intent = payload.get("agent_message") or "Cursor agent shell command"
    intent = " ".join(str(intent).split())[:240]
    result = subprocess.run(
        [
            atuin,
            "history",
            "start",
            "--author",
            "cursor",
            "--author-kind",
            "agent",
            "--intent",
            intent,
            "--",
            command,
        ],
        cwd=cwd,
        capture_output=True,
        text=True,
        check=False,
    )
    history_id = result.stdout.strip()
    if not history_id or result.returncode != 0:
        return

    destination = state_file(tool_use_id)
    with tempfile.NamedTemporaryFile(
        mode="w", encoding="utf-8", dir=destination.parent, delete=False
    ) as temporary:
        temporary.write(history_id)
        temporary_path = temporary.name
    os.chmod(temporary_path, 0o600)
    os.replace(temporary_path, destination)


def finish(payload, atuin, failed):
    tool_use_id = payload.get("tool_use_id")
    if not tool_use_id:
        return

    destination = state_file(tool_use_id)
    try:
        history_id = destination.read_text(encoding="utf-8").strip()
    except OSError:
        return

    if failed:
        failure_type = payload.get("failure_type")
        exit_code = 124 if failure_type == "timeout" else 1
    else:
        output = payload.get("tool_output", "")
        try:
            result = json.loads(output) if isinstance(output, str) else output
            exit_code = int(result.get("exitCode", result.get("exit_code", 0)))
        except (TypeError, ValueError, json.JSONDecodeError):
            exit_code = 0

    duration_ms = payload.get("duration")
    args = [atuin, "history", "end", "--exit", str(exit_code)]
    if isinstance(duration_ms, (int, float)):
        args.extend(["--duration", str(max(0, int(duration_ms * 1_000_000)))])
    args.append(history_id)
    subprocess.run(args, capture_output=True, check=False)
    destination.unlink(missing_ok=True)


def main():
    mode = sys.argv[1] if len(sys.argv) > 1 else ""
    payload = read_payload()
    atuin = atuin_path()
    if atuin:
        try:
            if mode == "start":
                start(payload, atuin)
            elif mode == "end":
                finish(payload, atuin, failed=False)
            elif mode == "failure":
                finish(payload, atuin, failed=True)
        except Exception:
            pass

    emit({"permission": "allow"} if mode == "start" else {})


if __name__ == "__main__":
    main()
