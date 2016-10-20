package Classes::POLYCOMACCESSMANAGEMENTMIB::Component::EnvironmentalSubsystem;
our @ISA = qw(Monitoring::GLPlugin::SNMP::Item);
use strict;

sub init {
  my $self = shift;
  $self->get_snmp_tables('POLYCOM-ACCESS-MANAGEMENT-MIB', [
      ['nics', 'hardwareNICNICsTable', 'Classes::POLYCOMACCESSMANAGEMENTMIB::Component::EnvironmentalSubsystem::Nic'],
  ]);
  $self->get_snmp_objects('POLYCOM-ACCESS-MANAGEMENT-MIB', qw(
      identitySoftwareInfo identityDeviceType identityDeviceModel identityDeviceSerialNumber
      identityStatus serviceH323Status serviceSipStatus hardwareOverallStatus
  ));
}

sub check {
  my $self = shift;
  $self->SUPER::check();
  $self->add_info(sprintf 'identity status is %s', $self->{identityStatus});
  if ($self->{identityStatus} eq 'disabled') {
  } elsif ($self->{identityStatus} eq 'ok') {
    $self->add_ok();
  } else {
    $self->add_critical();
  }
  $self->add_info(sprintf 'h323 status is %s', $self->{serviceH323Status});
  if ($self->{serviceH323Status} eq 'disabled') {
  } elsif ($self->{serviceH323Status} eq 'ok') {
    $self->add_ok();
  } else {
    $self->add_critical();
  }
  $self->add_info(sprintf 'sip status is %s', $self->{serviceSipStatus});
  if ($self->{serviceSipStatus} eq 'disabled') {
  } elsif ($self->{serviceSipStatus} eq 'ok') {
    $self->add_ok();
  } else {
    $self->add_critical();
  }
  $self->add_info(sprintf 'hardware status is %s', $self->{hardwareOverallStatus});
  if ($self->{hardwareOverallStatus} eq 'disabled') {
  } elsif ($self->{hardwareOverallStatus} eq 'ok') {
    $self->add_ok();
  } else {
    $self->add_critical();
  }
}

package Classes::POLYCOMACCESSMANAGEMENTMIB::Component::EnvironmentalSubsystem::Nic;
our @ISA = qw(Monitoring::GLPlugin::SNMP::TableItem);
use strict;

sub check {
  my $self = shift;
  $self->add_info(sprintf 'nic %s status is %s duplex is %s',
      $self->{hardwareNICNICsName}, $self->{hardwareNICNICsStatus},
      $self->{hardwareNICNICsDuplex});
  if ($self->{hardwareNICNICsStatus} eq 'disabled') {
  } elsif ($self->{hardwareNICNICsStatus} eq 'ok') {
    $self->add_ok();
  } else {
    $self->add_critical();
  }
  if ($self->{hardwareNICNICsDuplex} ne 'full' && $self->{hardwareNICNICsStatus} ne 'disabled') {
    $self->add_warning();
  }
}


