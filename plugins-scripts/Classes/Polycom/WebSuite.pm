package Classes::Polycom::WebSuite;
our @ISA = qw(Classes::Polycom);
use strict;

sub init {
  my $self = shift;
  if ($self->mode =~ /device::hardware::health/) {
    if ($self->implements_mib('HOST-RESOURCES-MIB')) {
      $self->analyze_and_check_environmental_subsystem("Classes::HOSTRESOURCESMIB::Component::EnvironmentalSubsystem");
    }
#    $self->analyze_and_check_environmental_subsystem("Classes::POLYCOMACCESSMANAGEMENTMIB::Component::EnvironmentalSubsystem");
  } elsif ($self->mode =~ /device::hardware::load/) {
    $self->analyze_and_check_cpu_subsystem("Classes::UCDMIB::Component::CpuSubsystem");
  } elsif ($self->mode =~ /device::hardware::memory/) {
    $self->analyze_and_check_mem_subsystem("Classes::UCDMIB::Component::MemSubsystem");
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

