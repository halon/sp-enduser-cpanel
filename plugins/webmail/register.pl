#!/usr/bin/perl

use lib '/usr/local/cpanel';
use Cpanel::DataStore;

my $app = {
	url => '/3rdparty/sp-enduser-cpanel/index.live.php',
	displayname => 'Halon Anti-spam',
	icon => '/3rdparty/sp-enduser-cpanel/icon-314x109.png',
};

print "Installing to webmail\n";

Cpanel::DataStore::store_ref('/var/cpanel/webmail/webmail_sp-enduser-cpanel.yaml', $app) || die("Could not write webmail registration file");

print "Plugin installed ok\n";
