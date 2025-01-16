#!/bin/bash

#Change default theme
sed -i "s/luci-theme-bootstrap/luci-theme-$WRT_THEME/g" $(find ./feeds/luci/collections/ -type f -name "Makefile")
#Change immortalwrt.lan connect address
sed -i "s/192\.168\.[0-9]*\.[0-9]*/$WRT_IP/g" $(find ./feeds/luci/modules/luci-mod-system/ -type f -name "flash.js")
#Add compile tags
sed -i "s/(\(luciversion || ''\))/(\1) + (' \/ $WRT_CI-$WRT_DATE')/g" $(find ./feeds/luci/modules/luci-mod-status/ -type f -name "10_system.js")

WIFI_SH="./package/base-files/files/etc/uci-defaults/990_set-wireless.sh"
WIFI_UC="./package/network/config/wifi-scripts/files/lib/wifi/mac80211.uc"
if [ -f "$WIFI_SH" ]; then
	#Change WIFI Name
	sed -i "s/BASE_SSID='.*'/BASE_SSID='$WRT_SSID'/g" $WIFI_SH
	#Change WIFI PW
	sed -i "s/BASE_WORD='.*'/BASE_WORD='$WRT_WORD'/g" $WIFI_SH
elif [ -f "$WIFI_UC" ]; then
	#Change WIFI Name
	sed -i "s/ssid='.*'/ssid='$WRT_SSID'/g" $WIFI_UC
	#Change WIFI PW
	sed -i "s/key='.*'/key='$WRT_WORD'/g" $WIFI_UC
	#Change WIFI Region
	sed -i "s/country='.*'/country='CN'/g" $WIFI_UC
	#Change WIFI encrypt_mode
	sed -i "s/encryption='.*'/encryption='psk2+ccmp'/g" $WIFI_UC
fi

CFG_FILE="./package/base-files/files/bin/config_generate"
#Change default lan address
sed -i "s/192\.168\.[0-9]*\.[0-9]*/$WRT_IP/g" $CFG_FILE
#Change default hostname
sed -i "s/hostname='.*'/hostname='$WRT_NAME'/g" $CFG_FILE

#Change config file
echo "CONFIG_PACKAGE_luci=y" >> ./.config
echo "CONFIG_LUCI_LANG_zh_Hans=y" >> ./.config
echo "CONFIG_PACKAGE_luci-theme-$WRT_THEME=y" >> ./.config
echo "CONFIG_PACKAGE_luci-app-$WRT_THEME-config=y" >> ./.config

#Only one manual set package
if [ -n "$WRT_PACKAGE" ]; then
	echo "$WRT_PACKAGE" >> ./.config
fi

#IPQ Platform Changes
if [[ $WRT_TARGET == *"IPQ"* ]]; then
	#Cannel NSS feeds
	echo "CONFIG_FEED_nss_packages=n" >> ./.config
	echo "CONFIG_FEED_sqm_scripts_nss=n" >> ./.config
	#Set NSS Version
	echo "CONFIG_NSS_FIRMWARE_VERSION_11_4=n" >> ./.config
	echo "CONFIG_NSS_FIRMWARE_VERSION_12_2=y" >> ./.config
fi

#Compiler Optimization
if [[ $WRT_TARGET != *"X86"* ]]; then
	echo "CONFIG_TARGET_OPTIONS=y" >> ./.config
	echo "CONFIG_TARGET_OPTIMIZATION=\"-O2 -pipe -march=armv8-a+crypto+crc -mcpu=cortex-a53+crypto+crc -mtune=cortex-a53\"" >> ./.config
fi
