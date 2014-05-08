apt-get -y update;
apt-get install -y vim wget curl docker.io bridge-utils arping puppet-common;
echo "limit nofile 65536 65536" >> /etc/init/docker.io.conf
echo "limit nproc unlimited unlimited" >> /etc/init/docker.io.conf
service docker.io restart
wget -O /bin/pipework https://raw.githubusercontent.com/jpetazzo/pipework/master/pipework;
chmod +x /bin/pipework;
ln -s /usr/bin/docker.io /usr/bin/docker
cd /root
wget http://dev2.hortonworks.com.s3.amazonaws.com/stuff/ssh.tar.gz
tar xvf ssh.tar.gz
chown root:root -R .ssh
chmod 600 .ssh/id_rsa
chmod 700 .ssh


echo 'nameserver 8.8.8.8' > /etc/resolv.conf
cp -rf /vagrant/images /tmp/
cp -rf /puppet /tmp/images/ambari/puppet
cd /tmp/images/common
docker.io build --rm=true -t ambari/common .
cd ../ambari
docker.io build --rm=true -t ambari/bluprint .
docker.io run -d --name ambari -p 8080:8080 -p 8000:8000 -p 8088:8088 -h ambari.hortonworks.com ambari/bluprint
pipework br1 ambari 192.168.1.1/24;
for i in `seq 2 3`
do
    name="host$i"
    docker.io run -d --name $name -h $name.hortonworks.com ambari/common
    pipework br1 $name 192.168.1.$i/24;
done

ip addr add 192.168.1.254/24 dev br1
ssh -oStrictHostKeyChecking=no root@192.168.1.1 'export FACTER_nodecount=3 && puppet apply --verbose --modulepath="/tmp/puppet/modules" --detailed-exitcodes /tmp/puppet/manifests/init.pp'
