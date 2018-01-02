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
}

sub check {
  my $self = shift;
  if ($self->mode =~ /device::videophone::health/) {
    $self->add_info(sprintf "image type is %s", $self->{content_type});
    $self->add_ok();
    if ($self->{content_type} !~ /(jpeg|jpg)/) {
  printf "%s\n", Data::Dumper::Dumper($self);
      $self->add_critical(sprintf "received content_type %s instead of image/jpeg",
          $self->{content_type});
	  printf "%s\n", Data::Dumper::Dumper($self->{content_content});
    } elsif (exists $self->{content_size}) {
      $self->add_info(sprintf "size is %db", $self->{content_size});
      $self->add_ok();
      $self->add_perfdata(
          label => "image_size",
	  value => $self->{content_size},
      );
    }
  }
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
