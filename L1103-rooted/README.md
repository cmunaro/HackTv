# L1103 recovery set

This directory preserves the proven minimal dual-rootfs USB patch used to
restore root SSH on L1103 and the rooted SquashFS embedded in it.

- Flash the original `usb_MICALIDVB6886_U4.bin` first when a full downgrade is
  required.
- Then flash `usb_MICALIDVB6886_U4_L1103_DUAL_ROOT_SSH.bin`.
- The patch is model-specific to the Hisense 58A7140F / MSD6886EUU4.

Verify `SHA256SUMS` before use. Do not substitute these files for another TV or
firmware family.
