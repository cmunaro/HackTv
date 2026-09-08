# Step 1: unprivileged HTTP callback

## Confirmed firmware layout

- Platform: MStar MSD6886 / ARM EABI5.
- Root filesystem: the `RFS` SquashFS partition.
- Guaranteed startup script: `/etc/init.d/rcS` inside `RFS`.
- Runtime-persistent storage: `/var/local` (ext4, read/write).
- BusyBox provides `/usr/bin/wget` and `/bin/su`.
- The existing unprivileged account `shell` has UID/GID 2000.

For the first test, attach the probe to `/etc/init.d/rcS` after
`/usr/local/scripts/start-firewall.sh`. The future firmware patch will add:

```sh
/bin/su shell -c '/usr/bin/wget -T 10 -q -O /tmp/hacktv-probe-response http://192.168.1.17:8000/hacktv-probe?stage=user-level' &
```

This only performs an outbound HTTP GET as the unprivileged `shell` user. It
does not expose a listening port on the TV.

## Start the listener on the Mac

From Terminal:

```sh
cd /Users/cmunaro/HackTv
python3 mac_probe_server.py
```

macOS may ask whether Python may accept incoming connections. Allow it on the
private network. Keep the terminal open while booting the modified firmware.

Expected output after the TV boots:

```text
GET /hacktv-probe?stage=user-level from <TV-IP>
```

The Mac currently has LAN address `192.168.1.17`. If that address changes,
the firmware probe target must be updated before building the image.

## Why this attachment point

`/var/local` is writable and persistent, but the inspected root filesystem has
no guaranteed hook that executes an arbitrary file from there. Editing `rcS`
is the smallest deterministic test. Once execution is confirmed, `rcS` can be
reduced to a launcher while the changeable payload and SSH state live under
`/var/local/hacktv/`.
