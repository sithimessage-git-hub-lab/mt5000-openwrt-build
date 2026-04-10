#!/bin/bash
# ===============================================
# DIY script for GL-MT5000 (MT7987A) support
# ===============================================

set -e

# 确保在正确的目录下
if [ -d "$GITHUB_WORKSPACE/openwrt" ]; then
    cd "$GITHUB_WORKSPACE/openwrt"
else
    echo "错误：未找到 openwrt 目录！"
    exit 1
fi

echo "=== Applying GL-MT5000 device support ==="

# 1. 复制设备树文件
echo "Copying device tree file..."
cp -f $GITHUB_WORKSPACE/files/mt7987a-gl-mt5000.dts ./target/linux/mediatek/dts/
echo "✓ Device tree file copied."

# 2. 应用镜像定义补丁
echo "Applying image definition patch..."
# 使用绝对路径，确保文件存在
SOURCE_FILE="$GITHUB_WORKSPACE/files/mt7987a-gl-mt5000.dts"
if [ -f "$SOURCE_FILE" ]; then
    cp -f "$SOURCE_FILE" ./target/linux/mediatek/dts/
    echo "✓ Device tree file copied."
else
    echo "❌ 错误：设备树文件不存在于 $SOURCE_FILE"
    echo "请检查文件是否已提交到仓库的 files/ 目录下。"
    exit 1
fi

# ... 其余部分保持不变 ...

# 3. 复制设备初始化脚本
echo "Copying board initialization scripts..."
mkdir -p ./target/linux/mediatek/mt7987a/base-files/etc/board.d/
cp -f $GITHUB_WORKSPACE/files/02_network ./target/linux/mediatek/mt7987a/base-files/etc/board.d/
chmod +x ./target/linux/mediatek/mt7987a/base-files/etc/board.d/02_network
echo "✓ Board scripts copied."

# 4. 复制平台识别脚本
echo "Copying platform identification script..."
mkdir -p ./target/linux/mediatek/mt7987a/base-files/lib/upgrade/
cp -f $GITHUB_WORKSPACE/files/platform.sh ./target/linux/mediatek/mt7987a/base-files/lib/upgrade/
chmod +x ./target/linux/mediatek/mt7987a/base-files/lib/upgrade/platform.sh
echo "✓ Platform script copied."

echo "=== GL-MT5000 support applied successfully ==="
