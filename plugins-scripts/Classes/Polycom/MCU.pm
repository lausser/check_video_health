package Classes::Polycom::MCU;
our @ISA = qw(Classes::Polycom);
use strict;

sub init {
  my $self = shift;
  if ($self->mode =~ /device::hardware::health/) {
    $self->{components}->{alarm_subsystem} = Classes::ALARMMIB::Component::AlarmSubsystem->new();
#    @{$self->{components}->{alarm_subsystem}->{alarms}} = grep {
      # accesspoint down und so interface-zeugs interessiert hier nicht, dafuer
      # gibt's die *accesspoint*- und *interface*-modes
#      $_->{alarmActiveDescription} =~ /(Temperature is out of range)|(Out of range voltage)|(failed)/ ? 1 : undef;
#    } @{$self->{components}->{alarm_subsystem}->{alarms}};
    #$self->{components}->{alarm_subsystem}->{stats}->[0]->{alarmActiveStatsActiveCurrent} = scalar(@{$self->{components}->{alarm_subsystem}->{alarms}});
    $self->check_alarm_subsystem();
  } elsif ($self->mode =~ /device::hardware::load/) {
    $self->analyze_and_check_cpu_subsystem("Classes::UCDMIB::Component::CpuSubsystem");
  } elsif ($self->mode =~ /device::hardware::memory/) {
    $self->analyze_and_check_mem_subsystem("Classes::UCDMIB::Component::MemSubsystem");
  } elsif ($self->mode =~ /device::videophone::health/) {
    $self->analyze_and_check_environmental_subsystem("Classes::Polycom::MCU::Component::VideoSubsystem");
  } else {
    $self->no_such_mode();
  }
}


package Monitoring::GLPlugin::SNMP::MibsAndOids::POLYCOMMCUMIB;

$Monitoring::GLPlugin::SNMP::MibsAndOids::origin->{'POLYCOM-MCU-MIB'} = {
  url => '',
  name => 'POLYCOM-MCU',
};

$Monitoring::GLPlugin::SNMP::MibsAndOids::mib_ids->{'POLYCOM-MCU-MIB'} =
    '1.3.6.1.4.1.13885.110';

