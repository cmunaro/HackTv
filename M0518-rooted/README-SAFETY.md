# Hisense 58A7140F M0518 rooted OTA package

This build is based on the official `L1103_to_M0518` OTA package for
`MSD6886EUU4/55A56EEVS064`.

## Artifact

`Hisense_58A7140F_M0518_ROOT_SSH_OTA.zip`

- MD5: `97edaf9d190a0bcc72cd39fa355b9f64`
- SHA-256: `e9beaf6c27827b96b16b372350f4a58636301a969a5d4ad09b1e990c2155903e`

This is an OTA ZIP, not an MStar bootloader USB `.bin` image. Do not rename it
to `usb_MICALIDVB6886.bin` and do not feed it directly to MBOOT.

## Changes

Only `patch_package/rootfs` and its MD5/size entry in `update_list.ini` differ
from the official OTA:

- root uses `/bin/sh`, because `/bin/bash` is absent;
- static ARM Dropbear and Dropbearkey are embedded under `/usr/sbin`;
- `/root/.ssh/authorized_keys` contains the selected Mac public key;
- `/etc/init.d/hacktv_ssh.sh` starts key-only SSH on TCP 2222;
- `rcS` starts that service after the stock firewall;
- `/etc/profile` does not replay boot initialization during SSH sessions.

Password login and SSH forwarding remain disabled. The SSH server does not
need the Mac HTTP probe server.

## Verified

- The ZIP passes `unzip -t`.
- The patched SquashFS is readable and uses gzip, 128 KiB blocks, no packed
  tailends, a single root UID/GID, and valid executable/key permissions.
- Patched rootfs size is 13,438,976 bytes; each live RFS/RFSB slot is
  37,748,736 bytes.
- `armfw`, `kernel`, `mboot`, `sboot`, `tee`, `usrfs`, `optfs`, `tvservice`,
  and `serialsdata` are byte-for-byte identical to the official M0518 OTA.

## Installation status

Replacing this ZIP at the `Restart now` prompt was proven to be too late: the
official updater had already staged M0518 into the inactive B partitions.
This ZIP is retained as an archival build and is not the proven installation
mechanism. See `PROVEN-M0518-ROOT-METHOD.md` and use the guarded
`stage-rooted-m0518.sh` procedure instead.

After a successful installation, connect without requesting a PTY:

```sh
ssh -T -p 2222 -i /Users/cmunaro/.ssh/id_rsa root@192.168.1.21 '/bin/sh -i'
```
