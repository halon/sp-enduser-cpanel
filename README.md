cPanel plugin for the end-user web application for Halon's email gateway. Please read more on http://wiki.halon.se/End-user and http://halon.io

Requirements
-------------
* cPanel version 11.50 or later
 * (Optional) `YAML::Syck` Perl module is required to register the webmail plugin
* Existing end-user web application with `session-transfer.php` enabled

Installation
-------------
1. Download the latest [release](https://github.com/halonsecurity/sp-enduser-cpanel/releases) to the cPanel server using `curl` or `wget` and extract it
2. Run the provided installation script with `./sp-enduser-cpanel/install.sh`

To uninstall the plugin, run the provided uninstall script with `./sp-enduser-cpanel/uninstall.sh`
