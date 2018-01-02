package Classes::Mobotix::Component::EnvironmentalSubsystem;
our @ISA = qw(Monitoring::GLPlugin::SNMP::Item Classes::Mobotix);
use strict;

sub init {
  my $self = shift;
  my $ua = LWP::UserAgent->new;
  $ua->timeout(10);
  my $url = sprintf "http%s://%s%s/control/camerainfo",
  "",
  #($self->opts->ssl ? "s" : ""),
      $self->opts->hostname,
      ($self->opts->port != 161 ? ":".$self->opts->port : "");
  my $request = HTTP::Request::Common::GET($url);
  $self->{response} = $ua->request($request);
  $self->debug(sprintf "response code is %s", $self->{response}->code());
  if ($self->{response}->is_success) {
    $self->{content_content} = $self->{response}->decoded_content;
    $self->{content_type} = $self->{response}->header('content-type');
    $self->{content_size} = $self->{response}->header('Content-Length');
    $self->scrape_tables();
  } else {
     $self->add_unknown($self->{response}->status_line);
  }
}

sub check {
  my $self = shift;
  return if $self->check_messages();
  printf "%s\n", Data::Dumper::Dumper($self);
  if ($self->mode =~ /device::uptime/) {
    bless $self, "Monitoring::GLPlugin::SNMP";
    $self->{productname} = sprintf "%s, hw: %s, sw: %s",
        $self->{camera_name}, $self->{hardware}, $self->{software};
    $self->init();
  } elsif ($self->mode =~ /device::hardware::health/) {
    $self->add_info(sprintf "storage usage is %.2f%%", $self->{usage});
    $self->add_ok();
    $self->add_perfdata(
        label => "storage_usage",
	value => $self->{usage},
	uom => '%',
    );
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
    if (exists $self->{frame_rate}) {
      $self->add_info(sprintf "%d frames/s", $self->{frame_rate});
      $self->add_ok();
      $self->add_perfdata(
          label => "frame_rate",
	  value => $self->{frame_rate},
      );
    }
  } elsif ($self->mode =~ /device::videophone::health/) {
  } else {
    $self->add_info(sprintf 'identity status is %s', $self->{identityStatus});
  }
}

