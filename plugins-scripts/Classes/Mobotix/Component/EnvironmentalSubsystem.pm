package Classes::Mobotix::Component::EnvironmentalSubsystem;
our @ISA = qw(Monitoring::GLPlugin::SNMP::Item);
use strict;

sub init {
  my $self = shift;
  my $ua = LWP::UserAgent->new;
  $ua->timeout(10);
  printf "ssl %s\n", Data::Dumper::Dumper($self->opts->ssl);
  printf "port %s\n", Data::Dumper::Dumper($self->opts->port);
  printf "hostname %s\n", Data::Dumper::Dumper($self->opts->hostname);
  my $url = sprintf "http%s://%s%s/control/camerainfo",
  "",
  #($self->opts->ssl ? "s" : ""),
      $self->opts->hostname,
      ($self->opts->port != 161 ? ":".$self->opts->port : "");
  printf "url %s\n", Data::Dumper::Dumper($url);
  my $response = $ua->get($url);
  #printf "response %s\n", Data::Dumper::Dumper($response);
  if ($response->is_success) {
     print "succes".$response->decoded_content;  # or whatever
  } else {
     printf "fail\n";
     die $response->status_line;
  }
  # lwp
  # http://www.perlmonks.org/?node_id=52180
}

sub check {
  my $self = shift;
  $self->add_info(sprintf 'identity status is %s', $self->{identityStatus});
}


