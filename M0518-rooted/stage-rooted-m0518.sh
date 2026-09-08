#!/bin/sh
# Safety-gated Mac-side helper for the proven L1103 -> rooted M0518 method.

set -eu

TV_IP="${TV_IP:-192.168.1.21}"
SSH_KEY="${SSH_KEY:-/Users/cmunaro/.ssh/id_rsa}"
ROOTFS="${ROOTFS:-/Users/cmunaro/HackTv/M0518-rooted/rootfs-rooted.img}"
ARMED="${1:-}"

EXPECTED_LOCAL_MD5=e1cf311e44b5a0a66478f4dd34c5a8c7
EXPECTED_RFSB_OFFICIAL=fd493146187c40070174e8173cf7139e
EXPECTED_KLB=79e49c0d3d68caafec7affcf16e51cc4
EXPECTED_OPTEEB=467da19dcf6dd283059e5dde01c0f742

if [ "$ARMED" != "--write-inactive-rfsb" ]; then
    echo "Audit-only refusal: pass --write-inactive-rfsb only at the M0518 'Restart now' prompt." >&2
    exit 2
fi

test -f "$ROOTFS"
local_md5="$(md5 -q "$ROOTFS")"
test "$local_md5" = "$EXPECTED_LOCAL_MD5" || {
    echo "Refusing: local rooted image MD5 is $local_md5" >&2
    exit 3
}

ssh_base="ssh -T -o BatchMode=yes -o StrictHostKeyChecking=yes -p 2222 -i $SSH_KEY root@$TV_IP"

cmdline="$($ssh_base 'cat /proc/cmdline')"
case "$cmdline" in
    *'bootflag=0'*'root=/dev/mmcblk0p9'*) ;;
    *) echo "Refusing: TV is not running slot A/L1103: $cmdline" >&2; exit 4 ;;
esac

remote_hashes="$($ssh_base '
    dd if=/dev/mmcblk0p10 bs=13156352 count=1 2>/dev/null | md5sum
    dd if=/dev/mmcblk0p8  bs=9027544  count=1 2>/dev/null | md5sum
    dd if=/dev/mmcblk0p12 bs=2190608  count=1 2>/dev/null | md5sum
')"

echo "$remote_hashes" | sed -n '1p' | grep -q "^$EXPECTED_RFSB_OFFICIAL " || {
    echo "Refusing: RFSB is not the officially staged M0518 rootfs." >&2; exit 5;
}
echo "$remote_hashes" | sed -n '2p' | grep -q "^$EXPECTED_KLB " || {
    echo "Refusing: KLB is not the official M0518 kernel." >&2; exit 6;
}
echo "$remote_hashes" | sed -n '3p' | grep -q "^$EXPECTED_OPTEEB " || {
    echo "Refusing: opteeB is not the official M0518 OP-TEE." >&2; exit 7;
}

echo "All guards passed; writing only inactive /dev/mmcblk0p10 (RFSB)."
$ssh_base 'dd of=/dev/mmcblk0p10 bs=1048576; sync' < "$ROOTFS"

written_md5="$($ssh_base 'dd if=/dev/mmcblk0p10 bs=13438976 count=1 2>/dev/null | md5sum' | awk '{print $1}')"
test "$written_md5" = "$EXPECTED_LOCAL_MD5" || {
    echo "FATAL: RFSB read-back MD5 is $written_md5; do not restart." >&2
    exit 8
}

echo "Verified rooted M0518 RFSB: $written_md5"
echo "Remove any MstarUpgrade USB, then use the TV's Restart now button."
