# Proven rooted N0423 method — Hisense 58A7140F

## Successful result

Verified after the official M0518-to-N0423 transition on 2026-09-08:

- active slot: A
- `bootflag=0`
- `root=/dev/mmcblk0p9`
- `otaflag=85`
- rooted N0423 RFS MD5: `8d79fce5395ec8114c5faf1e63de48d6`
- official N0423 kernel MD5: `05d1f325bda3757aa6fce8c1f4e91f8a`
- official N0423 OP-TEE MD5: `4d509eb5ff3d00ea0a8259a3e946e0b9`
- key-only root Dropbear running on TCP 2222

## Proven transition

1. Begin with rooted M0518 running from slot B (`/dev/mmcblk0p10`).
2. Let the stock updater download and stage N0423.
3. Stop at the `Restart now` prompt.
4. Run `stage-rooted-n0423.sh --write-inactive-rfs` from the Mac.
5. The helper requires all of the following before writing:
   - M0518 is active from slot B;
   - inactive RFS contains official staged N0423 MD5
     `c1aac8845dedb53cea44222ff58f0846`;
   - inactive KL contains official N0423 kernel MD5
     `05d1f325bda3757aa6fce8c1f4e91f8a`;
   - inactive OP-TEE contains official N0423 MD5
     `4d509eb5ff3d00ea0a8259a3e946e0b9`;
   - local rooted image MD5 is `8d79fce5395ec8114c5faf1e63de48d6`.
6. It writes only inactive `/dev/mmcblk0p9`, then reads back exactly
   13,430,784 bytes and verifies the rooted MD5.
7. Remove any USB containing `MstarUpgrade.bin` and select `Restart now`.
8. After N0423 boots, connect using `/Users/cmunaro/HackTv/hacktv-root`.

## Recovery

The frozen `/Users/cmunaro/HackTv/M0518-rooted` and earlier L1103 artifacts
remain independent recovery paths. The N0423 operation never modifies those
files.

`n0423-root-postboot-proof.txt` records the successful live system state.
