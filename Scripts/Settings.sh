#!/bin/bash

#修改默认主题
sed -i "s/luci-theme-bootstrap/luci-theme-$WRT_THEME/g" $(find ./feeds/luci/collections/ -type f -name "Makefile")

CFG_FILE="./package/base-files/files/bin/config_generate"
#修改默认IP地址
sed -i "s/192\.168\.[0-9]*\.[0-9]*/$WRT_IP/g" $CFG_FILE
#修改默认主机名
sed -i "s/hostname='.*'/hostname='$WRT_NAME'/g" $CFG_FILE
#修改默认时区
sed -i "s/timezone='.*'/timezone='CST-8'/g" $CFG_FILE
sed -i "/timezone='.*'/a\\\t\t\set system.@system[-1].zonename='Asia/Shanghai'" $CFG_FILE

if [[ $WRT_URL == *"lede"* ]]; then
	# 修改主机名字，把OpenWrt-123修改你喜欢的就行（不能纯数字或者使用中文）
	sed -i '/uci commit system/i\uci set system.@system[0].hostname='$WRT_NAME$'' package/lean/default-settings/files/zzz-default-settings
	sed -i "s/OpenWrt /StarZ build $(TZ=UTC-8 date "+%Y.%m.%d") @ OpenWrt /g" ./package/lean/default-settings/files/zzz-default-settings
	#修改默认WIFI名
	sed -i "s/ssid=.*/ssid=$WRT_WIFI/g" ./package/kernel/mac80211/files/lib/wifi/mac80211.sh
elif [[ $WRT_URL == *"immortalwrt"* ]]; then
	#添加编译日期标识
	VER_FILE=$(find ./feeds/luci/modules/ -type f -name "10_system.js")
	awk -v wrt_repo="$WRT_REPO" -v wrt_date="$WRT_DATE" '{ gsub(/(\(luciversion \|\| \047\047\))/, "& + (\047 / "wrt_repo"-"wrt_date"\047)") } 1' $VER_FILE > temp.js && mv -f temp.js $VER_FILE
	#修改默认WIFI名
	sed -i "s/ssid=.*/ssid=$WRT_WIFI/g" ./package/network/config/wifi-scripts/files/lib/wifi/mac80211.sh
fi

#配置文件修改
echo "CONFIG_PACKAGE_luci-theme-$WRT_THEME=y" >> ./.config
echo "CONFIG_PACKAGE_luci-app-$WRT_THEME-config=y" >> ./.config

if [[ $WRT_URL == *"lede"* ]]; then
	echo "CONFIG_PACKAGE_luci-app-ssr-plus=y" >> ./.config
	# echo "CONFIG_PACKAGE_luci-app-openclash=y" >> ./.config
elif [[ $WRT_URL == *"immortalwrt"* ]]; then
	echo "CONFIG_PACKAGE_luci=y" >> ./.config
	echo "CONFIG_LUCI_LANG_zh_Hans=y" >> ./.config
	echo "CONFIG_PACKAGE_luci-app-homeproxy=y" >> ./.config
fi
