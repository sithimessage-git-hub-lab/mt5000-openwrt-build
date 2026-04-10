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

# 2. 应用镜像定义补丁
echo "Applying image definition patch..."
if [ -f files/filogic.mk.patch ]; then
    echo "直接插入设备定义到 filogic.mk..."
    
    # 确保目标文件存在
    if [ ! -f target/linux/mediatek/image/filogic.mk ]; then
        echo "创建目标文件..."
        mkdir -p target/linux/mediatek/image/
        touch target/linux/mediatek/image/filogic.mk
    fi
    
    # 在 glinet_gl-mt3000 之后插入设备定义
    if grep -q "glinet_gl-mt3000" target/linux/mediatek/image/filogic.mk; then
        echo "找到 glinet_gl-mt3000，在其后插入 GL-MT5000 定义..."
        
        # 创建要插入的内容
        INSERT_CONTENT="\n\
define Device/glinet_gl-mt5000\n\
  DEVICE_VENDOR := GL.iNet\n\
  DEVICE_MODEL := GL-MT5000\n\
  DEVICE_DTS := mt7987a-gl-mt5000\n\
  DEVICE_DTS_DIR := ../dts\n\
  SUPPORTED_DEVICES := glinet,gl-mt5000\n\
  DEVICE_PACKAGES := mkf2fs blkid blockdev kmod-fs-ext4 mt7987-2p5g-phy-firmware \\\\\n\
                     kmod-mmc kmod-fs-f2fs kmod-fs-vfat\n\
  IMAGES += factory.bin\n\
  IMAGE/factory.bin := append-kernel | pad-to 32M | append-rootfs\n\
  IMAGE/sysupgrade.bin := sysupgrade-tar | append-gl-metadata\n\
endef\n\
\n\
TARGET_DEVICES += glinet_gl-mt5000\n"
        
        # 使用 sed 插入内容
        sed -i '/glinet_gl-mt3000/a\'"$INSERT_CONTENT" target/linux/mediatek/image/filogic.mk
        echo "✓ GL-MT5000 设备定义已插入"
    else
        echo "⚠ 未找到 glinet_gl-mt3000，将定义追加到文件末尾..."
        
        # 直接追加到文件末尾
        cat >> target/linux/mediatek/image/filogic.mk << 'EOF'

define Device/glinet_gl-mt5000
  DEVICE_VENDOR := GL.iNet
  DEVICE_MODEL := GL-MT5000
  DEVICE_DTS := mt7987a-gl-mt5000
  DEVICE_DTS_DIR := ../dts
  SUPPORTED_DEVICES := glinet,gl-mt5000
  DEVICE_PACKAGES := mkf2fs blkid blockdev kmod-fs-ext4 mt7987-2p5g-phy-firmware \
                     kmod-mmc kmod-fs-f2fs kmod-fs-vfat
  IMAGES += factory.bin
  IMAGE/factory.bin := append-kernel | pad-to 32M | append-rootfs
  IMAGE/sysupgrade.bin := sysupgrade-tar | append-gl-metadata
endef

TARGET_DEVICES += glinet_gl-mt5000
EOF
        echo "✓ GL-MT5000 设备定义已追加到文件末尾"
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
