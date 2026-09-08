# Proven rooted P0220 method — Hisense 58A7140F

## Successful result

Verified after the official N0423-to-P0220 transition on 2026-09-08:

- active slot: B
- `bootflag=1`
- `root=/dev/mmcblk0p10`
- `otaflag=85`
- rooted P0220 RFSB MD5: `ee1fa27912ca7b1237c042ead0c6cbfe`
- official P0220 kernel MD5: `1fa0f9354f0bf32fbbbbdc1c883900f9`
- official P0220 OP-TEE MD5: `5e4b003a820f5d91520567be22a5ff33`
- key-only root Dropbear running on TCP 2222

## Proven transition

1. Begin with rooted N0423 running from slot A (`/dev/mmcblk0p9`).
2. Let the stock updater download and stage P0220 into inactive slot B.
3. Stop at the `Restart now` prompt.
4. Run `stage-rooted-p0220.sh --write-inactive-rfsb` from the Mac.
5. The helper requires:
   - N0423 active from slot A (`/dev/mmcblk0p9`);
   - official staged P0220 RFSB MD5 `f6c5078bded188e96b1dcfc2b92d612f`;
   - official staged KLB MD5 `1fa0f9354f0bf32fbbbbdc1c883900f9`;
   - official staged OP-TEEB MD5 `5e4b003a820f5d91520567be22a5ff33`;
   - local rooted image MD5 `ee1fa27912ca7b1237c042ead0c6cbfe`.
6. It writes only inactive `/dev/mmcblk0p10` and verifies the complete
   13,430,784-byte read-back hash.
7. Remove any USB containing `MstarUpgrade.bin`, then select `Restart now`.
8. Connect using `/Users/cmunaro/HackTv/hacktv-root` after P0220 boots.

The official OTA was built on 2025-02-20 and offered on 2025-02-26.
`p0220-root-postboot-proof.txt` records the successful live system state.
