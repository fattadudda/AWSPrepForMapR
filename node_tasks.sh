#/usr/sbin/bash

#**********TO DO***********
# modify root password in line 6

root_passwd=root
#echo $root_passwd

#DO NOT MODIFY - this will be updated by initial_setup.sh script
master_node_ip=0
echo master node is: $master_node_ip

user_name=`whoami`
echo user name is: $user_name

sudo yum install -y sshpass && echo "${root_passwd}" | sudo passwd root --stdin && sudo cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bak && echo "start copy config file..." && sudo sshpass -p '${root_passwd}' scp -o "StrictHostKeyChecking no" -i poc.pem ${user_name}@${master_node_ip}:/etc/ssh/sshd_config /etc/ssh/sshd_config && echo "sshd config file copied..." && sudo sshd -t && echo sshd... && sudo service sshd restart && echo "sshd restarted" 


exit
