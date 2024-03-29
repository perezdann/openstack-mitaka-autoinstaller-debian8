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

if [ -f ./configs/main-config.rc ]
then
	source ./configs/main-config.rc
	mkdir -p /etc/openstack-control-script-config
else
	echo "Can't Access my config file. Aborting !"
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

if [ -f /etc/openstack-control-script-config/keystone-extra-idents ]
then
	echo ""
	echo "This module was already completed. Exiting !"
	echo ""
	exit 0
fi

source $keystone_fulladmin_rc_file

echo ""
echo "Creating NEUTRON Identities"
echo ""

echo "Neutron User:"
openstack user create --domain $keystonedomain --password  $neutronpass --email $neutronemail $neutronuser

echo "Neutron Role:"
openstack role add --project $keystoneservicestenant --user $neutronuser $keystoneadminuser

echo "Neutron Service:"
openstack service create \
        --name $neutronsvce \
        --description "OpenStack Networking" \
        network

echo "Neutron Endpoints:"

openstack endpoint create --region $endpointsregion \
	network public http://$neutronhost:9696

openstack endpoint create --region $endpointsregion \
	network internal http://$neutronhost:9696

openstack endpoint create --region $endpointsregion \
	network admin http://$neutronhost:9696

echo "Listo"

echo ""
echo "NEUTRON Identities Created"
echo ""

