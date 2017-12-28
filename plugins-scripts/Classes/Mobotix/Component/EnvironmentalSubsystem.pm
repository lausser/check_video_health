package Classes::Mobotix::Component::EnvironmentalSubsystem;
our @ISA = qw(Monitoring::GLPlugin::SNMP::Item);
use strict;

sub init {
  my $self = shift;
  # lwp
}

sub check {
  my $self = shift;
  $self->add_info(sprintf 'identity status is %s', $self->{identityStatus});
}


