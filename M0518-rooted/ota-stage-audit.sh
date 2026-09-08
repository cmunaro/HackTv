#!/bin/sh
# Read-only OTA/A-B state audit for Hisense 58A7140F (MSD6886).
# Run through SSH before download, while downloading, and at "Restart now".

set -u

stamp="$(date +%Y%m%d-%H%M%S)"
out="/var/local/hacktv/ota-audit-$stamp.txt"
mkdir -p /var/local/hacktv

exec >"$out" 2>&1

echo "timestamp=$(date)"
echo "cmdline=$(cat /proc/cmdline)"
echo

echo '[block-map]'
for p in /sys/class/block/mmcblk0p*; do
    name="$(sed -n 's/^PARTNAME=//p' "$p/uevent")"
    start="$(cat "$p/start" 2>/dev/null)"
    size="$(cat "$p/size" 2>/dev/null)"
    echo "${p##*/} name=$name start=$start sectors=$size"
done
echo

echo '[bootflag-first-4k]'
md5sum /dev/mmcblk0p4
dd if=/dev/mmcblk0p4 bs=4096 count=1 2>/dev/null | hexdump -C | head -20
echo

echo '[ab-image-prefixes]'
# Hash exactly each known image length, not the unused remainder of its slot.
dd if=/dev/mmcblk0p7  bs=9027544  count=1 2>/dev/null | md5sum | sed 's/-$/KL/'
dd if=/dev/mmcblk0p8  bs=9027544  count=1 2>/dev/null | md5sum | sed 's/-$/KLB/'
dd if=/dev/mmcblk0p9  bs=13156352 count=1 2>/dev/null | md5sum | sed 's/-$/RFS/'
dd if=/dev/mmcblk0p10 bs=13156352 count=1 2>/dev/null | md5sum | sed 's/-$/RFSB/'
dd if=/dev/mmcblk0p11 bs=2190608  count=1 2>/dev/null | md5sum | sed 's/-$/optee/'
dd if=/dev/mmcblk0p12 bs=2190608  count=1 2>/dev/null | md5sum | sed 's/-$/opteeB/'
dd if=/dev/mmcblk0p13 bs=58464    count=1 2>/dev/null | md5sum | sed 's/-$/armfw/'
dd if=/dev/mmcblk0p14 bs=58464    count=1 2>/dev/null | md5sum | sed 's/-$/armfwB/'
echo

echo '[oad]'
df -h /OAD
find /OAD -maxdepth 2 -type f -exec ls -ln {} \; 2>/dev/null
[ -f /OAD/patch_package.zip ] && md5sum /OAD/patch_package.zip
echo

echo '[updater-state]'
find /var/local/upgrade /tmp -maxdepth 2 -type f -exec ls -ln {} \; 2>/dev/null
for f in /var/local/upgrade/*.ini /var/local/upgrade/*.xml; do
    [ -f "$f" ] || continue
    echo "--- $f"
    # Do not copy authentication tokens into the report.
    case "$f" in *authentication*) echo '[redacted]' ;; *) cat "$f" ;; esac
done
echo

echo '[processes-and-open-files]'
ps | grep -E 'ota|upgrade' | grep -v grep
for p in /proc/[0-9]*; do
    cmd="$(tr '\000' ' ' <"$p/cmdline" 2>/dev/null)"
    case "$cmd" in
        *ota_upgrade*|*app_upgrade*)
            echo "PID=${p##*/} $cmd"
            ls -l "$p/fd" 2>/dev/null | grep -E '/OAD|/tmp|upgrade|patch|zip'
            ;;
    esac
done

echo "AUDIT_FILE=$out"
