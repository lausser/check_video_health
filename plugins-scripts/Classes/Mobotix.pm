package Classes::Mobotix;
our @ISA = qw(Classes::Device);
use strict;

{
  our $caminfos = {
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
      'Internal Temperature' => 'temperature_int',
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
      'Kameratemperatur' => 'temperature_int',
      'Umgebungstemperatur' => 'temperature_amb',
      'Helligkeit' => 'avg_brightness',
      'Akt. Bilderzeugungsrate' => 'frame_rate',
      'Aktive Clients' => 'clients',
    },
  };
  our $caminfo_values = {
    'en' => {
      'uptime' => sub { my ($txt) = @_;
          return $1*86400 + $2*3600+$3*60+$4 if $txt =~ /(\d+) Days (\d+):(\d+):(\d+)/;
          return $1*3600+$2*60+$3 if $txt =~ /(\d+):(\d+):(\d+)/;
          return $txt; },
      'statistics' => sub { my ($txt) = @_;
          my $stats = {};
          $stats->{loss} = $1 if $txt =~ /([\d\.]+)%/;
          return $stats; },
      'temperature_int' => sub { my ($txt) = @_;
          return $1 if $txt =~ /([\-\d\.]+)&deg;C/; return $txt; },
      'temperature_amb' => sub { my ($txt) = @_;
          return $1 if $txt =~ /([\-\d\.]+)&deg;C/; return $txt; },
      'frame_rate' => sub { my ($txt) = @_;
          return $1 if $txt =~ /([\d]+) B\/s/; return $txt; },
      'clients' => sub { my ($txt) = @_;
          my $stats = {};
          $stats->{live} = $1 if $txt =~ /([\d]+) Live/;
          $stats->{play} = $1 if $txt =~ /([\d]+) Wiedergabe/;
          return $stats; },
      'usage' => sub { my ($txt) = @_;
          return $1 if $txt =~ /\(([\d\.]+)%\)/; return $txt; },
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
      'temperature_int' => sub { my ($txt) = @_;
          return $1 if $txt =~ /([\-\d\.]+)&deg;C/; return $txt; },
      'temperature_amb' => sub { my ($txt) = @_;
          return $1 if $txt =~ /([\-\d\.]+)&deg;C/; return $txt; },
      'frame_rate' => sub { my ($txt) = @_;
          return $1 if $txt =~ /([\d]+) B\/s/; return $txt; },
      'clients' => sub { my ($txt) = @_;
          my $stats = {};
          $stats->{live} = $1 if $txt =~ /([\d]+) Live/;
          $stats->{play} = $1 if $txt =~ /([\d]+) Wiedergabe/;
          return $stats; },
      'usage' => sub { my ($txt) = @_;
          return $1 if $txt =~ /\(([\d\.]+)%\)/; return $txt; },
    },
  };
}

sub init {
  my $self = shift;
  $self->override_opt("username", "admin") if ! $self->opts->username;
  $self->override_opt("authpassword", "meinsm") if ! $self->opts->authpassword;
  if ($self->mode =~ /device::uptime/) {
    $self->analyze_and_check_environmental_subsystem("Classes::Mobotix::Component::EnvironmentalSubsystem");
  } elsif ($self->mode =~ /device::hardware::health/) {
    $self->analyze_and_check_environmental_subsystem("Classes::Mobotix::Component::EnvironmentalSubsystem");
  } elsif ($self->mode =~ /device::videophone::health/) {
    $self->analyze_and_check_environmental_subsystem("Classes::Mobotix::Component::VideoSubsystem");
  } else {
    $self->no_such_mode();
  }
}

sub scrape_language {
  my ($self) = @_;
  if ($self->{content_content} =~ /homepage__language="(.*)"/) {
    $self->{language} = $1;
    $self->debug('page uses language '.$self->{language});
  }
}

sub scrape_tables {
  my ($self) = @_;
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
  my $t = HTML::Parser->new(
    handlers => {
        start => [
            sub {
              my $tag  = shift;
              $inside{$tag} = 1;
              if ($tag eq 'table'){
                ++$tbl; $row = -1;
              } elsif ($tag eq 'tr' && $inside{'table'}){
                ++$row; $col = -1;
              } elsif ($tag eq 'td' && $inside{'table'}){
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
              if ($inside{'td'} && $inside{'table'}){
                $tables[$tbl][$row][$col] = $str;
              }
            },
            'text'
        ],
    }
  );
  $p->parse($self->{content_content});
  $t->parse($self->{content_content}) if ! @tables;
  $self->scrape_language();
printf "%s\n", Data::Dumper::Dumper(\@tables);
  foreach my $table (@tables) {
    foreach my $row (@{$table}) {
      next if ref($row) eq "SCALAR" and ! defined $row;
      $self->debug($row->[0]." :\t".$row->[1]);
      $self->translate($row);
    }
  }
}

sub translate {
  my ($self, $row) = @_;
  my $lang = $self->{language};
  if (exists $Classes::Mobotix::caminfos->{$lang}->{$row->[0]}) {
    my $label = $Classes::Mobotix::caminfos->{$lang}->{$row->[0]};
    if (exists $Classes::Mobotix::caminfo_values->{$lang}->{$label}) {
      $self->{$label} = $Classes::Mobotix::caminfo_values->{$lang}->{$label}($row->[1]);
      if (ref($self->{$label}) eq "HASH") {
        foreach (keys %{$self->{$label}}) {
          $self->{$label.'_'.$_} = $self->{$label}->{$_};
        }
        delete $self->{$label};
      }
    } else {
      $self->{$label} = $row->[1];
    }
  }
}

