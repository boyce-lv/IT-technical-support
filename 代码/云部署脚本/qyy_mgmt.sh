#!/bin/bash

#set -x
function base_create {
	openstack project create $class"实验室"
        openstack quota set $class"实验室" --ram -1 \
        --key-pairs -1 --instances -1 --fixed-ips -1 --cores -1 \
        --injected-files -1 --injected-file-size -1 --routers -1 \
        --ports -1 --subnets -1 --networks -1 --floating-ips -1 \
        --secgroups -1 --secgroup-rules -1
	PROJECT_NAME=`openstack project list | grep $class | awk '{print $4}'`
	PROJECT_ID=`openstack project list | grep $class | awk '{print $2}'`
	openstack role add --project $PROJECT_ID --user admin admin
	cat > /root/os_keys/$class"-openrc" << EOF
		export OS_PROJECT_NAME=$PROJECT_NAME
		export OS_USERNAME=admin
		export OS_PASSWORD=4cdb0e5526184afc
		export OS_AUTH_URL=http://172.16.0.11:5000/v2.0
                export OS_REGION_NAME=RegionOne
EOF
	source /root/os_keys/$class"-openrc"

        openstack network create $class"-data-net"
        openstack subnet create --network $class"-data-net" \
        --allocation-pool start=10.0.10.0,end=10.0.100.0 \
        --gateway 10.0.0.1 \
        --dns-nameserver 114.114.114.114 \
        --subnet-range 10.0.0.0/8 $class"-data-subnet"
        DATANET_ID=`openstack network list | grep $class"-data-net" | awk '{print $2}'`
	for ((i=1; i<=$people; i++)); do
		openstack network create $class"-"$i"-internal-net"
		openstack subnet create --network $class"-"$i"-internal-net" \
		--allocation-pool start=172.16.$i.11,end=172.16.$i.13 \
		--gateway 172.16.$i.1 \
		--dns-nameserver 114.114.114.114 \
		--subnet-range 172.16.$i.0/24 $class"-"$i"-internal-subnet"
		NET_ID=`openstack network list | grep $class"-"$i"-internal-net" | awk '{print $2}'`
		SUBNET_ID=`openstack network list | grep $class"-"$i"-internal-net" | awk '{print $6}'`
		neutron router-create $class"-Router-"$i
		neutron router-gateway-set $class"-Router-"$i Public
		neutron router-interface-add $class"-Router-"$i $SUBNET_ID
		nova boot --image af59c902-8700-4573-8197-474792713b2d --flavor 0f54a309-22db-4ba4-8580-69b2a5a1b358 \
                --nic net-id=$NET_ID --nic net-id=$DATANET_ID $class"-"$i"-controller"
		nova boot --image af59c902-8700-4573-8197-474792713b2d --flavor 0f54a309-22db-4ba4-8580-69b2a5a1b358 \
                --nic net-id=$NET_ID --nic net-id=$DATANET_ID $class"-"$i"-compute"
                INSTANCES_PORTS=(`openstack port list | grep $SUBNET_ID | grep -wE "172.16.$i.11|172.16.$i.12|172.16.$i.13" | awk '{print $2}'`)
                #echo ${INSTANCES_PORTS[*]}
                for j in ${INSTANCES_PORTS[*]}; do
                        PORT_TYPE=`openstack port show $j | grep device_owner | awk '{print $4}'| awk -F ':' '{print $1}'`
                        #echo $PORT_TYPE
                        if [ "$PORT_TYPE" == "compute" ]; then
                		neutron floatingip-create Public --port-id $j
                        fi
                done
	done
}

function clean {
	source /root/os_keys/$class"-openrc"
	VMS=(`nova list | grep $class | awk '{print $2}'`)
	ROUTERS=(`neutron router-list | grep $class | awk '{print $2}'`)
	NETWORKS=(`neutron net-list | grep $class | awk '{print $2}'`)
	PROJECT=`openstack project list | grep $class | awk '{print $2}'`
	#SUBNETS=(`neutron subnet-list | grep $class | awk '{print $2}'`)
        FLOATING_IPS=(`nova floating-ip-list | grep Public | awk '{print $4}'`)
        openstack floating ip delete ${FLOATING_IPS[*]}
        #UNUSED_FLOATING=(`openstack floating ip list | grep None | awk '{print $2}'`)
        #if test -z $UNUSED_FLOATING; then
        #        echo "There are not  unused floating IPs."
        #else
        #        openstack floating ip delete ${UNUSED_FLOATING[*]}
        #fi
	for i in ${ROUTERS[*]}; do
		ROUTER_PORT=(`neutron router-port-list $i | grep subnet_id | awk '{print $2}'`)
		for j in ${ROUTER_PORT[*]}; do
			DEVICE_OWNER=`neutron port-show $j | grep device_owner | awk '{print $4}' | awk -F ':' '{print $2}'`
			if [ "$DEVICE_OWNER" == "router_interface" ]; then
				ROUTER_SUBNET=(`neutron port-show $j | grep fixed_ips | awk '{print $5}' | awk -F '"' '{print $2}'`)
				#ROUTER_SUBNETS=(`neutron router-port-list $i | grep subnet_id | awk '{print $8}' | awk -F '"' '{print $2}'`)
				neutron router-interface-delete $i $ROUTER_SUBNET
			fi
		done
	done
	nova delete ${VMS[*]}
	neutron router-delete ${ROUTERS[*]}
	neutron net-delete ${NETWORKS[*]}
	openstack project delete $PROJECT
	rm -fr /root/os_keys/$class"-openrc"
}

function advance_create {
	echo "advance_create"
}

######################################################函数初始化完毕##############################################
source /root/os_keys/keystonerc_admin

echo "========================"
echo "========基本配置========"
echo "========================"
echo "请输入班级: "
read class
echo "请输入人数: "
read people
#echo "请输入人均云主机数: "
#read vms_per_people

echo "========================"
echo "=====请输入操作类型====="
echo "========================"
echo "1)创建基础环境          "
echo "2)创建实战环境          "
echo "3)清除该班环境          "
echo "4)直接退出操作          "
read type
if [ $type = 1 ]; then
	if [ -f "/root/os_keys/$class"-openrc"" ]; then
		echo $class"已存在，请先行清除"
	else
		base_create
	fi
elif [ $type = 2 ]; then
	if [ -f "/root/os_keys/$class"-openrc"" ]; then
		echo $class"已存在，请先行清除"
	else
		advance_create
	fi
elif [ $type = 3 ]; then
	if [ -f "/root/os_keys/$class"-openrc"" ]; then
		clean
	else
		echo $class"已被清除"
	fi
elif [ $type = 4 ]; then
	exit
else
	echo "无效操作，请再来一次！"
fi