$Monitoring::GLPlugin::SNMP::MibsAndOids::mibs_and_oids->{'POLYCOM-MCU-MIB'} = {
  'mcu-MIB' => '1.3.6.1.4.1.13885.110',
  mcuNotifications => '1.3.6.1.4.1.13885.110.0',
  mcuObjects => '1.3.6.1.4.1.13885.110.1',
  identity => '1.3.6.1.4.1.13885.110.1.1',
  identitySoftwareInfo => '1.3.6.1.4.1.13885.110.1.1.1',
  identityBuildDate => '1.3.6.1.4.1.13885.110.1.1.2',
  identityDeviceType => '1.3.6.1.4.1.13885.110.1.1.3',
  identityStatus => '1.3.6.1.4.1.13885.110.1.1.6',
  identityStatusDefinition => 'POLYCOM-MCU-MIB::identityStatus',
  identityDebugMode => '1.3.6.1.4.1.13885.110.1.1.7',
  identityConsoleAccess => '1.3.6.1.4.1.13885.110.1.1.8',
  service => '1.3.6.1.4.1.13885.110.1.2',
  serviceH323 => '1.3.6.1.4.1.13885.110.1.2.7',
  serviceH323Status => '1.3.6.1.4.1.13885.110.1.2.7.1',
  serviceH323StatusDefinition => 'POLYCOM-MCU-MIB::serviceH323Status',
  serviceSip => '1.3.6.1.4.1.13885.110.1.2.8',
  serviceSipStatus => '1.3.6.1.4.1.13885.110.1.2.8.1',
  serviceSipStatusDefinition => 'POLYCOM-MCU-MIB::serviceSipStatus',
  serviceIsdn => '1.3.6.1.4.1.13885.110.1.2.9',
  serviceIsdnStatus => '1.3.6.1.4.1.13885.110.1.2.9.1',
  serviceIsdnStatusDefinition => 'POLYCOM-MCU-MIB::serviceIsdnStatus',
  serviceSecurity => '1.3.6.1.4.1.13885.110.1.2.10',
  serviceSecurityProfile => '1.3.6.1.4.1.13885.110.1.2.10.1',
  serviceConferenceServer => '1.3.6.1.4.1.13885.110.1.2.17',
  serviceConferenceServerTotalPorts => '1.3.6.1.4.1.13885.110.1.2.17.1',
  serviceConferenceServerTotalVoicePorts => '1.3.6.1.4.1.13885.110.1.2.17.2',
  serviceConferenceServerTotalVideoPorts => '1.3.6.1.4.1.13885.110.1.2.17.3',
  serviceConferenceServerTotalPortsUsed => '1.3.6.1.4.1.13885.110.1.2.17.4',
  serviceConferenceServerPortsUsedPercentage => '1.3.6.1.4.1.13885.110.1.2.17.5',
  serviceConferenceServerTotalVoicePortsUsed => '1.3.6.1.4.1.13885.110.1.2.17.6',
  serviceConferenceServerVoicePortsUsedPercentage => '1.3.6.1.4.1.13885.110.1.2.17.7',
  serviceConferenceServerTotalVideoPortsUsed => '1.3.6.1.4.1.13885.110.1.2.17.8',
  serviceConferenceServerVideoPortsUsedPercentage => '1.3.6.1.4.1.13885.110.1.2.17.9',
  serviceConferenceServerTotalNumberActiveParticipants => '1.3.6.1.4.1.13885.110.1.2.17.10',
  hardware => '1.3.6.1.4.1.13885.110.1.3',
  hardwareOverallStatus => '1.3.6.1.4.1.13885.110.1.3.1',
  hardwareOverallStatusDefinition => 'POLYCOM-MCU-MIB::hardwareOverallStatus',
  hardwareFan => '1.3.6.1.4.1.13885.110.1.3.2',
  hardwareFanStatus => '1.3.6.1.4.1.13885.110.1.3.2.1',
  hardwareFanStatusDefinition => 'POLYCOM-MCU-MIB::hardwareFanStatus',
  hardwarePowerSupply => '1.3.6.1.4.1.13885.110.1.3.3',
  hardwarePowerSupplyStatus => '1.3.6.1.4.1.13885.110.1.3.3.1',
  hardwarePowerSupplyStatusDefinition => 'POLYCOM-MCU-MIB::hardwarePowerSupplyStatus',
  hardwareIntegratedBoard => '1.3.6.1.4.1.13885.110.1.3.4',
  hardwareIntegratedBoardStatus => '1.3.6.1.4.1.13885.110.1.3.4.1',
  hardwareIntegratedBoardStatusDefinition => 'POLYCOM-MCU-MIB::hardwareIntegratedBoardStatus',
  call => '1.3.6.1.4.1.13885.110.1.4',
  callNewCallsLastMin => '1.3.6.1.4.1.13885.110.1.4.2',
  callNewCallsLastMinTotal => '1.3.6.1.4.1.13885.110.1.4.2.1',
  callNewCallsLastMinSuccess => '1.3.6.1.4.1.13885.110.1.4.2.2',
  callNewCallsLastMinFailed => '1.3.6.1.4.1.13885.110.1.4.2.3',
  callNewCallsLastMinSuccessRatio => '1.3.6.1.4.1.13885.110.1.4.2.4',
  callEndedCallsLastMin => '1.3.6.1.4.1.13885.110.1.4.3',
  callEndedCallsLastMinSuccessRatio => '1.3.6.1.4.1.13885.110.1.4.3.1',
  callEndedCallsLastMinTotal => '1.3.6.1.4.1.13885.110.1.4.3.2',
  callEndedCallsLastMinSuccess => '1.3.6.1.4.1.13885.110.1.4.3.3',
  callEndedCallsLastMinFailed => '1.3.6.1.4.1.13885.110.1.4.3.4',
  callActiveCallsSummary => '1.3.6.1.4.1.13885.110.1.4.4',
  callActiveCallsSummaryVoice => '1.3.6.1.4.1.13885.110.1.4.4.1',
  callActiveCallsSummaryVoiceTotalCalls => '1.3.6.1.4.1.13885.110.1.4.4.1.1',
  callActiveCallsSummaryVideo => '1.3.6.1.4.1.13885.110.1.4.4.2',
  callActiveCallsSummaryVideoTotalCalls => '1.3.6.1.4.1.13885.110.1.4.4.2.1',
  conference => '1.3.6.1.4.1.13885.110.1.5',
  conferenceNumberActiveConferences => '1.3.6.1.4.1.13885.110.1.5.1',
  mcuMIBConformance => '1.3.6.1.4.1.13885.110.2',
  mcuMIBGroups => '1.3.6.1.4.1.13885.110.2.2',
};

$Monitoring::GLPlugin::SNMP::MibsAndOids::definitions->{'POLYCOM-MCU-MIB'} = {
  serviceIsdnStatus => {
    '1' => 'disabled',
    '2' => 'ok',
    '3' => 'failed',
  },
  hardwareFanStatus => {
    '1' => 'disabled',
    '2' => 'ok',
    '3' => 'failed',
  },
  hardwarePowerSupplyStatus => {
    '1' => 'disabled',
    '2' => 'ok',
    '3' => 'failed',
  },
  hardwareIntegratedBoardStatus => {
    '1' => 'disabled',
    '2' => 'ok',
    '3' => 'failed',
  },
  serviceSipStatus => {
    '1' => 'disabled',
    '2' => 'ok',
    '3' => 'failed',
  },
  serviceH323Status => {
    '1' => 'disabled',
    '2' => 'ok',
    '3' => 'failed',
  },
  hardwareOverallStatus => {
    '1' => 'disabled',
    '2' => 'ok',
    '3' => 'failed',
  },
  identityStatus => {
    '1' => 'disabled',
    '2' => 'ok',
    '3' => 'failed',
  },
};
