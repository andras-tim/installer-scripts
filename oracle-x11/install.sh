#!/bin/bash -e
# Oracle 11 Express (XE) Installer for Ubuntu
#   by Carl Scharenberg, July 18, 2011, carl.scharenberg@gmail.com
#   Original blog post: http://blog.uncommonguy.com/?p=1234
#
# Use as you like, but please leave original credits in place.
# Disclaimer: Use at your own risk. Don't ever blindly run scripts without
#             knowing what they do, including this one.

# Assumption: you have downloaded the Oracle 11 Express debian package from
# http://www.oracle.com/technetwork/database/express-edition/11gxe-beta-download-302519.html

# Change this if necessary. Perhaps version and filename will change at some point
ORACLE_FILE='oracle-xe_11.2.0-2_amd64.deb'

# check for Oracle package in local dir
if [ ! -f $ORACLE_FILE ]; then
  echo The Oracle 11 XE package $ORACLE_FILE was not found in the local dir.
  echo
  exit
fi

# install pre-reqs
echo Installing needed libraries
sudo apt-get -y install libaio1 bc chkconfig


# create /sbin/chkconfig if it doesn't exist (like on Ubuntu)
if [[ ! -f /sbin/chkconfig ]]; then
echo Creating /sbin/chkconfig to emulate Red Hat control script
read -d '' TEXT <<"DELIM"
#!/bin/bash\\n
# Oracle 11gR2 XE installer chkconfig hack for Debian by Dude\\n
file=/etc/init.d/oracle-xe\\n
if [[ ! `tail -n1 $file | grep INIT` ]]; then\\n
   echo >> $file\\n
   echo '### BEGIN INIT INFO' >> $file\\n
   echo '# Provides:             OracleXE' >> $file\\n
   echo '# Required-Start:       $remote_fs $syslog' >> $file\\n
   echo '# Required-Stop:        $remote_fs $syslog' >> $file\\n
   echo '# Default-Start:        2 3 4 5' >> $file\\n
   echo '# Default-Stop:         0 1 6' >> $file\\n
   echo '# Short-Description:    Oracle 11g Express Edition' >> $file\\n
   echo '### END INIT INFO' >> $file\\n
fi\\n
update-rc.d oracle-xe defaults 80 01\\n
DELIM
echo -e $TEXT > /tmp/chkconfig
chmod 755 /tmp/chkconfig
mv /tmp/chkconfig /sbin/chkconfig
fi

# install Oracle package
echo Starting Oracle install
sudo dpkg -i "${ORACLE_FILE}"

######
# WORKAROUNDS by tia
#
[ ! -e '/bin/awk' ] && ln -s '/usr/bin/awk' '/bin/awk'

mkdir -p /var/lock/subsys
sed -E 's>(CONFIGURATION="/etc/default/.*)>\1\n        mkdir -p "/var/lock/subsys" >' -i /etc/init.d/oracle-xe

update-rc.d oracle-xe defaults

export ORACLE_HOME=/u01/app/oracle/product/11.2.0/xe
export ORACLE_SID=XE
cat - >> '/etc/environment' << EOF
ORACLE_HOME=${ORACLE_HOME}
ORACLE_SID=${ORACLE_SID}
EOF

export PATH="$PATH:${ORACLE_HOME}/bin"
sed -E "s>^(PATH=.*[^\"])([\"]*)$>\1:${ORACLE_HOME}/bin\2>g" -i '/etc/environment'
#
######

# configure Oracle
echo Configuring Oracle
sudo /etc/init.d/oracle-xe configure


# add Oracle environment variables to oracle user environment
echo "Adding environment variables to oracle user's .bashrc"
cat >> /u01/app/oracle/.bashrc << DELIM
export ORACLE_SID=XE
alias vi='vim'
export ORACLE_BASE=\$HOME
export ORACLE_HOME=\$ORACLE_BASE/product/11.2.0/xe
export ORACLE_TERM=xterm
export _EDITOR=vim
export NLS_LANG=american_america.utf8
export TNS_ADMIN=\$ORACLE_HOME/network/admin
export ORA_NLS33=\$ORACLE_HOME/ocommon/nls/admin/data
export LD_LIBRARY_PATH=\$ORACLE_HOME/lib
export PATH=\$ORACLE_HOME/bin:\$PATH
DELIM

echo Finished
echo
echo Reconfigure: sudo /etc/init.d/oracle-xe configure
echo Stop:  sudo /etc/init.d/oracle-xe stop
echo Start: sudo /etc/init.d/oracle-xe start
echo
echo Usage: sqlplus SYSTEM/\<password\>@XE
echo
