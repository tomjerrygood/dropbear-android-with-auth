#!/bin/bash
set -e

VERSION=2018.76
PREFIX=/tmp/dropbear-android
HOST=arm-linux-androideabi

export TOOLCHAIN="$TOOLCHAIN"
export PATH="$TOOLCHAIN/bin:$PATH"

# Android bionic libc 静态链接修复：stderr/stdin/stdout
EXTRA_CFLAGS="-Dstderr=__stderrp -Dstdout=__stdoutp -Dstdin=__stdinp"

wget -q https://mjt.dl.sourceforge.net/project/dropbear/dropbear-${VERSION}.tar.bz2
tar -xjf dropbear-${VERSION}.tar.bz2

# 先打补丁（解压原始源码，未运行configure）
cd dropbear-${VERSION}
patch -p1 -N --no-backup < ../android-compat.patch
cd -

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
  CFLAGS="${EXTRA_CFLAGS} -Os"

echo "===== Start make ====="
make -j$(nproc)
make install

mkdir -p ../target/arm
cp ${PREFIX}/sbin/dropbear ../target/arm/
cp ${PREFIX}/bin/dropbearkey ../target/arm/

${HOST}-strip ../target/arm/dropbear
${HOST}-strip ../target/arm/dropbearkey

echo "Build done, binaries in target/arm/"
ls -lh ../target/arm/
