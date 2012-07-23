#!/bin/bash -e

[ $# -lt 1 ] && echo 'Missing parameter: ZIP file' && exit 1
[ ! -e "$1" ] && echo "ZIP file doesn't not exits" && exit 1
file="`echo "$1" | sed -E 's>\.rpm\.zip>>g'`"

apt-get install unzip alien libaio1 unixodbc

unzip "$1"
cd Disk1

alien --verbose --to-deb --scripts "${file}.rpm"

cd ..
mv "Disk1/${file}.deb" ./
rm -r 'Disk1'

exit 0
