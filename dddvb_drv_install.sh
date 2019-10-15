#!/bin/sh
if [ "$EUID" -ne 0 ]
  then echo "Please run as root!"
  exit
fi
echo 'Prepare system' 
if [ -n "`which apt-get`" ]; then apt-get -y install build-essential patchutils\
 libproc-processtable-perl linux-headers-$(uname -r) git;
systemctl disable apt-daily.service
systemctl disable apt-daily.timer ;
elif [ -n "`which yum`" ]; then yum -y groupinstall "Development Tools" "Development Libraries"; 
	yum install -y mercurial perl-Proc-ProcessTable kernel-devel kernel-headers ; fi
rm -rf /usr/src/dddvb
#rm -rf /lib/modules/$(uname -r)/extra
#rm -rf /lib/modules/$(uname -r)/kernel/drivers/media
#rm -rf /lib/modules/$(uname -r)/kernel/drivers/staging/media
git clone --depth=1 https://github.com/DigitalDevices/dddvb /usr/src/dddvb
cd /usr/src/dddvb
sed -i -e 's/^#if defined(CONFIG_DVB_MAX_ADAPTERS).*$/#if 0/g' dvb-core/dvbdev.h
sed -i -e 's/DVB_MAX_ADAPTERS 64/DVB_MAX_ADAPTERS 256/g' dvb-core/dvbdev.h
sed -i -e 's/^\(#define MAX_DVB_MINORS*\).*/\1 512/g' dvb-core/dvbdev.c
make -j 5
make install
mkdir -p /etc/depmod.d
echo 'search extra updates built-in' >/etc/depmod.d/extra.conf
depmod -a
modprobe ddbridge
echo 'Done! Please reboot the server'
