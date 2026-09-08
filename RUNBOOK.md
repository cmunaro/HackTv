# Root-preserving VIDAA OTA runbook

## 1. Hardware and partition model

Device: Hisense 58A7140F, MSD6886EUU4 platform.

Relevant eMMC partitions:

| Partition | Device | Size | Role |
|---|---:|---:|---|
| KL | `/dev/mmcblk0p7` | 16 MiB | kernel A |
| KLB | `/dev/mmcblk0p8` | 16 MiB | kernel B |
| RFS | `/dev/mmcblk0p9` | 36 MiB | rootfs A |
| RFSB | `/dev/mmcblk0p10` | 36 MiB | rootfs B |
| optee | `/dev/mmcblk0p11` | 6 MiB | OP-TEE A |
| opteeB | `/dev/mmcblk0p12` | 6 MiB | OP-TEE B |
| armfw | `/dev/mmcblk0p13` | 64 KiB | ARM firmware A |
| armfwB | `/dev/mmcblk0p14` | 64 KiB | ARM firmware B |
| bootflag | `/dev/mmcblk0p4` | 4 KiB | selected/prepared slot state |
| OAD | `/dev/mmcblk0p37` | 1000 MiB | OTA download storage |

Slot mapping seen in `/proc/cmdline`:

- `bootflag=0 root=/dev/mmcblk0p9`: slot A
- `bootflag=1 root=/dev/mmcblk0p10`: slot B

## 2. Why the method works

The official updater authenticates and stages the next system into the
inactive slot while the current rootfs remains mounted read-only and running.
At the `Restart now` prompt, the inactive kernel, rootfs, and OP-TEE already
match the files in the official OTA ZIP and the boot flag is prepared.

We keep the official staged kernel and OP-TEE unchanged and replace only the
inactive SquashFS rootfs with a version-matched rooted SquashFS. The normal
updater then performs its standard slot transition.

## 3. Rootfs modifications

Each rooted rootfs contains only these intentional changes:

- root login shell changed from missing `/bin/bash` to `/bin/sh`;
- static ARM EABI5 musl Dropbear and Dropbearkey under `/usr/sbin`;
- the user's public key at `/root/.ssh/authorized_keys`;
- `/etc/init.d/hacktv_ssh.sh` creates a persistent host key, opens TCP 2222,
  and starts key-only Dropbear;
- the service is launched in `rcS` after the stock firewall script;
- `/etc/profile` returns early for SSH sessions to avoid replaying boot logic.

Password login and SSH forwarding are disabled. The final images make no HTTP
callbacks and do not depend on the Mac probe server.

SquashFS parameters copied from every official image:

```text
SquashFS 4.0, gzip, block size 131072, exportable, no packed tailends,
compressed metadata/fragments/xattrs/ids, all files owned by root
```

Representative build command:

```sh
mksquashfs rootfs rootfs-rooted.img \
  -comp gzip -b 131072 -no-tailends -all-root -noappend
```

## 4. Procedure for a future OTA

1. From the current rooted firmware, inspect
   `/var/local/upgrade/check_version_result_data.xml` to record version, URL,
   advertised MD5, and release date. Redact tokens from any other XML.
2. Do not start the TV download yet. Download the official ZIP to the Mac,
   verify its advertised MD5 and `unzip -t`, and save its SHA-256.
3. Extract `update_list.ini`, split manifests, and `rootfs`. Verify every
   internal MD5 and size.
4. Create a new isolated `<VERSION>-rooted/` directory.
5. Unsquash the new official rootfs. Apply only the six modifications listed
   above, using the proven static binaries and the user's public key.
6. Repack with the official SquashFS parameters. Unsquash it again and verify
   contents, ownership, modes, size, MD5, and SHA-256.
7. Determine the inactive slot from `/proc/cmdline`:
   - active A means the OTA should stage B;
   - active B means the OTA should stage A.
8. Create a version-specific guarded writer. Hard-code official rootfs, kernel,
   and OP-TEE hashes from that OTA; the rooted image hash and exact byte length;
   expected active slot; and exact inactive block device.
