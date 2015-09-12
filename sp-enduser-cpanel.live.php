<?php
// Non-cPanel users should use the regular version instead
if (!isset($_SERVER['CPANEL']) || $_SERVER['CPANEL'] != 'active')
	die();

// Get timezone offset from client
if (isset($_GET['timezone'])) setcookie('timezone', intval($_GET['timezone']));
if (!isset($_COOKIE['timezone']))
	die('<script>window.location.href = "?timezone=" + new Date().getTimezoneOffset();</script>');

// Includes
require_once '/usr/local/cpanel/php/cpanel.php';
require_once 'sp-enduser-settings.php';

// Cpanel API
$cpanel = new CPANEL();

// For some reason, querying 'listpops' when signed in as a domain
// owner returns only the username, while logging in as a specific
// email address returns that address (and likely aliases as well)
if(strpos($_SERVER['REMOTE_USER'], '@') === false)
{
	// It's the domain owner, give them access to everything
	$domains_res = $cpanel->api2('Email', 'listmaildomains');
	$domains = array();
	foreach($domains_res['cpanelresult']['data'] as $data)
		$domains[] = $data['domain'];
	if(empty($domains))
		die("No Domains");
	$access = array('domain' => $domains);
}
else
{
	// It's an email user, give them access to their own account
	$addresses_res = $cpanel->api2('Email', 'listpops');
	$addresses = array();
	foreach($addresses_res['cpanelresult']['data'] as $data)
		$addresses[] = $data['email'];
	if(empty($addresses))
		die("No Addresses");
	$access = array('mail' => $addresses);
}

$get = http_build_query(
	array(
		'username' => $_SERVER['REMOTE_USER'],
		'api-key' => $settings['api-key']
	)
);
$opts = array(
	'http' => array(
		'method'  => 'POST',
		'header'  => 'Content-type: application/x-www-form-urlencoded',
		'content' => http_build_query(array('access' => $access))
	)
);
$context = stream_context_create($opts);
$result = json_decode(@file_get_contents($settings['enduser'].'session-transfer.php?'.$get, false, $context));
if (!$result || !isset($result->session))
	die('Transfer failed');

header('Location: '.$settings['enduser'].'session-transfer.php?session='.$result->session);
