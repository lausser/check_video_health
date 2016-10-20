package Classes::Polycom::CMA::Component::VideoSubsystem;
our @ISA = qw(Monitoring::GLPlugin::SNMP::Item);
use strict;

sub init {
  my $self = shift;
  foreach my $sym (keys %{$Monitoring::GLPlugin::SNMP::MibsAndOids::mibs_and_oids->{'POLYCOM-CMA-MIB'}}) {
    if ($sym =~ /^(\w+)TableEntry/) {
      $Monitoring::GLPlugin::SNMP::MibsAndOids::mibs_and_oids->{'POLYCOM-CMA-MIB'}->{$1.'Entry'} =
        $Monitoring::GLPlugin::SNMP::MibsAndOids::mibs_and_oids->{'POLYCOM-CMA-MIB'}->{$sym};
    }
  }
  $self->get_snmp_tables('POLYCOM-CMA-MIB', [
      ['features', 'cmaConfigLicenseFeatureTable', 'Classes::Polycom::CMA::Component::VideoSubsystem::Feature'],
      ['endpoints', 'cmaEndpointStatusTable', 'Classes::Polycom::CMA::Component::VideoSubsystem::Endpoint'],
      ['rpads', 'cmaRpadStatusTable', 'Classes::Polycom::CMA::Component::VideoSubsystem::Rpad'],
      ['alerts', 'cmaSystemAlertTable', 'Classes::Polycom::CMA::Component::VideoSubsystem::Alert'],
  ]);
  $self->get_snmp_objects('POLYCOM-CMA-MIB', qw(
      cmaConfigSoftwareVersion cmaConfigCMADMacSoftwareVersion cmaConfigCMADShippedSoftwareVersion
      cmaConfigCMADMacShippedSoftwareVersion cmaConfigHardwareVersion
      cmaConfigLicenseExpirationDays cmaConfigLicenseStatus
      cmaLicenseSeatCount cmaLicenseSeatsInUse
      cmaStatusDevice cmaStatusDeviceMCU
  ));
}

sub check {
  my $self = shift;
  if ($self->{cmaConfigLicenseExpirationDays} == -1) {
    $self->add_info('license will not expire soon');
    $self->add_ok();
  } else {
    $self->add_info(sprintf 'license will expire in %d days',
        $self->{cmaConfigLicenseExpirationDays});
    $self->add_warning();
  }
  $self->add_info(sprintf '%d of %d licenses are in use',
      $self->{cmaLicenseSeatsInUse}, $self->{cmaLicenseSeatCount});
  $self->add_ok();
}

package Classes::Polycom::CMA::Component::VideoSubsystem::Feature;
our @ISA = qw(Monitoring::GLPlugin::SNMP::TableItem);
use strict;

sub finish {
  my $self = shift;
  $self->{activatedDateHuman} = scalar localtime $self->{activatedDate};
  $self->{expirationDateHuman} = scalar localtime $self->{expirationDate};
}

package Classes::Polycom::CMA::Component::VideoSubsystem::Endpoint;
our @ISA = qw(Monitoring::GLPlugin::SNMP::TableItem);
use strict;

package Classes::Polycom::CMA::Component::VideoSubsystem::Rpad;
our @ISA = qw(Monitoring::GLPlugin::SNMP::TableItem);
use strict;

package Classes::Polycom::CMA::Component::VideoSubsystem::Alert;
our @ISA = qw(Monitoring::GLPlugin::SNMP::TableItem);
use strict;

sub finish {
  my $self = shift;
  $self->{cmaSystemAlertNotes} = $self->unhex_octet_string($self->{cmaSystemAlertNotes});
}

