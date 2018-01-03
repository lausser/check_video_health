package Classes::Mobotix::Component::VideoSubsystem;
our @ISA = qw(Monitoring::GLPlugin::SNMP::Item);
use strict;

sub init {
  my $self = shift;
  my $ua = LWP::UserAgent->new;
  $ua->timeout(10);
  my $url = sprintf "http%s://%s%s/record/current.jpg",
  "",
  #($self->opts->ssl ? "s" : ""),
      $self->opts->hostname,
      ($self->opts->port != 161 ? ":".$self->opts->port : "");
  $self->{response} = $ua->get($url);
  if ($self->{response}->is_success) {
    $self->{content_content} = $self->{response}->decoded_content;
  } else {
     $self->add_unknown($self->{response}->status_line);
  }
  $self->{content_type} = $self->{response}->header('content-type');
  $self->{content_size} = $self->{response}->header('Content-Length');
  delete $self->{response};
}

sub check {
  my $self = shift;
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

