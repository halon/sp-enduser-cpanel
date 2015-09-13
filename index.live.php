<?php
// Get timezone offset from client
if (isset($_GET['timezone'])) $timezone = intval($_GET['timezone']);
if (!isset($_GET['timezone']))
	die('<script>window.location.href = "?timezone=" + new Date().getTimezoneOffset();</script>');

require_once '/usr/local/cpanel/php/cpanel.php';
require_once 'settings.php';

$cpanel = new CPANEL();

if (strpos($_SERVER['REMOTE_USER'], '@') === false) {
	// cPanel users, give them access to their domains
	$domains_res = $cpanel->uapi('Email', 'list_mail_domains');
	$domains = array();
	foreach ($domains_res['cpanelresult']['result']['data'] as $data)
		$domains[] = $data['domain'];
	if (empty($domains))
		die("No domains");
	$access = array('domain' => $domains);
}
else {
	// Webmail users, give them access to their email addresses 
	$addresses_res = $cpanel->uapi('Email', 'list_pops');
	$addresses = array();
	foreach ($addresses_res['cpanelresult']['result']['data'] as $data)
		$addresses[] = $data['email'];
	if (empty($addresses))
		die("No email addresses");
	$access = array('mail' => $addresses);
}

$enduser = $settings['enduser'];
if (substr($enduser, -1) == '/')
	$enduser = substr($enduser, 0, -1);

$get = http_build_query(
	array(
		'username' => $_SERVER['REMOTE_USER'],
		'api-key' => $settings['api-key'],
		'timezone' => $timezone
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
$result = json_decode(@file_get_contents($enduser.'/session-transfer.php?'.$get, false, $context));
if (!$result || !isset($result->session))
	die('Transfer failed');

header('Location: '.$enduser.'/session-transfer.php?session='.$result->session);
