package Classes::Polycom::CMA;
our @ISA = qw(Classes::Polycom);
use strict;

sub init {
  my $self = shift;
  if ($self->mode =~ /device::hardware::health/) {
    $self->analyze_and_check_environmental_subsystem("Classes::HOSTRESOURCESMIB::Component::EnvironmentalSubsystem");
  } elsif ($self->mode =~ /device::hardware::load/) {
    $self->analyze_and_check_cpu_subsystem("Classes::UCDMIB::Component::CpuSubsystem");
  } elsif ($self->mode =~ /device::hardware::memory/) {
    $self->analyze_and_check_mem_subsystem("Classes::UCDMIB::Component::MemSubsystem");
  } elsif ($self->mode =~ /device::videophone::health/) {
    $self->analyze_and_check_environmental_subsystem("Classes::Polycom::CMA::Component::VideoSubsystem");
  } else {
    $self->no_such_mode();
  }
}


package Monitoring::GLPlugin::SNMP::MibsAndOids::POLYCOWEBSUITEMIB;

$Monitoring::GLPlugin::SNMP::MibsAndOids::origin->{'POLYCOM-WEB-SUITE-MIB'} = {
  url => '',
  name => 'POLYCOM-ACCESS-MANAGEMENT',
};

$Monitoring::GLPlugin::SNMP::MibsAndOids::mib_ids->{'POLYCOM-WEB-SUITE-MIB'} =
    '1.3.6.1.4.1.13885.310';

