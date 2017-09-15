#!/bin/bash

set -e # Abort script at first error

cwd=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
uninstall_plugin='/usr/local/cpanel/scripts/uninstall_plugin'
dst='/usr/local/cpanel/base/3rdparty/sp-enduser-cpanel'

if [ $EUID -ne 0 ]; then
	echo 'Script requires root privileges, run it as root or with sudo'
	exit 1
fi

if [ ! -f /usr/local/cpanel/version ]; then
	echo 'cPanel installation not found'
	exit 1
fi

if [ ! -x $uninstall_plugin ]; then
	echo 'cPanel version 11.50 or later required'
	exit 1
fi

themes=('paper_lantern')

for theme in ${themes[@]}; do
	$uninstall_plugin ${cwd}/plugins/${theme} --theme $theme
done

webmail_plugin='/var/cpanel/webmail/webmail_sp-enduser-cpanel.yaml'

if [ -f $webmail_plugin ]; then
	echo 'Uninstalling from webmail'
	rm -v $webmail_plugin
	echo 'Plugin uninstalled ok'
fi

if [ -d $dst ]; then
	rm -rfv $dst
fi

echo 'Uninstall finished without errors'
