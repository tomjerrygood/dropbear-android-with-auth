#!/bin/bash
set -e

VERSION=2018.76
PREFIX=/tmp/dropbear-android
HOST=arm-linux-androideabi

# 使用GitHub Action传入的TOOLCHAIN路径
export TOOLCHAIN="$TOOLCHAIN"
export PATH="$TOOLCHAIN/bin:$PATH"

# 下载原版dropbear源码
wget -q https://mjt.dl.sourceforge.net/project/dropbear/dropbear-${VERSION}.tar.bz2

# 解压源码
tar -xjf dropbear-${VERSION}.tar.bz2

# ====================== 关键：先打补丁，再configure ======================
cd dropbear-${VERSION}
# 打安卓兼容补丁，CI非交互模式
patch -p1 -N --no-backup < ../android-compat.patch
cd -

# 进入源码目录执行configure编译配置
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
  --disable-lastlog

echo "===== Start make ====="
make -j$(nproc)
make install

# 拷贝编译好的二进制到项目输出目录
mkdir -p ../target/arm
cp ${PREFIX}/sbin/dropbear ../target/arm/
cp ${PREFIX}/bin/dropbearkey ../target/arm/

# strip裁剪体积，去掉调试符号
${HOST}-strip ../target/arm/dropbear
${HOST}-strip ../target/arm/dropbearkey

echo "Build done, binaries in target/arm/"
ls -lh ../target/arm/
