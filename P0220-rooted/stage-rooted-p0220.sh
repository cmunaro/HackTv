#!/bin/sh
# Safety-gated Mac-side writer for N0423/A -> rooted P0220/B.
set -eu

TV_IP="${TV_IP:-192.168.1.21}"
SSH_KEY="${SSH_KEY:-/Users/cmunaro/.ssh/id_rsa}"
ROOTFS="${ROOTFS:-/Users/cmunaro/HackTv/P0220-rooted/rootfs-rooted-p0220.img}"
EXPECTED_LOCAL_MD5=ee1fa27912ca7b1237c042ead0c6cbfe
EXPECTED_RFSB_OFFICIAL=f6c5078bded188e96b1dcfc2b92d612f
EXPECTED_KLB=1fa0f9354f0bf32fbbbbdc1c883900f9
EXPECTED_OPTEEB=5e4b003a820f5d91520567be22a5ff33

if [ "${1:-}" != "--write-inactive-rfsb" ]; then
    echo "Refusing: pass --write-inactive-rfsb only at the P0220 'Restart now' prompt." >&2
    exit 2
fi

test -f "$ROOTFS"
local_md5="$(md5 -q "$ROOTFS")"
test "$local_md5" = "$EXPECTED_LOCAL_MD5" || {
    echo "Refusing: rooted P0220 image MD5 is $local_md5" >&2; exit 3;
}

ssh_base="ssh -T -o BatchMode=yes -o StrictHostKeyChecking=yes -p 2222 -i $SSH_KEY root@$TV_IP"
cmdline="$($ssh_base 'cat /proc/cmdline')"
case "$cmdline" in
    *'bootflag=0'*'root=/dev/mmcblk0p9'*) ;;
    *) echo "Refusing: TV is not running N0423 from slot A: $cmdline" >&2; exit 4 ;;
esac

hashes="$($ssh_base '
    dd if=/dev/mmcblk0p10 bs=13148160 count=1 2>/dev/null | md5sum
    dd if=/dev/mmcblk0p8  bs=9027544  count=1 2>/dev/null | md5sum
    dd if=/dev/mmcblk0p12 bs=2190608  count=1 2>/dev/null | md5sum
')"

echo "$hashes" | sed -n '1p' | grep -q "^$EXPECTED_RFSB_OFFICIAL " || {
    echo "Refusing: RFSB is not the officially staged P0220 rootfs." >&2; exit 5;
}
echo "$hashes" | sed -n '2p' | grep -q "^$EXPECTED_KLB " || {
    echo "Refusing: KLB is not the official P0220 kernel." >&2; exit 6;
}
echo "$hashes" | sed -n '3p' | grep -q "^$EXPECTED_OPTEEB " || {
    echo "Refusing: opteeB is not the official P0220 OP-TEE." >&2; exit 7;
}

echo "All guards passed; writing only inactive /dev/mmcblk0p10 (RFSB)."
$ssh_base 'dd of=/dev/mmcblk0p10 bs=1048576; sync' < "$ROOTFS"
written_md5="$($ssh_base 'dd if=/dev/mmcblk0p10 bs=13430784 count=1 2>/dev/null | md5sum' | awk '{print $1}')"
test "$written_md5" = "$EXPECTED_LOCAL_MD5" || {
    echo "FATAL: RFSB read-back MD5 is $written_md5; do not restart." >&2; exit 8;
}
echo "Verified rooted P0220 RFSB: $written_md5"
echo "Remove any MstarUpgrade USB, then use the TV's Restart now button."
