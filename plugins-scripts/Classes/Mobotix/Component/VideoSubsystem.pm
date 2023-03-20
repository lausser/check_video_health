package Classes::Mobotix::Component::VideoSubsystem;
our @ISA = qw(Monitoring::GLPlugin::SNMP::Item Classes::Mobotix);
use strict;

sub init {
  my $self = shift;
#  $self->scrape_webpage("/record/current.jpg");
  $self->scrape_webpage("/cgi-bin/image.jpg?error=empty");
#  $self->scrape_webpage("/cgi-bin/image.jpg?error=content");
  $self->{video_content_type} = $self->{content_type} ?
      $self->{content_type} : "unknown/unknown";
  $self->{video_content_size} = $self->{content_size} ?
      $self->{content_size} : 0;
  $self->scrape_webpage("/control/camerainfo");
  if (exists $self->{image_setup}) {
    push(@{$self->{image_setups}},
        Classes::Mobotix::Component::VideoSubsystem::ImageSetup->new(%{$self->{image_setup}}));
    delete $self->{image_setup};
  }
  if (exists $self->{recording_setup}) {
    push(@{$self->{recording_setups}},
        Classes::Mobotix::Component::VideoSubsystem::RecordingSetup->new(%{$self->{recording_setup}}));
    delete $self->{recording_setup};
  }
}

sub check {
  my $self = shift;
  return if $self->check_messages();
  if ($self->mode =~ /device::videophone::health/) {
    $self->SUPER::check();
    $self->add_info(sprintf "image type is %s", $self->{video_content_type});
    $self->add_ok();
    if ($self->{video_content_type} !~ /(jpeg|jpg)/) {
      $self->add_critical(sprintf "received content_type %s instead of image/jpeg",
          $self->{video_content_type});
    } elsif (exists $self->{video_content_size}) {
      $self->add_info(sprintf "size is %db", $self->{video_content_size});
      $self->add_ok();
      $self->add_perfdata(
          label => "image_size",
	  value => $self->{video_content_size},
      );
      delete $self->{content_content};
    }
  }
}


package Classes::Mobotix::Component::VideoSubsystem::ImageSetup;
our @ISA = qw(Monitoring::GLPlugin::TableItem);
use strict;

sub check {
  my ($self) = @_;
  if (exists $self->{frame_rate}) {
    $self->add_info(sprintf "%d frames/s", $self->{frame_rate});
    $self->add_ok();
    $self->add_perfdata(
        label => "frame_rate",
        value => $self->{frame_rate},
    );
  }
}

package Classes::Mobotix::Component::VideoSubsystem::RecordingSetup;
our @ISA = qw(Monitoring::GLPlugin::TableItem);
use strict;

sub check {
  my ($self) = @_;
  if (exists $self->{recording}) {
    $self->add_info(sprintf "recording is %s", $self->{recording});
    if ($self->{recording} eq "enabled") {
      $self->add_ok();
    } else {
      $self->add_critical_mitigation();
    }
  }
}

