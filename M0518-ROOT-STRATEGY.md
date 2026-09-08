# M0518 root strategy

1. Restore full L1103, then restore the known-working L1103 root SSH image.
2. Run `ota-stage-audit.sh` before starting the M0518 download.
3. Start the official download and run the audit again while it is active.
4. At the `Restart now` prompt, do not restart. Run the audit a third time.
5. Compare KL/KLB, RFS/RFSB, OP-TEE A/B, ARM firmware A/B, bootflag, updater
   state, and `/OAD` across the three snapshots.

Decision:

- If the inactive rootfs already matches official M0518 at the prompt, patch
  only that inactive rootfs after proving the boot-slot transition.
- If partitions are unchanged but the package has already been unpacked into
  another staging area, patch that staging copy and its manifest.
- If only `/OAD/patch_package.zip` exists and is not unpacked, replace it before
  the updater marks the download complete, then let the updater validate the
  rooted package normally.

Do not write any partition until its active/inactive role and the updater's
subsequent behavior are proven by the snapshots.
