# Proven rooted M0518 method — Hisense 58A7140F

## Result

Successfully booted rooted M0518 on 2026-09-08:

- `bootflag=1`
- `root=/dev/mmcblk0p10` (`RFSB`)
- `otaflag=85`
- rooted RFSB MD5: `e1cf311e44b5a0a66478f4dd34c5a8c7`
- key-only Dropbear running as root on TCP 2222

## Why replacing the ZIP failed

The TV stages the complete B boot set during the download, before displaying
`Restart now`. Replacing `/OAD/patch_package.zip` at that prompt is too late.

The before/after audits proved that the download phase changed:

- `KLB` to official M0518 kernel `79e49c0d3d68caafec7affcf16e51cc4`
- `RFSB` to official M0518 rootfs `fd493146187c40070174e8173cf7139e`
- `opteeB` to official M0518 OP-TEE `467da19dcf6dd283059e5dde01c0f742`
- the boot flag from the A state to the prepared B/reboot state

The active `RFS`/slot A remained untouched.

## Proven procedure

1. Run rooted L1103 from slot A (`bootflag=0`, `/dev/mmcblk0p9`).
2. Check for M0518 and start the official download.
3. At `Restart now`, do not restart yet.
4. Confirm the inactive B hashes using `ota-stage-audit.sh`.
5. Write `rootfs-rooted.img` only to inactive `/dev/mmcblk0p10`.
6. Read back exactly 13,438,976 bytes and require MD5
   `e1cf311e44b5a0a66478f4dd34c5a8c7`.
7. Remove any USB containing `MstarUpgrade.bin`.
8. Select `Restart now` and allow the official update transition to finish.
9. Connect without a PTY using `hacktv-root`.

For repeatability, `stage-rooted-m0518.sh` implements steps 4–6 and refuses to
write unless the active slot and all three official staged B hashes match.

## Files

- `rootfs-rooted.img`: rooted M0518 SquashFS
- `ota-stage-audit.sh`: read-only A/B staging audit
- `stage-rooted-m0518.sh`: guarded inactive-RFSB writer
- `ota-audit-before-download.txt`: L1103/A baseline
- `ota-audit-after-download.txt`: M0518/B staged state
- `m0518-root-postboot-proof.txt`: successful rooted M0518 boot evidence
- `Hisense_58A7140F_M0518_ROOT_SSH_OTA.zip`: archival rooted OTA experiment;
  not the proven installation mechanism

## SSH

```sh
/Users/cmunaro/HackTv/hacktv-root
```

The kernel has no usable PTY support, so the helper uses `ssh -T`.