9. Test that the writer refuses to run without its explicit arming flag.
10. Save a read-only pre-download audit of active slot, boot flag, and both
    target-slot component hashes.
11. Tell the user to download. Stop at `Restart now`.
12. Run the guarded writer. It must first prove the inactive slot contains the
    official staged release, write only that inactive rootfs, call `sync`, and
    verify a complete read-back hash.
13. Remove any `MstarUpgrade.bin` USB and let the user select `Restart now`.
14. After boot, capture `/proc/cmdline`, active rootfs hash, active kernel and
    OP-TEE hashes, bootflag bytes, Dropbear process, and installed file modes.
15. Save `PROVEN-<VERSION>-ROOT-METHOD.md`, `SHA256SUMS`, `MD5SUMS`, and
    `FROZEN.txt`; verify manifests and make the version directory read-only.

## 5. Proven release chain and hashes

### M0518

- OTA URL: `https://ota-dl.vidaahub.com/ota/MSD6886EUU4/55A56EEVS064/patch_package_entire_20220518.zip`
- OTA MD5: `a9e887a037d26c5d033f5b0f1c177a6e`
- official rootfs: `fd493146187c40070174e8173cf7139e`
- official kernel: `79e49c0d3d68caafec7affcf16e51cc4`
- official OP-TEE: `467da19dcf6dd283059e5dde01c0f742`
- rooted rootfs: `e1cf311e44b5a0a66478f4dd34c5a8c7`
- proven transition: L1103/A to M0518/B

### N0423

- OTA URL: `https://ota-dl.vidaahub.com/ota/MSD6886EUU4/43A519EEVS470/patch_package_entire_20230423.zip`
- OTA MD5: `73147cbf6050a3564fd876f4328373fe`
- official rootfs: `c1aac8845dedb53cea44222ff58f0846`
- official kernel: `05d1f325bda3757aa6fce8c1f4e91f8a`
- official OP-TEE: `4d509eb5ff3d00ea0a8259a3e946e0b9`
- rooted rootfs: `8d79fce5395ec8114c5faf1e63de48d6`
- proven transition: M0518/B to N0423/A

### P0220

- OTA URL: `https://ota-dl.vidaahub.com/ota/MSD6886EUU4/75A66EEVS430/patch_package_entire_20250220.zip`
- OTA MD5: `2bed2bea901e7e6b06f253445a3dbfe4`
- official rootfs: `f6c5078bded188e96b1dcfc2b92d612f`
- official kernel: `1fa0f9354f0bf32fbbbbdc1c883900f9`
- official OP-TEE: `5e4b003a820f5d91520567be22a5ff33`
- rooted rootfs: `ee1fa27912ca7b1237c042ead0c6cbfe`
- proven transition: N0423/A to P0220/B
- built: 2025-02-20; offered: 2025-02-26

## 6. Failure and recovery notes

- `Connection refused` means the IP responds but Dropbear is not listening.
- A timeout may mean firewall filtering or loss of LAN reachability; verify the
  current IP before diagnosing SSH.
- No HTTP probe callback is expected from final embedded-root images.
- Replacing the official ZIP at `Restart now` failed because staging had
  already completed.
- A minimal dual-RFS MStar USB image can restore a matching rooted rootfs, but
  it is not the preferred OTA method. Never use a full repartitioning USB image
  casually.
- Keep the original L1103 full USB image and all frozen version sets locally.

## 7. Local tools

- `hacktv-root`, `hacktv-shell`: no-PTY SSH helpers
- `ota-stage-audit.sh`: read-only partition/updater audit
- `mstar-bin-tool/`: integrated, locally patched MStar unpacker/packer
- `dropbear-build/`: reproducible static Dropbear/TinyALSA build material
- version directories: official/rooted hashes, guarded writers, audits, proofs

## 8. Repository and backup

Large recovery artifacts are Git LFS objects. After cloning, run
`git lfs pull`, then verify the version-specific checksum manifests. A local
commit alone is not an off-machine backup: push both Git history and LFS
objects to a trusted remote or copy the complete repository to external media.
