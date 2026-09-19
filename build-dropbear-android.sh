#!/bin/bash
set -e
set -x
VERSION=2018.76
PREFIX=/tmp/dropbear-android
HOST=arm-linux-androideabi
export TOOLCHAIN="$TOOLCHAIN"
export PATH="$TOOLCHAIN/bin:$PATH"
# Android bionic libc static stderr fix
EXTRA_CFLAGS="-Dstderr=__stderrp -Dstdout=__stdoutp -Dstdin=__stdinp"
echo "=== Download dropbear source ==="
# Download the latest version of dropbear SSH
if [ ! -f ./dropbear-$VERSION.tar.bz2 ]; then
    wget -O ./dropbear-$VERSION.tar.bz2 https://matt.ucc.asn.au/dropbear/releases/dropbear-$VERSION.tar.bz2
fi
echo "=== Extract source ==="
tar -xjf dropbear-${VERSION}.tar.bz2
echo "=== Apply patch ==="
cd dropbear-${VERSION}
patch -p1 -N --no-backup < ../android-compat.patch
cd -
echo "=== Run configure ==="
cd dropbear-${VERSION}
./configure \
  --host=${HOST} \
  --prefix=${PREFIX} \
  --disable-zlib \
  --enable-static \
  --disable-shadow \
  --disable-utmp \
  --disable-pty \
  --disable-syslog \
  --disable-lastlog \
  --disable-client \
  CFLAGS="${EXTRA_CFLAGS} -Os"
echo "=== Start make ==="
make -j$(nproc)
make install
echo "=== Copy binaries ==="
mkdir -p ../target/arm
cp ${PREFIX}/sbin/dropbear ../target/arm/
cp ${PREFIX}/bin/dropbearkey ../target/arm/
echo "=== Strip ==="
${HOST}-strip ../target/arm/dropbear
${HOST}-strip ../target/arm/dropbearkey
echo "Build done, binaries in target/arm/"
ls -lh ../target/arm/
