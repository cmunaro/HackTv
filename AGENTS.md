# Instructions for future agent sessions

## Scope and current state

This is a user-owned Hisense 58A7140F running VIDAA on MSD6886EUU4. Root SSH
was established for authorized device research. The current known-good system
is rooted P0220 on slot B (`bootflag=1`, `root=/dev/mmcblk0p10`).

## Mandatory safety rules

1. Read `RUNBOOK.md` and the relevant frozen version's `PROVEN-*.md` before
   changing firmware or partitions.
2. Treat `M0518-rooted/`, `N0423-rooted/`, and `P0220-rooted/` as immutable.
3. Start every update investigation with read-only inspection and capture a
   before-download baseline.
4. Never write the currently mounted rootfs slot.
5. Never write MBOOT, MBOOTBAK, SBOOT, GPT, kernel, OP-TEE, ARM firmware, DTB,
   calibration, certificates, model/factory data, or persistent data manually.
6. Let the official OTA updater stage its signed kernel/OP-TEE/boot components.
   Patch only the inactive staged rootfs after verifying exact official hashes.
7. A writer must fail closed unless active slot, inactive official rootfs,
   kernel, OP-TEE, local image checksum, and write length all match.
8. Read back the complete written rootfs and verify its checksum before the
   user presses `Restart now`.
9. Remove every USB containing `MstarUpgrade.bin` before an OTA reboot.
10. Never interrupt power during an update or slot transition.
11. Do not expose authentication tokens from updater XML in logs or Git.
12. Never commit private SSH keys or extracted working trees. Approved recovery
    firmware and ELF payloads are already tracked through Git LFS; add new ones
    only with checksums and explicit documentation.

The patched `mstar-bin-tool/` source is integrated into this repository. Do
not replace it with a new clone or reapply the archival patch.

## Root connection

```sh
/Users/cmunaro/HackTv/hacktv-root
```

Equivalent command:

```sh
ssh -T -p 2222 -i /Users/cmunaro/.ssh/id_rsa \
  root@192.168.1.21 '/bin/sh -i'
```

The Dropbear configuration is key-only (`-s -j -k`). The kernel lacks usable
PTY support. A regenerated, previously unseen host key is accepted by the
helper; a changed known host key is still rejected.

## Proven OTA observation

The updater downloads `/OAD/patch_package.zip` and writes the inactive A/B
kernel, rootfs, and OP-TEE during the download, before displaying
`Restart now`. Replacing the ZIP at that prompt is too late. The proven method
is to replace only the already-staged inactive rootfs, then use the normal TV
restart action.

## Editing convention

For a future release, create `/Users/cmunaro/HackTv/<VERSION>-rooted/`; never
reuse or unfreeze an older directory. Preserve the official OTA, official
rootfs, rooted rootfs, guarded writer, before-download audit, post-boot proof,
procedure, and checksum manifests in that directory, then freeze it read-only
only after successful boot verification.
