#!/bin/bash

#Make sure this script is run from the folder which contains the override files
#e.g. cd /tmp/argus/install_overrides
install_overrides_folder=`pwd`

if [ ! -d admin ]; then
	echo "ERROR: This script should be run from override folder. e.g. /tmp/argus/install_overrides"
	exit 1
fi

#latest_ver=`ls | grep -v current | sort -unr | head --lines=1`
latest_folder=`find /usr/hdp -name argus | grep -v current | sort -unr | head --lines=1`

if [ -f /etc/profile.d/java.sh ]; then
	. /etc/profile.d/java.sh
fi

echo "Override folder=$install_overrides_folder Install_folder=$latest_folder JAVA_HOME=$JAVA_HOME"

set -x
cd $install_overrides_folder
cp -r * $latest_folder

cd ${latest_folder}/admin
./install.sh

cd ${latest_folder}/ugsync
./install.sh

cd ${latest_folder}/hdfs-agent
./enable-hdfs-agent.sh

cd ${latest_folder}/hive-agent
./enable-hive-agent.sh
cp /etc/hive/conf/xa* /etc/hive/conf.server

cd ${latest_folder}/hbase-agent
./enable-hbase-agent.sh

cd ${latest_folder}/knox-agent
./enable-knox-agent.sh

#cd ${latest_folder}/storm-agent
#./enable-storm-agent.sh

#Apply the patches
cd $install_overrides_folder
cd ../patches
#Resolve hue getting databases issues. Should be removed later as it is fixed by dev team
./patch_for_audit_log_message/apply_patch.sh 


#Set the properties in Hive and HBase to use Argus
cd /var/lib/ambari-server/resources/scripts
./configs.sh -u admin -p admin -port 8080 set sandbox.hortonworks.com Sandbox hive-site "hive.security.authorization.enabled" "true"
./configs.sh -u admin -p admin -port 8080 set sandbox.hortonworks.com Sandbox hive-site "hive.security.authorization.manager" "com.xasecure.authorization.hive.authorizer.XaSecureHiveAuthorizerFactory"

./configs.sh -u admin -p admin -port 8080 set sandbox.hortonworks.com Sandbox hbase-site "hbase.coprocessor.master.classes" "com.xasecure.authorization.hbase.XaSecureAuthorizationCoprocessor"
./configs.sh -u admin -p admin -port 8080 set sandbox.hortonworks.com Sandbox hbase-site "hbase.coprocessor.region.classes" "com.xasecure.authorization.hbase.XaSecureAuthorizationCoprocessor"

#Copy the tutorial files to the home folder of root
cd $install_overrides_folder
cp -r ../argus_tutorial /root


#  exec{"install_argus_admin":
#    cwd => "/usr/hdp/current/argus/admin",
#    command => "/usr/hdp/current/argus/admin/install.sh",
#    require => Exec["override_properties"],
#  }
#  
#  exec{"install_argus_user_sync":
#    cwd => "/usr/hdp/current/argus/ugsync",
#    command => "/usr/hdp/current/argus/ugsync/install.sh",
#    require => Exec["install_argus_admin"],
#  }
#   
#  exec{"install_argus_hdfs_agent":
#    cwd => "/usr/hdp/current/argus/hdfs-agent",
#    command => "/usr/hdp/current/argus/hdfs-agent/enable-hdfs-agent.sh",
#    require => Exec["install_argus_admin"],
#  } 
