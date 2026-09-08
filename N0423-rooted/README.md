# Rooted N0423 preparation — Hisense 58A7140F

This directory is independent of the frozen, working `M0518-rooted` recovery
set. Nothing in that directory is modified.

## Official update

- transition: `M0518-N0423`
- OTA ZIP MD5: `73147cbf6050a3564fd876f4328373fe`
- OTA ZIP SHA-256: `29d45fbe77f47ca00507cabdd567c36e3e719f35a42a1ad329ce51ae35ebcfe2`
- official N0423 rootfs MD5: `c1aac8845dedb53cea44222ff58f0846`
- official kernel MD5: `05d1f325bda3757aa6fce8c1f4e91f8a`
- official OP-TEE MD5: `4d509eb5ff3d00ea0a8259a3e946e0b9`

## Rooted rootfs

- length: `13,430,784` bytes
- MD5: `8d79fce5395ec8114c5faf1e63de48d6`
- SHA-256: `d1fff40655a06dbf927f497a6f00dc4c43c838f5c5549b9f61d009e0d1c593ed`

The expected transition is from active M0518 slot B (`mmcblk0p10`) to inactive
N0423 slot A (`mmcblk0p9`). At the `Restart now` prompt, run:

```sh
/Users/cmunaro/HackTv/N0423-rooted/stage-rooted-n0423.sh --write-inactive-rfs
```

The helper refuses to write unless the current slot and the staged official
N0423 RFS, kernel, and OP-TEE hashes all match.
