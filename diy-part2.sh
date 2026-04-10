#!/bin/bash
# ===============================================
# DIY script for GL-MT5000 (MT7987A) support
# ===============================================

set -e

echo "=== 调试信息 ==="
echo "当前目录: $(pwd)"
echo "脚本路径: $0"
echo "检查目录结构:"
ls -la
echo "=== 调试结束 ==="

# 检查 openwrt 目录是否存在
if [ ! -d openwrt ]; then
    echo "错误：openwrt 目录不存在"
    echo "当前目录内容:"
    ls -la
    exit 1
fi

# 进入 openwrt 目录
cd openwrt
echo "已进入 openwrt 目录，当前目录: $(pwd)"

# 检查 files 目录是否存在
if [ ! -d files ]; then
    echo "错误：files 目录不存在于 openwrt/ 中"
    echo "openwrt目录内容:"
    ls -la
    exit 1
fi

echo "=== Applying GL-MT5000 device support ==="

# 1. 复制设备树文件
echo "Copying device tree file..."
if [ -f files/mt7987a-gl-mt5000.dts ]; then
    cp -f files/mt7987a-gl-mt5000.dts target/linux/mediatek/dts/
    echo "✓ Device tree file copied."
else
    echo "⚠ Device tree file not found: files/mt7987a-gl-mt5000.dts"
    echo "files目录内容:"
    ls -la files/
    exit 1
fi

# 2. 应用镜像定义补丁（跳过有问题的补丁）
echo "Applying image definition patch..."
if [ -f files/filogic.mk.patch ]; then
    echo "检查补丁文件内容..."
    # 检查补丁文件是否为空或无效
    if [ ! -s files/filogic.mk.patch ]; then
        echo "⚠ 补丁文件为空，跳过"
    elif ! head -n 1 files/filogic.mk.patch | grep -q "^---\|^diff\|^Index:"; then
        echo "⚠ 补丁文件格式无效，跳过"
        echo "补丁文件前几行内容:"
        head -n 5 files/filogic.mk.patch
    else
        echo "尝试应用补丁..."
        if patch -p1 -d target/linux/mediatek/image/ < files/filogic.mk.patch; then
            echo "✓ Image definition patched."
        else
            echo "⚠ 补丁应用失败，跳过此步骤继续编译"
            echo "注意：这可能导致固件镜像定义不正确"
        fi
    fi
else
    echo "⚠ No patch file found, skipping."
fi

# 3. 复制设备初始化脚本
echo "Copying board initialization scripts..."
mkdir -p target/linux/mediatek/mt7987a/base-files/etc/board.d/
if [ -f files/02_network ]; then
    cp -f files/02_network target/linux/mediatek/mt7987a/base-files/etc/board.d/
    chmod +x target/linux/mediatek/mt7987a/base-files/etc/board.d/02_network
    echo "✓ Board scripts copied."
else
    echo "⚠ Board script not found: files/02_network"
    exit 1
fi

# 4. 复制平台识别脚本
echo "Copying platform identification script..."
mkdir -p target/linux/mediatek/mt7987a/base-files/lib/upgrade/
if [ -f files/platform.sh ]; then
    cp -f files/platform.sh target/linux/mediatek/mt7987a/base-files/lib/upgrade/
    chmod +x target/linux/mediatek/mt7987a/base-files/lib/upgrade/platform.sh
    echo "✓ Platform script copied."
else
    echo "⚠ Platform script not found: files/platform.sh"
    exit 1
fi

echo "=== GL-MT5000 support applied successfully ==="
