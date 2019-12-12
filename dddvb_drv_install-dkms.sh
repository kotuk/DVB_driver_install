#!/bin/bash
if [ "$EUID" -ne 0 ]
  then echo "Please run as root!"
  exit
fi
echo 'Prepare system'.
apt-get -y install build-essential patchutils\
 libproc-processtable-perl linux-headers-$(uname -r) git dkms;
systemctl disable apt-daily.service
systemctl disable apt-daily.timer ;
rm -rf /usr/src/dddvb-dkms
git clone --depth=1 https://github.com/DigitalDevices/dddvb /usr/src/dddvb-dkms
cd /usr/src/dddvb-dkms
sed -i -e 's/^#if defined(CONFIG_DVB_MAX_ADAPTERS).*$/#if 0/g' dvb-core/dvbdev.h
sed -i -e 's/DVB_MAX_ADAPTERS 64/DVB_MAX_ADAPTERS 256/g' dvb-core/dvbdev.h
sed -i -e 's/^\(#define MAX_DVB_MINORS*\).*/\1 512/g' dvb-core/dvbdev.c
echo "PACKAGE_NAME=dddvb
PACKAGE_VERSION=dddvb-dkms
AUTOINSTALL=y
MAKE='make all'
CLEAN='make clean'

BUILT_MODULE_NAME[0]=ddbridge
BUILT_MODULE_LOCATION[0]=ddbridge/
DEST_MODULE_LOCATION[0]=/updates/dkms

BUILT_MODULE_NAME[1]=octonet
BUILT_MODULE_LOCATION[1]=ddbridge/
DEST_MODULE_LOCATION[1]=/updates/dkms

BUILT_MODULE_NAME[2]=dvb-core
BUILT_MODULE_LOCATION[2]=dvb-core/
DEST_MODULE_LOCATION[2]=/updates/dkms

BUILT_MODULE_NAME[3]=cxd2099
BUILT_MODULE_LOCATION[3]=frontends/
DEST_MODULE_LOCATION[3]=/updates/dkms

BUILT_MODULE_NAME[4]=cxd2843
BUILT_MODULE_LOCATION[4]=frontends/
DEST_MODULE_LOCATION[4]=/updates/dkms

BUILT_MODULE_NAME[5]=drxk
BUILT_MODULE_LOCATION[5]=frontends/
DEST_MODULE_LOCATION[5]=/updates/dkms
 
BUILT_MODULE_NAME[6]=lnbh25
BUILT_MODULE_LOCATION[6]=frontends/
DEST_MODULE_LOCATION[6]=/updates/dkms

BUILT_MODULE_NAME[7]=lnbp21
BUILT_MODULE_LOCATION[7]=frontends/
DEST_MODULE_LOCATION[7]=/updates/dkms

BUILT_MODULE_NAME[8]=mxl5xx
BUILT_MODULE_LOCATION[8]=frontends/
DEST_MODULE_LOCATION[8]=/updates/dkms

BUILT_MODULE_NAME[9]=stv0367dd
BUILT_MODULE_LOCATION[9]=frontends/
DEST_MODULE_LOCATION[9]=/updates/dkms

BUILT_MODULE_NAME[10]=stv090x
BUILT_MODULE_LOCATION[10]=frontends/
DEST_MODULE_LOCATION[10]=/updates/dkms

BUILT_MODULE_NAME[11]=stv0910
BUILT_MODULE_LOCATION[11]=frontends/
DEST_MODULE_LOCATION[11]=/updates/dkms

BUILT_MODULE_NAME[12]=stv6110x
BUILT_MODULE_LOCATION[12]=frontends/
DEST_MODULE_LOCATION[12]=/updates/dkms

BUILT_MODULE_NAME[13]=stv6111
BUILT_MODULE_LOCATION[13]=frontends/
DEST_MODULE_LOCATION[13]=/updates/dkms

BUILT_MODULE_NAME[14]=tda18212dd
BUILT_MODULE_LOCATION[14]=frontends/
DEST_MODULE_LOCATION[14]=/updates/dkms

BUILT_MODULE_NAME[15]=tda18271c2dd
BUILT_MODULE_LOCATION[15]=frontends/
DEST_MODULE_LOCATION[15]=/updates/dkms" >> /usr/src/dddvb-dkms/dkms.conf
dkms add dddvb/dkms -k $(uname -r)
dkms build dddvb/dkms -k $(uname -r)
dkms install dddvb/dkms -k $(uname -r)
mkdir -p /etc/depmod.d
echo 'search extra updates built-in' >/etc/depmod.d/extra.conf
depmod -a
modprobe ddbridge
echo 'Done! Please reboot the server'
