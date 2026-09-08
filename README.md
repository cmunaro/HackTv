# Hisense 58A7140F VIDAA research workspace

This repository documents a successfully reproduced, key-only root SSH path
across the official firmware chain:

```text
L1103 -> M0518 -> N0423 -> P0220
```

Current proven state (2026-09-08): P0220 boots from slot B
(`/dev/mmcblk0p10`) with Dropbear listening on TCP 2222 as root.

Start with [RUNBOOK.md](RUNBOOK.md). Agent-specific safety and workspace rules
are in [AGENTS.md](AGENTS.md).

Large firmware files remain on the local disk but are deliberately excluded
from Git. Their checksum manifests and the scripts that produced/installed
them are versioned.

## Quick access

```sh
./hacktv-root
```

The TV kernel has no usable PTY support, so the helper uses `ssh -T` and
`/bin/sh -i`.

## Frozen known-good sets

- `M0518-rooted/`
- `N0423-rooted/`
- `P0220-rooted/`

Never edit a frozen set in place. Copy the required inputs into a new
version-specific directory.

