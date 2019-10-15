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
rm -rf /usr/src/media_build
rm -rf /usr/src/media
rm -r /usr/src/tbs-tuner-firmwares_v1.0.tar.bz2
cd /usr/src
git clone https://github.com/tbsdtv/media_build.git
git clone --depth=1 https://github.com/tbsdtv/linux_media.git -b latest ./media
cd media_build
make dir DIR=../media
make allyesconfig
make -j4
sudo make install
wget http://www.tbsdtv.com/download/document/linux/tbs-tuner-firmwares_v1.0.tar.bz2
tar jxvf tbs-tuner-firmwares_v1.0.tar.bz2 -C /lib/firmware/
echo 'Done! Please reboot the server'
