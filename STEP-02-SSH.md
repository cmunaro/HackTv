# HackTV SSH update

This update installs a key-only Dropbear SSH service for the unprivileged TV
account `shell` on TCP port 2222. Root login, password authentication, agent
forwarding, and TCP forwarding are disabled.

## Before flashing

Keep this server running on the Mac at `192.168.1.17`:

```sh
cd /Users/cmunaro/HackTv
python3 mac_probe_server.py
```

The server supplies `dropbear` and `dropbearkey` during the first boot. Their
MD5 values are pinned in the TV installer. Once installed, the binaries, host
key, authorized key, and log persist in `/var/local/hacktv` and the Mac server
is no longer required on later boots.

## Update file

Copy this file to the update USB drive:

`/Users/cmunaro/HackTv/mstar-bin-tool/build/usb_MICALIDVB6886_U4_DUAL_SSH.bin`

SHA-256:

`44f1a4f5d52f8d19ce5612fe54d32dd73968f501acbf57f6ec2f6bfd20080a9d`

The update writes only `RFS` and `RFSB`.

## Connect

After the TV has booted and the Mac server shows downloads for `/dropbear` and
`/dropbearkey`, connect with:

```sh
ssh -p 2222 -i /Users/cmunaro/.ssh/id_rsa shell@192.168.1.21
```

The first connection will ask you to accept the newly generated TV host key.
The installer log is `/var/local/hacktv/ssh-install.log`.
