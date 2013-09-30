#!/bin/sh

CUR_DIR=`pwd`
TMP_DIR="/tmp/oracle-instantclient"
ORACLE_INSTANTCLIENT_LIB_DIR="/usr/lib64/oracle"
ORACLE_INSTANTCLIENT_LD_CONF=/etc/ld.so.conf.d/oracle-instantclient-x86_64.conf
# Oracle Instant Client Package tarball oracle-instantclientAMD64-10.1.0.5.0.tgz contains sources downloaded 
# from http://www.oracle.com/technetwork/topics/linuxx86-64soft-092277.html :
#     instantclient-basic-linuxAMD64-10.1.0.5.0-20060519.zip (32,200,686 bytes) (cksum - 991396986)
#     instantclient-jdbc-linuxAMD64-10.1.0.5.0-20060519.zip (4,650,957 bytes) (cksum - 2639141761)
#     instantclient-sqlplus-linuxAMD64-10.1.0.5.0-20060519.zip (366,963 bytes) (cksum - 567416601)
#     instantclient-sdk-linuxAMD64-10.1.0.5.0-20060519.zip (294,632 bytes) (cksum - 3782887635)
ORA_BACKEND_TAR_LINK=ftp://10.2.2.42/pub/temp/oracle-instantclientAMD64-10.1.0.5.0.tgz
ORA_BACKEND_TAR=$CUR_DIR/oracle-instantclientAMD64-10.1.0.5.0.tgz

if [ ! -f "$ORA_BACKEND_TAR" ]; then
  wget "$ORA_BACKEND_TAR_LINK"
  if [ ! -f "$ORA_BACKEND_TAR" ]; then
    echo "The Oracle backend tarball does not exist at $ORA_BACKEND_TAR"
    echo "Fix the problem and try again."
    exit 1
  fi
fi

if [ ! -d "$TMP_DIR" ]; then
  mkdir -p "$TMP_DIR"
fi

tar xfvz "$ORA_BACKEND_TAR" -C "$TMP_DIR"
cd "$TMP_DIR"
unzip ./instantclient-sdk-linuxAMD64-10.1.0.5.0-20060519.zip
unzip ./instantclient-sqlplus-linuxAMD64-10.1.0.5.0-20060519.zip
unzip ./instantclient-basic-linuxAMD64-10.1.0.5.0-20060519.zip
unzip ./instantclient-jdbc-linuxAMD64-10.1.0.5.0-20060519.zip

mkdir -p $ORACLE_INSTANTCLIENT_LIB_DIR
cp -f $TMP_DIR/instantclient10_1/*.so* $ORACLE_INSTANTCLIENT_LIB_DIR
ln -s $ORACLE_INSTANTCLIENT_LIB_DIR/libclntsh.so.10.1 $ORACLE_INSTANTCLIENT_LIB_DIR/libclntsh.so
ln -s $ORACLE_INSTANTCLIENT_LIB_DIR/libclntsh.so.10.1 /usr/lib/libclntsh.so
echo $ORACLE_INSTANTCLIENT_LIB_DIR > $ORACLE_INSTANTCLIENT_LD_CONF
ldconfig
export ORACLE_HOME="$TMP_DIR/instantclient10_1"
export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:$ORACLE_HOME"
yum install -y python-devel

/etc/init.d/hue stop
#/usr/lib/hue/build/env/bin/hue dumpdata > /tmp/db_dump.json
/usr/lib/hue/build/env/bin/pip install south --upgrade
/usr/lib/hue/build/env/bin/pip install cx_Oracle
/usr/lib/hue/build/env/bin/hue syncdb --noinput
/usr/lib/hue/build/env/bin/hue migrate
#/usr/lib/hue/build/env/bin/hue loaddata /tmp/db_dump.json
/etc/init.d/hue start
rm -Rf "$TMP_DIR"

