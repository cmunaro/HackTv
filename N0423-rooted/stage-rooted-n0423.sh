#!/bin/sh
# Safety-gated Mac-side writer for M0518/B -> rooted N0423/A.

set -eu

TV_IP="${TV_IP:-192.168.1.21}"
SSH_KEY="${SSH_KEY:-/Users/cmunaro/.ssh/id_rsa}"
ROOTFS="${ROOTFS:-/Users/cmunaro/HackTv/N0423-rooted/rootfs-rooted-n0423.img}"

EXPECTED_LOCAL_MD5=8d79fce5395ec8114c5faf1e63de48d6
EXPECTED_RFS_OFFICIAL=c1aac8845dedb53cea44222ff58f0846
EXPECTED_KL=05d1f325bda3757aa6fce8c1f4e91f8a
EXPECTED_OPTEE=4d509eb5ff3d00ea0a8259a3e946e0b9

if [ "${1:-}" != "--write-inactive-rfs" ]; then
    echo "Refusing: pass --write-inactive-rfs only at the N0423 'Restart now' prompt." >&2
    exit 2
fi

test -f "$ROOTFS"
local_md5="$(md5 -q "$ROOTFS")"
test "$local_md5" = "$EXPECTED_LOCAL_MD5" || {
    echo "Refusing: rooted N0423 image MD5 is $local_md5" >&2; exit 3;
}

ssh_base="ssh -T -o BatchMode=yes -o StrictHostKeyChecking=yes -p 2222 -i $SSH_KEY root@$TV_IP"
cmdline="$($ssh_base 'cat /proc/cmdline')"
case "$cmdline" in
    *'bootflag=1'*'root=/dev/mmcblk0p10'*) ;;
    *) echo "Refusing: TV is not running M0518 from slot B: $cmdline" >&2; exit 4 ;;
esac

hashes="$($ssh_base '
    dd if=/dev/mmcblk0p9  bs=13148160 count=1 2>/dev/null | md5sum
    dd if=/dev/mmcblk0p7  bs=9027544  count=1 2>/dev/null | md5sum
    dd if=/dev/mmcblk0p11 bs=2190608  count=1 2>/dev/null | md5sum
')"

echo "$hashes" | sed -n '1p' | grep -q "^$EXPECTED_RFS_OFFICIAL " || {
    echo "Refusing: RFS is not the officially staged N0423 rootfs." >&2; exit 5;
}
echo "$hashes" | sed -n '2p' | grep -q "^$EXPECTED_KL " || {
    echo "Refusing: KL is not the official N0423 kernel." >&2; exit 6;
}
echo "$hashes" | sed -n '3p' | grep -q "^$EXPECTED_OPTEE " || {
    echo "Refusing: optee is not the official N0423 OP-TEE." >&2; exit 7;
}

echo "All guards passed; writing only inactive /dev/mmcblk0p9 (RFS)."
$ssh_base 'dd of=/dev/mmcblk0p9 bs=1048576; sync' < "$ROOTFS"

written_md5="$($ssh_base 'dd if=/dev/mmcblk0p9 bs=13430784 count=1 2>/dev/null | md5sum' | awk '{print $1}')"
test "$written_md5" = "$EXPECTED_LOCAL_MD5" || {
    echo "FATAL: RFS read-back MD5 is $written_md5; do not restart." >&2; exit 8;
}

echo "Verified rooted N0423 RFS: $written_md5"
echo "Remove any MstarUpgrade USB, then use the TV's Restart now button."
