#!/bin/bash

if  [ $1 = '--help' ]; then
	echo 'Script for control SELinux module'
	echo 'Please run as root'
	echo 'No argument needed, work in interactive mode'
	exit 0
fi

if [ "$EUID" -ne 0 ]; then
	# user not root
	echo "Please run script as root(use sudo)" 
	exit 1
fi
rootdir=$(sestatus | grep "SELinux root directory" | sed "s/SELinux root directory: //")
echo
echo '******************************************* '
echo 'Cerrent state: '
sestatnow=$(sestatus | grep "Current mode:" | sed "s/Current mode: //")
echo "SELinux current mode:$sestatnow"
sestat=$(sestatus | grep "SELinux status:" | sed "s/SELinux status: //")
echo "SELinux status: $sestat"
semode=$(sestatus | grep "Mode from config file:" | sed "s/Mode from config file: //")
echo "Mode from config file: $semode"
echo '********************************************'
echo
if [ $sestatnow = 'enforcing' ]; then
	# Current enable
	read -p 'SELinux current enabled, DISABLE it (y/n, q-quit): ' answer
	if [[ $answer = [Yy] ]]; then
		setenforce 0
	elif [[ $answer = [Nn] ]]; then
		echo 'no changed'		
	elif [[ $answer = [Qq] ]]; then
		exit 0
	fi	
elif [ $sestatnow = 'permissive' ]; then
	# Current disable
	read -p 'SELinux current disable, ENABLE it (y/n, q-quit): ' answer
	if [[ $answer = [Yy] ]]; then
		setenforce 1
	elif [[ $answer = [Nn] ]]; then
		echo 'no changed'		
	elif [[ $answer = [Qq] ]]; then
		exit 0
	fi
fi

if [ $semode != 'disabled' ]; then
	# Current enable in config
	read -p 'DISABLE SELinux in config file? (y/n, q-quit): ' answer
	if [[ $answer = [Yy] ]]; then
		sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' $rootdir/config
		sed -i 's/SELINUX=permissive/SELINUX=disabled/g' $rootdir/config
		echo 'Changes apply after reboot System'
	elif [[ $answer = [Nn] ]]; then
		echo		
	elif [[ $answer = [Qq] ]]; then
		exit 0
	fi	
else
	# Current disable in config
	read -p 'ENABLE SELinux in config file? (y/n, q-quit): ' answer
	if [[ $answer = [Yy] ]]; then
		sed -i 's/SELINUX=disabled/SELINUX=enforcing/' $rootdir/config
		echo 'Changes apply after reboot System'
	elif [[ $answer = [Nn] ]]; then
		echo		
	elif [[ $answer = [Qq] ]]; then
		exit 0
	fi
fi
exit 0
