%global __os_install_post %{nil}
%define _unpackaged_files_terminate_build 1
%define _binaries_in_noarch_packages_terminate_build   0


Summary: Hue
Name: hue
Version: 1.2.1
Release: 1
License: Apache License, Version 2.0
Group: Development/Libraries
BuildArch: noarch
Source: hue.tgz
Source1: start_scripts.tgz
Source2: .ssh.tar.gz
#Source3: apache-maven-3.0.4-bin.tar.gz


Requires: wget, sudo, supervisor, libxslt, python-lxml

provides: hue

#No automatic binary dependencies
AutoReqProv: no



%description
Hue

%prep
%setup -n hue
%setup -b 1 -T -D -n start_scripts
%setup -b 2 -T -D -n .ssh
#%setup -b 3 -T -D -n apache-maven-3.0.4

%build


%install
rm -rf $RPM_BUILD_ROOT
mkdir -p $RPM_BUILD_ROOT/home/sandbox/{hue,start_scripts,.ssh}/ #apache-maven-3.0.4

cd $RPM_BUILD_DIR/hue
cp -R ./ $RPM_BUILD_ROOT/home/sandbox/hue/

cd $RPM_BUILD_DIR/start_scripts
cp -R ./ $RPM_BUILD_ROOT/home/sandbox/start_scripts

cd $RPM_BUILD_DIR/.ssh
cp -R ./ $RPM_BUILD_ROOT/home/sandbox/.ssh

#cd $RPM_BUILD_DIR/apache-maven-3.0.4
#cp -R ./ $RPM_BUILD_ROOT/home/sandbox/apache-maven-3.0.4


%clean
rm -rf $RPM_BUILD_ROOT $RPM_BUILD_DIR


%files
%dir /home/sandbox/hue
%dir /home/sandbox/start_scripts
%dir /home/sandbox/.ssh
#%dir /home/sandbox/apache-maven-3.0.4


%defattr(-,sandbox,sandbox)
/home/sandbox/


%defattr(600,sandbox,sandbox)
/home/sandbox/.ssh/id_rsa

%defattr(755,sandbox,sandbox)
/home/sandbox/start_scripts/hue
/home/sandbox/start_scripts/startup_script
/home/sandbox/start_scripts/startup_script_ec2


%pre

(
groupadd -f hadoop
[[ -z `cat /etc/passwd | grep sandbox` ]] && useradd -G hadoop sandbox || usermod -a -G hadoop sandbox
sudo -u sandbox -s -- <<END_OF_SANDBOX
cd /home/sandbox

#export PATH=$PATH:/home/sandbox/apache-maven-3.0.4/bin/

END_OF_SANDBOX

) | tee ~/sandbox-install.log


%post

(
sudo -u sandbox mkdir /home/sandbox/hue/logs

cd /home/sandbox/hue
mv desktop/libs/hadoop/java-lib/hue-plugins-*.jar /usr/lib/hadoop/lib/

ln -sf /home/sandbox/start_scripts/ambari /etc/init.d/ambari
chkconfig --add ambari
chkconfig ambari off

ln -sf /home/sandbox/start_scripts/startup_script /etc/init.d/startup_script
chkconfig --add startup_script
chkconfig --levels 3 startup_script on

ln -sf /home/sandbox/start_scripts/hue /etc/init.d/hue
chkconfig --add hue
chkconfig --levels 3 hue on



chkconfig iptables off
iptables -F
chkconfig ip6tables off
ip6tables -F

#echo "Update lxml"
#source build/env/bin/activate
#pip install lxml --upgrade


mkdir /etc/hue
mv /home/sandbox/hue/desktop/conf /etc/hue/
ln -s /etc/hue/conf /home/sandbox/hue/desktop/


) | tee ~/sandbox-install.log

%postun

if [ "$1" = "0" ]; then
	#  userdel -r sandbox
    echo
elif [ "$1" = "1" ]; then
  # upgrade
  echo
fi
