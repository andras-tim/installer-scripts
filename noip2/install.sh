#!/bin/bash -e

function cout()
{
    echo -e "\n### $1..."
}

######
# MAIN
#
DIR="`pwd`"
TMP="`mktemp -d`"
cd "$TMP"

cout 'Getting source'
wget 'http://www.no-ip.com/client/linux/noip-duc-linux.tar.gz' -O 'noip-duc-linux.tar.gz'
tar xzf 'noip-duc-linux.tar.gz'
cd `find . -type d -name 'noip-*'`

cout 'Building'
make

cout 'Installing'
make install

cout 'Configuring rc'
cp 'debian.noip2.sh' '/etc/init.d/noip2'
chmod 755 '/etc/init.d/noip2'
update-rc.d noip2 defaults

cout 'Starting ip'
'/etc/init.d/noip2' start
noip2 -S

cout 'Cleaning up'
cd "$DIR"
rm -r "$TMP"

cout 'All Done'
exit 0
