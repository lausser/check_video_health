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
	  #print "succes".$response->decoded_content;  # or whatever
  } else {
     printf "fail\n";
     die $response->status_line;
  }
  printf "dorsch\n";
  $self->scrape_language($response->decoded_content);
  $self->scrape_tables($response->decoded_content);
  printf "%s\n", Data::Dumper::Dumper($self);
  # lwp
  # http://www.perlmonks.org/?node_id=52180
  #
  #

}

sub check {
  my $self = shift;
  $self->add_info(sprintf 'identity status is %s', $self->{identityStatus});
}

sub scrape_language {
  my ($self, $html) = @_;
  if ($html =~ /homepage__language="(.*)"/) {
    $self->{language} = $1;
  }
}

sub scrape_tables {
  my ($self, $html) = @_;
  my %inside = ();
  my $tbl = -1; my $col; my $row;
  my @tables = ();
  
  my $p = HTML::Parser->new(
    handlers => {
    start => [
        sub {
          my $tag  = shift;
          $inside{$tag} = 1; 
          if ($tag eq 'tbody'){
            ++$tbl; $row = -1;
          } elsif ($tag eq 'tr' && $inside{'tbody'}){
            ++$row; $col = -1;
          } elsif ($tag eq 'td' && $inside{'tbody'}){
            ++$col;
            $tables[$tbl][$row][$col] = ''; # or undef
          }
        },
        'tagname'
    ],
    end => [
        sub {
          my $tag = shift;
          $inside{$tag} = 0;
        },
        'tagname'
    ],
    text => [
        sub {
          my $str = shift;
          if ($inside{'td'} && $inside{'tbody'}){
            $tables[$tbl][$row][$col] = $str;
          }
        },
        'text'
    ],      
    }
  );
  $p->parse($html); # or filename
  foreach my $table (@tables) {
    foreach my $row (@{$table}) {
      $self->translate($row);
    }
  }
}

sub translate {
  my ($self, $row) = @_;
  my $labels = {
    'de' => {
      'Modell' => 'model',
      'Seriennummer' => 'serial',
      'Hardware' => 'hardware',
      'Bildsensor' => 'sensor',
      'Software' => 'software',
      'Laufzeit seit Neustart' => 'uptime',
    },
  };
  if (exists $labels->{$self->{language}}->{$row->[0]}) {
    $self->{$labels->{$self->{language}}->{$row->[0]}} = $row->[1];
  }
}
