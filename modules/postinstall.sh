#!/bin/bash
#
# Unattended/SemiAutomated OpenStack Installer
# Danny j. Pérez M. perezdann at gmail dot com
# Based on 1.0.5 ubuntu16lts by Reynaldo R. Martinez P. TigerLinux at gmail dot com
#
# Main Installer Script
# Version: 1.0.6.deb8 "Daenerys"
# July 09, 2016
#
# OpenStack MITAKA for Debian 8

PATH=$PATH:/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin

#
# First, we source our config file and verify that some important proccess are 
# already completed.
#

if [ -f ./configs/main-config.rc ]
then
	source ./configs/main-config.rc
	mkdir -p /etc/openstack-control-script-config
else
	echo "Can't access my config file. Aborting !"
	echo ""
	exit 0
fi

if [ -f /etc/openstack-control-script-config/db-installed ]
then
	echo ""
	echo "DB Proccess OK. Let's continue"
	echo ""
else
	echo ""
	echo "DB Proccess not completed. Aborting !"
	echo ""
	exit 0
fi

if [ -f /etc/openstack-control-script-config/keystone-installed ]
then
	echo ""
	echo "Keystone Proccess OK. Let's continue"
	echo ""
else
	echo ""
	echo "Keystone Proccess not completed. Aborting !"
	echo ""
	exit 0
fi

if [ -f /etc/openstack-control-script-config/postinstall-done ]
then
	echo ""
	echo "This module was already completed. Exiting !"
	echo ""
	exit 0
fi

#
# We copy our scripts and crontabs
#

cp -v ./libs/openstack-control.sh /usr/local/bin/
cp -v ./libs/openstack-log-cleaner.sh /usr/local/bin/
cp -v ./libs/openstack-vm-boot-start.sh /usr/local/bin/
cp -v ./libs/compute-and-instances-full-report.sh /usr/local/bin/
cp -v ./libs/instance-cpu-metrics-report.sh /usr/local/bin/
if [ $keystoneinstall == "yes" ]
then
	cp -v ./libs/openstack-keystone-tokenflush.sh /usr/local/bin/
	cp -v ./libs/keystone-flush-crontab /etc/cron.d/
fi
cp -v ./libs/nova-start-vms.conf /etc/openstack-control-script-config/
 
chmod 755 /usr/local/bin/openstack-control.sh
chmod 755 /usr/local/bin/openstack-log-cleaner.sh
chmod 755 /usr/local/bin/compute-and-instances-full-report.sh
if [ $keystoneinstall == "yes" ]
then
	chmod 755 /usr/local/bin/openstack-keystone-tokenflush.sh
fi
chmod 755 /usr/local/bin/openstack-vm-boot-start.sh

# service cron reload
systemctl restart cron

#
# Then we clean all OpenStack related logs and restarts all OpenStack related services
#

echo ""
echo "Re-starting all OpenStack Services and Cleaning UP all logs !"
echo ""

/usr/local/bin/openstack-control.sh stop
sleep 1
sync
/usr/local/bin/openstack-log-cleaner.sh auto
sync
sleep 1
/usr/local/bin/openstack-control.sh enable
/usr/local/bin/openstack-control.sh start

#
# And we are DONE !!!
#

echo ""
echo "Post Install Completed"
echo ""
echo "Remember: You can use the script /usr/local/bin/openstack-control.sh for admin tasks"
echo ""
/usr/local/bin/openstack-control.sh status
echo ""

