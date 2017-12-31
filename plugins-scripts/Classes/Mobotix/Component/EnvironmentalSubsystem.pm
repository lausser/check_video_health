package Classes::Mobotix::Component::EnvironmentalSubsystem;
our @ISA = qw(Monitoring::GLPlugin::SNMP::Item);
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
  my $response = $ua->get($url);
  if ($response->is_success) {
	  #print "succes".$response->decoded_content;  # or whatever
  } else {
     $self->add_unknown($response->status_line);
  }
  $self->scrape_language($response->decoded_content);
  $self->scrape_tables($response->decoded_content);
}

sub check {
  my $self = shift;
  $self->add_info(sprintf 'identity status is %s', $self->{identityStatus});
}

sub scrape_language {
  my ($self, $html) = @_;
  if ($html =~ /homepage__language="(.*)"/) {
    $self->{language} = $1;
    $self->debug('page uses language '.$self->{language});
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
      $self->debug($row->[0]." :\t".$row->[1]);
      $self->translate($row);
    }
  }
}

sub translate {
  my ($self, $row) = @_;
  my $languages = {
    'en' => {
      'Model' => 'model',
      'Factory IP Address' => 'serial',
      'Hardware' => 'hardware',
      'Image Sensor' => 'sensor',
      'Software' => 'software',
      'Current Uptime' => 'uptime',
      'Camera Name' => 'camera_name',
      'Statistics' => 'statistics',
      'Current Usage' => 'usage',
      'Max. Size' => 'max_usage',
      'PIR Level' => 'pir_level',
      'Internal Temperature' => 'temperature',
      'Average Brightness' => 'avg_brightness',
      'Current Frame Rate' => 'frame_rate',
      #'Aktive Clients' => 'clients',
    },
    'de' => {
      'Modell' => 'model',
      'Seriennummer' => 'serial',
      'Hardware' => 'hardware',
      'Bildsensor' => 'sensor',
      'Software' => 'software',
      'Laufzeit seit Neustart' => 'uptime',
      'Kameraname' => 'camera_name',
      'Statistik' => 'statistics',
      'Aktueller Speicherbedarf' => 'usage',
      'Maximalgröße' => 'max_usage',
      'Beleuchtung' => 'pir_level',
      'Kameratemperatur' => 'temperature',
      'Helligkeit' => 'avg_brightness',
      'Akt. Bilderzeugungsrate' => 'frame_rate',
      'Aktive Clients' => 'clients',
    },
  };
  my $values = {
    'en' => {
    },
    'de' => {
      'uptime' => sub { my ($txt) = @_;
          return $1*86400 + $2*3600+$3*60+$4 if $txt =~ /(\d+) Tage (\d+):(\d+):(\d+)/;
          return $1*3600+$2*60+$3 if $txt =~ /(\d+):(\d+):(\d+)/;
	  return $txt; },
      'statistics' => sub { my ($txt) = @_;
          my $stats = {};
          $stats->{loss} = $1 if $txt =~ /([\d\.]+)%/;
	  return $stats; },
      'temperature' => sub { my ($txt) = @_;
          return $1 if $txt =~ /([\-\d\.]+)&deg;C/; return $txt; },
      'frame_rate' => sub { my ($txt) = @_;
          return $1 if $txt =~ /([\d]+) B\/s/; return $txt; },
      'clients' => sub { my ($txt) = @_;
          my $stats = {};
          $stats->{live} = $1 if $txt =~ /([\d]+) Live/;
          $stats->{play} = $1 if $txt =~ /([\d]+) Wiedergabe/;
	  return $stats; },
    },
  };
  if (exists $languages->{$self->{language}}->{$row->[0]}) {
    my $universal_label = $languages->{$self->{language}}->{$row->[0]};
    if (exists $values->{$self->{language}}->{$universal_label}) {
      $self->{$universal_label} = $values->{$self->{language}}->{$universal_label}($row->[1]);
      if (ref($self->{$universal_label}) eq "HASH") {
        foreach (keys %{$self->{$universal_label}}) {
	  $self->{$universal_label.'_'.$_} = $self->{$universal_label}->{$_};
	}
	delete $self->{$universal_label};
      }
    } else {
      $self->{$universal_label} = $row->[1];
    }
  }
}
