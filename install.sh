#!/bin/bash

set -e # Abort script at first error

cwd=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
install_plugin='/usr/local/cpanel/scripts/install_plugin'
dst='/usr/local/cpanel/base/3rdparty/sp-enduser-cpanel'

if [ $EUID -ne 0 ]; then
	echo 'Script requires root privileges, run it as root or with sudo'
	exit 1
fi

if [ ! -f /usr/local/cpanel/version ]; then
	echo 'cPanel installation not found'
	exit 1
fi

if [ ! -x $install_plugin ]; then
	echo 'cPanel version 11.44 or later required'
	exit 1
fi

if [ -d $dst ]; then
	echo "Existing installation found, try running the uninstall script first"
	exit 1
fi

mkdir -v $dst
cp -v ${cwd}/index.live.php $dst
cp -v ${cwd}/settings.php $dst

themes=('paper_lantern')

for theme in ${themes[@]}; do
	$install_plugin ${cwd}/plugins/${theme} --theme $theme
done

echo 'Install webmail plugin?'
select action in "Yes" "No"; do
	case $action in
		"Yes")
			webmail=true
			break;
			;;
		"No")
			webmail=false
			break;
			;;
		*)
			echo 'Invalid option'
			;;
	esac
done

if [ "$webmail" = true ]; then
	cp -v ${cwd}/plugins/webmail/icon-314x109.png $dst
	${cwd}/plugins/webmail/register.pl
fi

echo 'Installation finished without errors'
echo "Edit '${dst}/settings.php' to configure the plugin"
