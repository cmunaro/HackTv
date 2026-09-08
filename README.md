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

The primary recovery payload hashes are in `RECOVERY-SHA256SUMS`.

Recovery-critical firmware files are committed through Git LFS. The patched
`mstar-bin-tool/` source is integrated directly, so no secondary clone or
patch step is required. A clone is not a complete backup until `git lfs pull`
succeeds and the LFS objects are also present on the remote or backup medium.

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
- `L1103-rooted/` (downgrade/root recovery)

Never edit a frozen set in place. Copy the required inputs into a new
version-specific directory.
