package Classes::UCDMIB;
our @ISA = qw(Classes::Device);
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

