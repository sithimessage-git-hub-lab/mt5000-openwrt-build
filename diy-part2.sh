#!/bin/bash
# ===============================================
# DIY script for GL-MT5000 (MT7987A) support
# ===============================================

set -e

# 进入openwrt目录
cd openwrt

echo "=== Applying GL-MT5000 device support ==="

# 1. 复制设备树文件
echo "Copying device tree file..."
# 使用相对路径：从仓库根目录的files文件夹复制
cp -f ../files/mt7987a-gl-mt5000.dts ./target/linux/mediatek/dts/
echo "✓ Device tree file copied."

# 2. 应用镜像定义补丁
echo "Applying image definition patch..."
if [ -f ../files/filogic.mk.patch ]; then
    patch -p1 -d ./target/linux/mediatek/image/ < ../files/filogic.mk.patch
    echo "✓ Image definition patched."
else
    echo "⚠ No patch file found, skipping."
fi

# 3. 复制设备初始化脚本
echo "Copying board initialization scripts..."
mkdir -p ./target/linux/mediatek/mt7987a/base-files/etc/board.d/
cp -f ../files/02_network ./target/linux/mediatek/mt7987a/base-files/etc/board.d/
chmod +x ./target/linux/mediatek/mt7987a/base-files/etc/board.d/02_network
echo "✓ Board scripts copied."

# 4. 复制平台识别脚本
echo "Copying platform identification script..."
mkdir -p ./target/linux/mediatek/mt7987a/base-files/lib/upgrade/
cp -f ../files/platform.sh ./target/linux/mediatek/mt7987a/base-files/lib/upgrade/
chmod +x ./target/linux/mediatek/mt7987a/base-files/lib/upgrade/platform.sh
echo "✓ Platform script copied."

echo "=== GL-MT5000 support applied successfully ==="
