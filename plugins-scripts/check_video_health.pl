#! /usr/bin/perl

use strict;
no warnings qw(once);

if ( ! grep /BEGIN/, keys %Monitoring::GLPlugin::) {
  eval {
    require Monitoring::GLPlugin;
    require Monitoring::GLPlugin::SNMP;
  };
  if ($@) {
    printf "UNKNOWN - module Monitoring::GLPlugin was not found. Either build a standalone version of this plugin or set PERL5LIB\n";
    printf "%s\n", $@;
    exit 3;
  }
}

my $lugin = Classes::Device->new();

my $plugin = Classes::Device->new(
    shortname => '',
    usage => 'Usage: %s [ -v|--verbose ] [ -t <timeout> ] '.
        '--mode <what-to-do> '.
        '--hostname <network-component> --community <snmp-community>'.
        '  ...]',
    version => '$Revision: #PACKAGE_VERSION# $',
    blurb => 'This plugin checks various parameters of video conference systems',
    url => 'http://labs.consol.de/nagios/check_video_health',
    timeout => 60,
);

$plugin->add_mode(
    internal => 'device::hardware::load',
    spec => 'cpu-load',
    alias => undef,
    help => 'Check the status of environmental equipment (fans, temperatures, power, selftests)',
);
$plugin->add_mode(
    internal => 'device::hardware::memory',
    spec => 'memory-usage',
    alias => undef,
    help => 'Check the status of environmental equipment (fans, temperatures, power, selftests)',
);
$plugin->add_mode(
    internal => 'device::hardware::health',
    spec => 'hardware-health',
    alias => undef,
    help => 'Check the status of environmental equipment (fans, temperatures, power, selftests)',
);
$plugin->add_mode(
    internal => 'device::videophone::health',
    spec => 'video-health',
    alias => ['phone-health'],
    help => 'Check the status of video/telephony',
);
$plugin->add_arg(
    spec => 'ssl',
    help => "--ssl
 A flag which tells the plugin to connect using ssl",
    required => 0,
);

$plugin->add_snmp_modes();
$plugin->add_snmp_args();
$plugin->add_default_args();

$plugin->getopts();
$plugin->classify();
$plugin->validate_args();

if (! $plugin->check_messages()) {
  $plugin->init();
  if (! $plugin->check_messages()) {
    $plugin->add_ok($plugin->get_summary())
        if $plugin->get_summary();
    $plugin->add_ok($plugin->get_extendedinfo(" "))
        if $plugin->get_extendedinfo();
  }
}
my ($code, $message) = $plugin->opts->multiline ?
    $plugin->check_messages(join => "\n", join_all => ', ') :
    $plugin->check_messages(join => ', ', join_all => ', ');
$message .= sprintf "\n%s\n", $plugin->get_info("\n")
    if $plugin->opts->verbose >= 1;

$plugin->nagios_exit($code, $message);

