#!/bin/bash
echo -n "input saltid:"
read saltid
echo -n "input hostip:"
read hostip

echo '#关闭防火墙'
systemctl stop firewalld  && systemctl disable firewalld
setenforce 0
sed -i s/"SELINUX=enforcing"/"SELINUX=disable"/ /etc/selinux/config 

echo '修改主机名'
echo 'export PS1="[\u@\H \W]\\$ \[\e[m\]"' >> /etc/profile
source /etc/profile
hostnamectl set-hostname $saltid 
echo "$hostip $saltid" >> /etc/hosts
echo "alias ce='curl vortex-eureka:8761 |grep '" >> ~/.bashrc
source ~/.bashrc

echo '修改yum源，安装常用软件'
mv /etc/yum.repos.d/CentOS-Base.repo /etc/yum.repos.d/CentOS-Base.repo.bak  
curl -o /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-7.repo 
curl -o /etc/yum.repos.d/epel-7.repo http://mirrors.aliyun.com/repo/epel-7.repo 
yum clean all
yum makecache
yum install dos2unix net-tools httpie ftp wget vim htop lrzsz zip unzip ntpdate  -y
echo '*/30 * * * * /usr/sbin/ntpdate time7.aliyun.com >/dev/null 2>&1' > /tmp/crontab2.tmp
crontab /tmp/crontab2.tmp

echo '安装jdk8'
rm -f `which java`
mkdir /home/java/;cd /home/java/
wget ftp://222.92.212.125:64300/software/jdk/jdk-8u144-linux-x64.tar.gz --ftp-user=vortex --ftp-password=ftp12#$
tar -zxvf jdk-8u144-linux-x64.tar.gz
echo 'export JAVA_HOME=/home/java/jdk1.8.0_144' >> /etc/profile
echo 'export PATH=$JAVA_HOME/bin:$PATH' >> /etc/profile
echo 'export CLASSPATH=.:$JAVA_HOME/lib/dt.jar:$JAVA_HOME/lib/tools.jar' >> /etc/profile
source /etc/profile
ln -s /home/java/jdk1.8.0_144/bin/jps /bin/jps
ln -s /home/java/jdk1.8.0_144/bin/java /bin/java

echo '安装saltstack'
#yum install salt-minion -y
cd /usr/local/src/
curl -Ou caofei:123456 ftp://caofei@222.92.212.125/centos/rpm/salt/salt-2018.3.4-1.el7.noarch.rpm
curl -Ou caofei:123456 ftp://caofei@222.92.212.125/centos/rpm/salt/salt-minion-2018.3.4-1.el7.noarch.rpm
yum install -y salt-2018.3.4-1.el7.noarch.rpm
yum install -y salt-minion-2018.3.4-1.el7.noarch.rpm
sed -i s/"^#master:.*"/"master: salt.vortexinfo.cn"/ /etc/salt/minion
sed -i s/"^#master_port: 4506"/"master_port: 14506"/ /etc/salt/minion 
sed -i s/"^#id:"/"id: $saltid"/ /etc/salt/minion
systemctl start salt-minion && systemctl enable salt-minion

#echo '安装docker'
#curl -s http://kod.vortexinfo.cn:8082/ks/sh/docker.sh |bash

chmod +x /etc/rc.d/rc.local