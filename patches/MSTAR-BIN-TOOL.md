# mstar-bin-tool local state

- upstream: `https://github.com/dipcore/mstar-bin-tool.git`
- base commit: `edd1a54cd5531ee98b82378ceeff9a246aced064`
- local source patch: `mstar-bin-tool-macos-hisense.patch`
- reference minimal-update config: `hisense-58a7140f-rfs-probe.ini`

The patch adds native macOS/system `lzop` discovery, fixed little-endian
32-bit CRC packing, and support for appending the Hisense vendor trailer.

The binary vendor trailer remains local at
`mstar-bin-tool/rfs-probe/hisense-vendor-trailer.bin` and is intentionally not
tracked. Its SHA-256 is
`63a33c17087651aab001b3a06eec2eedcabc4ca6b161d342af836c5ef2994f2c`.
Verify it before reuse.

To reconstruct a clean tool checkout, clone the upstream repository, check out
the base commit, and apply the patch:

```sh
git clone https://github.com/dipcore/mstar-bin-tool.git
cd mstar-bin-tool
git checkout edd1a54cd5531ee98b82378ceeff9a246aced064
git apply ../patches/mstar-bin-tool-macos-hisense.patch
```
