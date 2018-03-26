#/usr/bin/bash

if [ $# -ne 1 ];
   then echo "Illegal number of parameters, please provide name of your cert file"
   exit 1
fi
# Things to change
# 1. root_passwd

root_passwd=root

master_node=`hostname -i`
#echo ${root_passwd}
sed -i "s/root_passwd=root/root_passwd=${root_passwd}/" node_tasks.sh
sed -i "s/master_node_ip=0/master_node_ip=${master_node}/" node_tasks.sh

#Initial content of the cluster shell groups file
line="all: "

#Modify the sshd config file
sudo cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bak
sudo sed -i s/\#PasswordAuthentication\ yes/PasswordAuthentication\ yes/ /etc/ssh/sshd_config
sudo sed -i s/PasswordAuthentication\ no/\#PasswordAuthentication\ no/ /etc/ssh/sshd_config
sudo sed -i s/\#PermitRootLogin\ yes/PermitRootLogin\ yes/ /etc/ssh/sshd_config

sudo chmod a+r /etc/ssh/sshd_config
sudo ssh-keygen -f /root/.ssh/id_rsa -N ''


while read ipaddress
do
  echo "Logging into $ipaddress..."

  #prepare data for clush groups file
  line=$line' '$ipaddress

  #Copy cert file to all nodes on home directory
  scp -i $1 -o "StrictHostKeyChecking no" $1 $ipaddress:poc.pem
  #Allow root login and restart sshd on all nodes
  cat node_tasks.sh | ssh -o "StrictHostKeyChecking no" -i $1 $ipaddress /usr/bin/bash
  # copy ssh key pair to node
  sudo sshpass -p "${root_passwd}" sudo ssh-copy-id -o StrictHostKeyChecking=no root@$ipaddress
done < poc_hosts.txt



echo "Install Cluster Shell on Master Node"
sudo yum -y install epel-release
sudo yum -y install clustershell vim-clustershell

echo Cluster shell groups file with all group: $line
echo $line > groups
sudo cp groups /etc/clustershell/groups

#echo Copy prepare_nodes.sh to all nodes
#sudo clush -a --copy $HOME/prepare_nodes.sh

#######################
#   Update hosts file # -- make sure hosts file is updated on the master node
#######################
echo Copy hosts file to all nodes
sudo clush -a --copy /etc/hosts



