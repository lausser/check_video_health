package Classes::Mobotix::Component::EnvironmentalSubsystem;
our @ISA = qw(Monitoring::GLPlugin::SNMP::Item Classes::Mobotix);
use strict;

sub init {
  my ($self) = @_;
  $self->scrape_webpage("/control/camerainfo");
  if (exists $self->{storage}) {
    push(@{$self->{storages}},
        Classes::Mobotix::Component::EnvironmentalSubsystem::Storage->new(%{$self->{storage}}));
    delete $self->{storage};
  }
  if (exists $self->{sensors}) {
    push(@{$self->{sensorpacks}},
        Classes::Mobotix::Component::EnvironmentalSubsystem::Sensorpack->new(%{$self->{sensors}}));
    delete $self->{sensors};
  }
  if (exists $self->{image_setup}) {
    push(@{$self->{image_setups}},
        Classes::Mobotix::Component::EnvironmentalSubsystem::ImageSetup->new(%{$self->{image_setup}}));
    delete $self->{image_setup};
  }
#  printf "%s\n", Data::Dumper::Dumper($self);
}

sub check {
  my ($self) = @_;
  return if $self->check_messages();
  if ($self->mode =~ /device::uptime/) {
    bless $self, "Monitoring::GLPlugin::SNMP";
    $self->{productname} = sprintf "%s, hw: %s, sw: %s",
        $self->{networking}->{camera_name} || "-noname-",
        $self->{system}->{hardware} || "-unknown-",
        $self->{system}->{software} || "-unknown-";
    $self->dump() if $self->opts->verbose >= 2;
    $self->init();
  } elsif ($self->mode =~ /device::hardware::health/) {
    $self->SUPER::check();
  }
}


package Classes::Mobotix::Component::EnvironmentalSubsystem::Sensorpack;
our @ISA = qw(Monitoring::GLPlugin::TableItem);
use strict;

sub check {
  my ($self) = @_;
  if (exists $self->{temperature_int}) {
    $self->add_info(sprintf "internal temperature is %dC", $self->{temperature_int});
    $self->add_ok();
    $self->add_perfdata(
        label => "internal_temperature",
        value => $self->{temperature_int},
    );
  }
  if (exists $self->{temperature_amb}) {
    $self->add_info(sprintf "ambient temperature is %dC", $self->{temperature_amb});
    $self->add_ok();
    $self->add_perfdata(
        label => "ambient_temperature",
        value => $self->{temperature_amb},
    );
  }
}

package Classes::Mobotix::Component::EnvironmentalSubsystem::Storage;
our @ISA = qw(Monitoring::GLPlugin::TableItem);
use strict;

sub finish {
  my ($self) = @_;
  if (! $self->{type}) {
    bless $self, "Classes::Mobotix::Component::EnvironmentalSubsystem::Storage::Ring";
  } elsif ($self->{type} =~ /cifs/i) {
    bless $self, "Classes::Mobotix::Component::EnvironmentalSubsystem::Storage::Cifs";
  } elsif ($self->{type} =~ /sd.*flash/i) {
    bless $self, "Classes::Mobotix::Component::EnvironmentalSubsystem::Storage::SD";
  }
}

sub check {
  my ($self) = @_;
  if (exists $self->{usage}) {
    $self->add_info(sprintf "storage usage is %.2f%%", $self->{usage});
    $self->add_ok();
    $self->add_perfdata(
        label => "storage_usage",
        value => $self->{usage},
        uom => '%',
    );
  }
}

package Classes::Mobotix::Component::EnvironmentalSubsystem::Storage::Ring;
our @ISA = qw(Classes::Mobotix::Component::EnvironmentalSubsystem::Storage);
use strict;

package Classes::Mobotix::Component::EnvironmentalSubsystem::Storage::Cifs;
our @ISA = qw(Classes::Mobotix::Component::EnvironmentalSubsystem::Storage);
use strict;

sub check {
  my ($self) = @_;
  if (exists $self->{status} && $self->{status} =~ /fail/i) {
    # - mount failed!
    $self->add_info(sprintf "storage %s has status %s",
        $self->{path}, $self->{status});
    $self->add_critical();
  }
  $self->SUPER::check();
}

package Classes::Mobotix::Component::EnvironmentalSubsystem::Storage::SD;
our @ISA = qw(Classes::Mobotix::Component::EnvironmentalSubsystem::Storage);
use strict;

sub check {
  my ($self) = @_;
  if (exists $self->{wear}) {
    $self->set_thresholds(metric => 'flash_wear',
        warning => 85, critical => 95);
    $self->add_info(sprintf "sd card wear level is at %.2f%%",
        $self->{wear});
    $self->add_message($self->check_thresholds(metric => 'flash_wear', value => $self->{wear}));
  }
  $self->SUPER::check();
}

