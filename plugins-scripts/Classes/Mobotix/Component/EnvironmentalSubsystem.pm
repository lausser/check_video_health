package MY::UserAgent;
use strict;
use warnings;
use base 'LWP::UserAgent';
 
sub get_basic_credentials {
    printf "gbc %s\n", Data::Dumper::Dumper(\@_);
    #my ($self, $realm, $url) = @_;
    
    #return 'szabgab', '**********';
}

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
  $p->parse($self->{content_content}); # or filename
  $self->scrape_language();
  foreach my $table (@tables) {
    foreach my $row (@{$table}) {
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
