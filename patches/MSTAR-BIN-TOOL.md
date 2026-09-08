# Integrated mstar-bin-tool

- upstream: `https://github.com/dipcore/mstar-bin-tool.git`
- upstream base: `edd1a54cd5531ee98b82378ceeff9a246aced064`
- former local tool commit: `d4aaba5`
- archival source patch: `mstar-bin-tool-macos-hisense.patch`
- reference configuration: `hisense-58a7140f-rfs-probe.ini`

The patch adds native macOS/system `lzop` discovery, fixed little-endian
32-bit CRC packing, and support for appending the Hisense vendor trailer.

The working source is committed directly at `mstar-bin-tool/` with these
changes already applied. Do not clone over it or apply the archival patch a
second time. The required binary vendor trailer is tracked through Git LFS at
`artifacts/hisense-vendor-trailer.bin`. Its SHA-256 is
`63a33c17087651aab001b3a06eec2eedcabc4ca6b161d342af836c5ef2994f2c`.
Verify it before reuse.

After cloning the HackTv repository, install the native dependencies and use
the integrated scripts directly:

```sh
brew install lzop squashfs
cd mstar-bin-tool
python3 unpack.py ../usb_MICALIDVB6886_U4.bin
```

Generated `build/`, `unpacked/`, and extracted filesystem trees remain
untracked. The patch and configuration under `patches/` are retained only as
provenance and emergency reconstruction material.

The upstream `default_keys/` directory is deliberately excluded because it
contains example private signing and symmetric encryption keys. Those keys are
not required by the proven Hisense unpack/repack workflow and must not be
published in this repository.
