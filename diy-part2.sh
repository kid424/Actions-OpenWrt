#!/bin/bash
#
# https://github.com/P3TERX/Actions-OpenWrt
# File name: diy-part2.sh
# Description: OpenWrt DIY script part 2 (After Update feeds)
#
# Copyright (c) 2019-2024 P3TERX <https://p3terx.com>
#
# This is free software, licensed under the MIT License.
# See /LICENSE for more information.
#

# Modify default IP
sed -i 's/192.168.1.1/10.0.0.1/g' package/base-files/files/bin/config_generate

# Modify default theme
#sed -i 's/luci-theme-bootstrap/luci-theme-argon/g' feeds/luci/collections/luci/Makefile

# Modify hostname
#sed -i 's/OpenWrt/P3TERX-Router/g' package/base-files/files/bin/config_generate

BASE_PATH=$(pwd)
cd package
#安装和更新软件包
UPDATE_PACKAGE() {
        local PKG_NAME=$1
        local PKG_REPO=$2
        local PKG_BRANCH=$3
        local PKG_SPECIAL=$4
        local REPO_NAME=$(echo $PKG_REPO | cut -d '/' -f 2)

        rm -rf $(find ../feeds/luci/ ../feeds/packages/ -maxdepth 3 -type d -iname "*$PKG_NAME*" -prune)

        git clone --depth=1 --single-branch --branch $PKG_BRANCH "https://github.com/$PKG_REPO.git"

        if [[ $PKG_SPECIAL == "pkg" ]]; then
                cp -rf $(find ./$REPO_NAME/*/ -maxdepth 3 -type d -iname "*$PKG_NAME*" -prune) ./
                rm -rf ./$REPO_NAME/
        elif [[ $PKG_SPECIAL == "name" ]]; then
                mv -f $REPO_NAME $PKG_NAME
        fi
}

UPDATE_PACKAGE "openclash" "vernesong/OpenClash" "dev" "pkg"

#sed -i '/\/etc\/init\.d\/tailscale/d;/\/etc\/config\/tailscale/d;' ../feeds/packages/net/tailscale/Makefile
#UPDATE_PACKAGE "luci-app-tailscale" "asvow/luci-app-tailscale" "main"
UPDATE_PACKAGE "luci-app-xupnpd" "jarod360/luci-app-xupnpd" "main"
UPDATE_PACKAGE "luci-app-wolplus" "animegasan/luci-app-wolplus" "main"
UPDATE_PACKAGE "luci-app-msd_lite" "ximiTech/luci-app-msd_lite" "main"

# 预置openclash文件
CORE_TYPE="arm64"
CORE_META="https://github.com/vernesong/OpenClash/raw/core/dev/meta/clash-linux-$CORE_TYPE.tar.gz"
GEO_MMDB="https://github.com/alecthw/mmdb_china_ip_list/raw/release/lite/Country.mmdb"
GEO_SITE="https://github.com/Loyalsoldier/v2ray-rules-dat/raw/release/geosite.dat"
GEO_IP="https://github.com/Loyalsoldier/v2ray-rules-dat/raw/release/geoip.dat"
cd ./luci-app-openclash/root/etc/openclash/
curl -sL -o Country.mmdb $GEO_MMDB && echo "Country.mmdb done!"
curl -sL -o GeoSite.dat $GEO_SITE && echo "GeoSite.dat done!"
curl -sL -o GeoIP.dat $GEO_IP && echo "GeoIP.dat done!"
mkdir ./core/ && cd ./core/
curl -sL -o meta.tar.gz $CORE_META && tar -zxf meta.tar.gz && mv -f clash clash_meta && echo "meta done!"
chmod +x ./* && rm -rf ./*.gz
cd $BASE_PATH
