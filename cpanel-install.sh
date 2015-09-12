#!/bin/bash

# Exit if anything errors; better safe than sorry
set -e

if [ $EUID -ne 0 ]; then
	echo "This script requires root privileges, please run it as root, or with:"
	echo "    sudo ./cpanel-install.sh"
	exit 1
fi

if [ ! -x '/usr/local/cpanel/bin/register_cpanelplugin' ];
then
	echo "Can't seem to find register_cpanelplugin, is cPanel installed properly?"
	exit 1
fi



# Figure out where we are; relative paths are evil
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Destination paths, because nobody likes repeating themselves
DEST="/usr/local/cpanel/base/3rdparty/sp-enduser"

# Has something been installed?
INSTALLED=false




# Only move things if they're not already in the right place
if [[ "$DIR" != "$DEST" ]]; then
	
	# If there's an old (copied) installation, abort and tell the user
	if [[ -d $DEST ]]; then
		echo "An existing installation has been found:"
		echo "$DEST"
		echo ""
		echo "Please either run 'git pull' and './cpanel-install.sh' in the existing"
		echo "installation to update it, or move it aside to set up a new installation."
		exit 1
	else
		echo "Installing SP-Enduser's cPanel plugin to:"
		echo "$DEST"
		
		cp -Rf "$DIR" "$DEST"
		INSTALLED=true
	fi
else
	echo "Already installed, would you like to re-register the plugin with cPanel?"
	select action in "Yes" "No"; do
		case $action in
			"Yes") break;;
			"No") exit 0;;
		esac
	done
fi

# Register the plugin with cPanel; output is written
echo ""
echo "Registering the plugin with cPanel... (this may take a while)"
if /usr/local/cpanel/bin/register_cpanelplugin $DIR/cpanel-sp-enduser.cpanelplugin > $DIR/register_cpanelplugin.log; then
	# If the installation succeeds, just quietly delete the log file
	rm $DIR/register_cpanelplugin.log
else
	echo " -> Couldn't register the plugin!"
	echo "    Output has been written to:"
	echo "    $DIR/register_cpanelplugin.log"
	exit 1
fi

if $INSTALLED; then
	echo ""
	echo "Halon SP-Enduser's cPanel plugin has been successfully installed!"
	echo ""
	echo "You can safely delete this directory, it has been copied to:"
	echo "$DEST"
	echo ""
	echo "If you want to show a logo for Halon Antispam on the webmail login page:"
	echo ""
	echo "1. Open /usr/local/cpanel/base/webmail/x3/index.html"
	echo "2. Locate the block that starts with <cpanelfeature emailtrace> and ends with"
	echo "   </cpanelfeature>"
	echo "3. Add the following below said block, but before the </cpanelif>:"
	echo ""
	echo '<cpanelfeature sp-enduser>'
    echo '	<td>'
    echo '		<div valign="top" align="center">'
    echo '			<a href="../../3rdparty/sp-enduser/index.live.php" target="_blank"><img src="../../3rdparty/sp-enduser/static/img/sp-logo-small.png" border="0" /></a><br /><a href="../../3rdparty/sp-enduser/index.live.php" target="_blank"><cpanel langprint="Halon Antispam"></a>'
    echo '		</div>'
	echo '	</td>'
	echo '</cpanelfeature>'
	echo ""
	echo "To configure the SP-Enduser plugin, edit settings.php."
fi
