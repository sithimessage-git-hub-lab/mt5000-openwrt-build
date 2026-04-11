#!/bin/bash
#
# https://github.com/P3TERX/Actions-OpenWrt
#
# File name: diy-part1.sh
# Description: OpenWrt DIY script part 1 (Before Update feeds)
#
# Copyright (c) 2019-2024 P3TERX <https://p3terx.com>
#
# This is free software, licensed under the MIT License.
# See /LICENSE for more information.
#

# Uncomment a feed source
#sed -i 's/^#\(.*helloworld\)/\1/' feeds.conf.default

# Add a feed source
echo 'src-git helloworld https://github.com/fw876/helloworld.git' >>feeds.conf.default
#echo 'src-git passwall https://github.com/xiaorouji/openwrt-passwall' >>feeds.conf.default

# 配置 GL-MT5000 设备
echo "配置 GL-MT5000 设备..."

# 创建初始配置
cat > .config << 'EOF'
# Target selection
CONFIG_TARGET_mediatek=y
CONFIG_TARGET_mediatek_filogic=y
CONFIG_TARGET_DEVICE_mediatek_filogic_DEVICE_glinet_gl-mt5000=y

# Basic configuration
CONFIG_TARGET_ROOTFS_SQUASHFS=y
CONFIG_TARGET_ROOTFS_INITRAMFS=y
CONFIG_TARGET_ROOTFS_CPIOGZ=y
CONFIG_TARGET_UBIFS_FREE_SPACE_FIXUP=y
CONFIG_TARGET_UBIFS_JOURNAL_SIZE=""

# Kernel modules
CONFIG_PACKAGE_kmod-mt7915e=y
CONFIG_PACKAGE_kmod-mt798x-firmware=y
CONFIG_PACKAGE_kmod-mmc=y
CONFIG_PACKAGE_kmod-fs-ext4=y
CONFIG_PACKAGE_kmod-fs-f2fs=y
CONFIG_PACKAGE_kmod-fs-vfat=y

# Utilities
CONFIG_PACKAGE_blkid=y
CONFIG_PACKAGE_blockdev=y
CONFIG_PACKAGE_mkf2fs=y

# Network
CONFIG_PACKAGE_iptables-mod-extra=y
CONFIG_PACKAGE_iptables-mod-tproxy=y
CONFIG_PACKAGE_dnsmasq-full=y

# LuCI
CONFIG_PACKAGE_luci=y
CONFIG_PACKAGE_luci-compat=y
CONFIG_PACKAGE_luci-app-firewall=y
CONFIG_PACKAGE_luci-app-opkg=y
CONFIG_PACKAGE_luci-app-upnp=y
CONFIG_PACKAGE_luci-theme-bootstrap=y

# Base system
CONFIG_PACKAGE_base-files=y
CONFIG_PACKAGE_busybox=y
CONFIG_PACKAGE_dropbear=y
CONFIG_PACKAGE_fstools=y
CONFIG_PACKAGE_procd=y
CONFIG_PACKAGE_uci=y
CONFIG_PACKAGE_wpad-openssl=y
EOF

echo "设备配置完成"
