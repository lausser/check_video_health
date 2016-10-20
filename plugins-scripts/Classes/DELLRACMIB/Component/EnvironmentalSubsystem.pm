package Classes::DELLRACMIB::Component::EnvironmentalSubsystem;
our @ISA = qw(Monitoring::GLPlugin::SNMP::Item);
use strict;

sub init {
  my $self = shift;
  foreach my $sym (keys %{$Monitoring::GLPlugin::SNMP::MibsAndOids::mibs_and_oids->{'DELL-RAC-MIB'}}) {
    if ($sym =~ /^(\w+)TableEntry/) {
      $Monitoring::GLPlugin::SNMP::MibsAndOids::mibs_and_oids->{'DELL-RAC-MIB'}->{$1.'Entry'} =
        $Monitoring::GLPlugin::SNMP::MibsAndOids::mibs_and_oids->{'DELL-RAC-MIB'}->{$sym};
    }
  }
  $self->get_snmp_tables('DELL-RAC-MIB', [
      ['powers', 'drsCMCPowerTable', 'Classes::DELLRACMIB::Component::EnvironmentalSubsystem::Power'],
      ['psus', 'drsCMCPSUTable', 'Classes::DELLRACMIB::Component::EnvironmentalSubsystem::Psu'],
      ['servers', 'drsCMCServerTable', 'Classes::DELLRACMIB::Component::EnvironmentalSubsystem::Server'],
  ]);
  $self->get_snmp_objects('DELL-RAC-MIB', qw(
      drsGlobalSystemStatus drsGlobalCurrStatus drsIOMCurrStatus
      drsKVMCurrStatus drsRedCurrStatus drsPowerCurrStatus drsFanCurrStatus
      drsBladeCurrStatus drsTempCurrStatus drsCMCCurrStatus drsChassisFrontPanelAmbientTemperature
      drsCMCAmbientTemperature drsCMCProcessorTemperature drsGlobalPrevStatus drsAlertCurrentStatus drsAlertMessage
  ));
}


package Classes::DELLRACMIB::Component::EnvironmentalSubsystem::Power;
our @ISA = qw(Monitoring::GLPlugin::SNMP::TableItem);
use strict;

package Classes::DELLRACMIB::Component::EnvironmentalSubsystem::Psu;
our @ISA = qw(Monitoring::GLPlugin::SNMP::TableItem);
use strict;

package Classes::DELLRACMIB::Component::EnvironmentalSubsystem::Server;
our @ISA = qw(Monitoring::GLPlugin::SNMP::TableItem);
use strict;


