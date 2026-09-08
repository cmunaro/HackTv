# Static ARM Dropbear build

This container cross-compiles Dropbear for the Hisense MSD6886 ARMv7 Linux
platform. The output binaries are static so they do not depend on the TV's old
glibc version.

```sh
cd /Users/cmunaro/HackTv/dropbear-build
docker build -t hacktv-dropbear .
container=$(docker create hacktv-dropbear)
docker cp "$container:/out/." ./out
docker rm "$container"
```

Only the `dropbear` server and `dropbearkey` host-key generator are built.
The deployment starts the server with password authentication, root login,
and forwarding disabled; authentication uses the selected public key.
