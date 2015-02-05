#!/bin/bash -x

rootdir="/opt/stack"
cd $rootdir
ls -l | grep -v -i  total | awk {'print $9'} > /tmp/flist

source ~/proxyrc
today=`date +"%d%m%y%H%M%S"`
pipdir=~/pipPackagesInstalled
mkdir -p $pipdir
devstackdir=~/devstack
backupdb=~/backupdb

while read line
do
	cd $rootdir/$line
	git checkout master
	git checkout -b "update$today"
	git pull origin master
	sudo pip freeze > $pipdir/before-$line-$today
	if [ -f $rootdir/$line/requirements.txt ]
	then
		sudo -E pip install -r $rootdir/$line/requirements.txt
		echo "sleeping incase to stop process on error"
		sleep 10
	fi
	sudo -E python setup.py build
	suod -E python setup.py install
done < /tmp/flist

# backup db

#| ceilometer         |
#| cinder             |
#| glance             |
#| heat               |
#| ironic             |
#| keystone           |
#| neutron            |
#| neutron_ml2        |
#| nova               |

#mysqldump --databases cinder glance heat ironic keystone neutron neutron_ml2 nova > $backupdb/openstack_dump-$today


#keystone-manage db_sync
#nova-manage db sync
#glance-manage db_sync
#neutron-db-manage --config-file /etc/neutron/neutron.conf --config-file /etc/neutron/plugins/ml2/ml2_conf.ini upgrade head
#cinder-manage db sync
#heat-manage db_sync
#ironic-dbsync --config-file /etc/ironic/ironic.conf upgrade head
#ceilometer-dbsync



# we may need to copy all etc / conf and replace values

#to add existing instances
# sudo ovs-vsctl add-port br-int qvo28549301-2c tag=1
