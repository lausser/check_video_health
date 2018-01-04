package Classes::Mobotix::Component::VideoSubsystem;
our @ISA = qw(Monitoring::GLPlugin::SNMP::Item Classes::Mobotix);
use strict;

sub init {
  my $self = shift;
#  $self->scrape_webpage("/record/current.jpg");
  $self->scrape_webpage("/cgi-bin/image.jpg?error=empty");
#  $self->scrape_webpage("/cgi-bin/image.jpg?error=content");
  if (! $self->{content_type}) {
    $self->{content_type} = "unknown/unknown";
  }
}

sub check {
  my $self = shift;
  return if $self->check_messages();
  if ($self->mode =~ /device::videophone::health/) {
    $self->add_info(sprintf "image type is %s", $self->{content_type});
    $self->add_ok();
    if ($self->{content_type} !~ /(jpeg|jpg)/) {
      $self->add_critical(sprintf "received content_type %s instead of image/jpeg",
          $self->{content_type});
    } elsif (exists $self->{content_size}) {
      $self->add_info(sprintf "size is %db", $self->{content_size});
      $self->add_ok();
      $self->add_perfdata(
          label => "image_size",
	  value => $self->{content_size},
      );
      delete $self->{content_content};
    }
  }
}


package Classes::Mobotix::Component::EnvironmentalSubsystem::ImageSetup;
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

