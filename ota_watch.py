#!/usr/bin/env python3
"""Watch a Hisense TV for an OTA payload and copy it to this Mac over SSH."""

from __future__ import annotations

import os
from pathlib import Path
import shlex
import subprocess
import time


TV = os.environ.get("HACKTV_IP", "192.168.1.21")
KEY = Path("/Users/cmunaro/.ssh/id_rsa")
DEST = Path("/Users/cmunaro/HackTv/ota-downloads")
POLL_SECONDS = 2
STABLE_POLLS = 5
MIN_PAYLOAD_SIZE = 1_000_000

SSH = [
    "ssh", "-T", "-o", "BatchMode=yes", "-o", "ConnectTimeout=10",
    "-p", "2222", "-i", str(KEY), f"root@{TV}",
]

SNAPSHOT_COMMAND = (
    "find /OAD /var/local/upgrade -maxdepth 5 -type f "
    "-exec stat -c '%n|%s|%Y' {} \\; 2>/dev/null"
)


def remote(command: str, *, capture: bool = True) -> subprocess.CompletedProcess[bytes]:
    return subprocess.run(
        SSH + [command],
        stdout=subprocess.PIPE if capture else None,
        stderr=subprocess.PIPE if capture else None,
        check=False,
    )


def snapshot() -> dict[str, tuple[int, int]]:
    result = remote(SNAPSHOT_COMMAND)
    if result.returncode != 0:
        error = result.stderr.decode("utf-8", "replace").strip()
        raise RuntimeError(f"TV snapshot failed: {error}")

    files: dict[str, tuple[int, int]] = {}
    for raw_line in result.stdout.decode("utf-8", "replace").splitlines():
        try:
            name, size, modified = raw_line.rsplit("|", 2)
            files[name] = (int(size), int(modified))
        except ValueError:
            continue
    return files


def safe_destination(remote_path: str) -> Path:
    name = Path(remote_path).name or "firmware.bin"
    candidate = DEST / name
    counter = 1
    while candidate.exists() or candidate.with_suffix(candidate.suffix + ".part").exists():
        candidate = DEST / f"{Path(name).stem}-{counter}{Path(name).suffix}"
        counter += 1
    return candidate


def download(remote_path: str, expected_size: int) -> Path:
    DEST.mkdir(parents=True, exist_ok=True)
    destination = safe_destination(remote_path)
    partial = destination.with_suffix(destination.suffix + ".part")
    print(f"Copying {remote_path} ({expected_size} bytes) -> {destination}", flush=True)

    with partial.open("wb") as output:
        result = subprocess.run(
            SSH + [f"cat {shlex.quote(remote_path)}"],
            stdout=output,
            stderr=subprocess.PIPE,
            check=False,
        )
    if result.returncode != 0:
        error = result.stderr.decode("utf-8", "replace").strip()
        raise RuntimeError(f"copy failed, partial retained at {partial}: {error}")

    actual_size = partial.stat().st_size
    current = snapshot().get(remote_path)
    if actual_size != expected_size or current is None or current[0] != expected_size:
        raise RuntimeError(
            f"payload changed during copy (expected {expected_size}, copied {actual_size}); "
            f"partial retained at {partial}"
        )
    partial.replace(destination)
    print(f"Saved complete OTA payload: {destination} ({actual_size} bytes)", flush=True)
    return destination


def main() -> int:
    baseline = snapshot()
    print(f"Watching {TV}: /OAD and /var/local/upgrade", flush=True)
    print(f"Baselined {len(baseline)} existing files. Trigger Check for updates now.", flush=True)

    stability: dict[str, tuple[int, int]] = {}
    while True:
        try:
            current = snapshot()
        except RuntimeError as exc:
            print(exc, flush=True)
            time.sleep(POLL_SECONDS)
            continue

        for path, (size, modified) in current.items():
            old = baseline.get(path)
            if size < MIN_PAYLOAD_SIZE or (old is not None and old == (size, modified)):
                stability.pop(path, None)
                continue

            previous_size, count = stability.get(path, (-1, 0))
            count = count + 1 if size == previous_size else 0
            stability[path] = (size, count)
            print(f"Candidate: {path} size={size} stable={count}/{STABLE_POLLS}", flush=True)
            if count >= STABLE_POLLS:
                destination = download(path, size)
                digest = subprocess.run(
                    ["shasum", "-a", "256", str(destination)],
                    check=False,
                    text=True,
                    capture_output=True,
                ).stdout.strip()
                if digest:
                    print(digest, flush=True)
                return 0

        time.sleep(POLL_SECONDS)


if __name__ == "__main__":
    raise SystemExit(main())
