#!/bin/bash -e

DEST='/opt/git-3th/facebook_flashcache'

function cout()
{
    echo -e "\n### $1..."
}

######
# MAIN
#
if [ -e "$DEST" ]; then
    echo "ERROR: The destination directory exists: $DEST"
    exit 1
fi

cout 'Installing dependencies'
apt-get install dkms build-essential linux-headers-`uname -r` git

cout 'Downloading source...'
mkdir -p "$DEST"
cd "$DEST"
git clone 'https://github.com/facebook/flashcache.git' "$DEST"

cout 'Preparing kernel modules and utilities'
make
make install

cout 'Preparing DKMS'
make -f Makefile.dkms boot_conf

cout 'Preparing man pages'
cd "$DEST/man"
make
make install

cout 'All Done'
exit 0
