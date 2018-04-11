#!/bin/bash
#set -x
yum remove firewalld-filesystem NetworkManager-libnm -y
PASSWORD=iforgot
MGMT_IP=`ip a | grep -e inet | grep -v inet'[0-9]' | awk '{print $2}' | cut -d "/" -f 1 | awk 'NR==2'`
PROVIDER_IN=`ip a | grep '^[0-9]' | cut -d ':' -f 2 | awk 'NR==2' | cut -d ' ' -f 2`
LOOP=`losetup -f`
COMPUTE_PKGS=(
lvm2
openstack-nova-compute
openstack-neutron-linuxbridge
ebtables
ipset
openstack-cinder
targetcli
python-keystone
)
yum install ${COMPUTE_PKGS[*]} -y
systemctl enable lvm2-lvmetad.service
systemctl start lvm2-lvmetad.service
sleep 10
cat > /etc/nova/nova.conf << EOF
[DEFAULT]
enabled_apis = osapi_compute,metadata
transport_url = rabbit://openstack:$PASSWORD@controller
my_ip = $MGMT_IP
use_neutron = True
firewall_driver = nova.virt.firewall.NoopFirewallDriver
[api]
auth_strategy = keystone
[cinder]
[database]
[ephemeral_storage_encryption]
[filter_scheduler]
[glance]
api_servers = http://controller:9292
[key_manager]
[keystone]
[keystone_authtoken]
auth_uri = http://controller:5000
auth_url = http://controller:35357
memcached_servers = controller:11211
auth_type = password
project_domain_name = default
user_domain_name = default
project_name = service
username = nova
password = $PASSWORD
[libvirt]
virt_type = qemu
#virt_type = kvm#在物理机中用kvm
[matchmaker_redis]
[metrics]
[mks]
[neutron]
url = http://controller:9696
auth_url = http://controller:35357
auth_type = password
project_domain_name = default
user_domain_name = default
region_name = RegionOne
project_name = service
username = neutron
password = $PASSWORD
[notifications]
[osapi_v21]
[oslo_concurrency]
lock_path = /var/lib/nova/tmp
[placement]
os_region_name = RegionOne
project_domain_name = Default
project_name = service
auth_type = password
user_domain_name = Default
auth_url = http://controller:35357/v3
username = placement
password = $PASSWORD
[vnc]
enabled = True
vncserver_listen = 0.0.0.0
vncserver_proxyclient_address = $MGMT_IP
novncproxy_base_url = http://controller:6080/vnc_auto.html
EOF
egrep -c '(vmx|svm)' /proc/cpuinfo
systemctl enable libvirtd.service openstack-nova-compute.service
systemctl start libvirtd.service openstack-nova-compute.service
sleep 10
cat > /etc/neutron/neutron.conf <<EOF
[DEFAULT]
transport_url = rabbit://openstack:$PASSWORD@controller
auth_strategy = keystone
[keystone_authtoken]
auth_uri = http://controller:5000
auth_url = http://controller:35357
memcached_servers = controller:11211
auth_type = password
project_domain_name = default
user_domain_name = default
project_name = service
username = neutron
password = $PASSWORD
[oslo_concurrency]
lock_path = /var/lib/neutron/tmp
EOF
cat > /etc/neutron/plugins/ml2/linuxbridge_agent.ini <<EOF
[linux_bridge]
physical_interface_mappings = provider:$PROVIDER_IN
[vxlan]
enable_vxlan = true
local_ip = $MGMT_IP
l2_population = true
[securitygroup]
enable_security_group = true
firewall_driver = neutron.agent.linux.iptables_firewall.IptablesFirewallDriver
EOF
systemctl restart openstack-nova-compute.service
sleep 10
systemctl enable neutron-linuxbridge-agent.service
systemctl start neutron-linuxbridge-agent.service
sleep 10
dd if=/dev/zero of=/root/test.img bs=1G count=20
losetup $LOOP /root/test.img
mkfs.ext4 $LOOP
pvcreate $LOOP
vgcreate cinder-volumes $LOOP
cp /etc/lvm/lvm.conf /etc/lvm/lvm.conf.bak
grep -v '^#' /etc/lvm/lvm.conf.bak | grep -v '^$' | grep -v '#' > /etc/lvm/lvm.conf
sed -i "12c filter = \[ \"a\|\.\*\/\|\" \]" /etc/lvm/lvm.conf
systemctl restart lvm2-lvmetad
sleep 10
cat > /etc/cinder/cinder.conf <<EOF
[DEFAULT]
transport_url = rabbit://openstack:$PASSWORD@controller
auth_strategy = keystone
my_ip = $MGMT_IP
enabled_backends = lvm
glance_api_servers = http://controller:9292
[database]
connection = mysql+pymysql://cinder:$PASSWORD@controller/cinder
[keystone_authtoken]
auth_uri = http://controller:5000
auth_url = http://controller:35357
memcached_servers = controller:11211
auth_type = password
project_domain_name = default
user_domain_name = default
project_name = service
username = cinder
password = $PASSWORD
[lvm]
volume_driver = cinder.volume.drivers.lvm.LVMVolumeDriver
volume_group = cinder-volumes
iscsi_protocol = iscsi
iscsi_helper = lioadm
[oslo_concurrency]
lock_path = /var/lib/cinder/tmp
EOF
systemctl enable openstack-cinder-volume.service target.service
systemctl start openstack-cinder-volume.service target.service
sleep 10