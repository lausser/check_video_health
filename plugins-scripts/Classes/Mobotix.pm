package Classes::Mobotix;
our @ISA = qw(Classes::Device);
use strict;
use HTML::Entities;
use Encode;

{
  our $caminfos = {
    'en' => {
      'system' => {
        'Model' => 'model',
        'Factory IP Address' => 'serial',
        'Hardware' => 'hardware',
        'Image Sensor' => 'sensor',
        'Software' => 'software',
        'Current Uptime' => 'uptime',
      },
      'networking' => {
        'Camera Name' => 'camera_name',
      },
      'storage' => {
        'Type' => 'type',
        'Path' => 'path',
        'Status' => 'status',
        'Flash Wear' => 'wear',
        'Lost Event Images' => 'lost_events',
        'Current Usage' => 'usage',
        'Max. Size' => 'max_usage',
      },
      'recording_setup' => {
        'Arm Recording' => 'recording',
      },
      'sensors' => {
        'PIR Level' => 'pir_level',
        'Illumination' => 'illumination',
        'Internal Temperature' => 'temperature_int',
      },
      'image_setup' => {
        'Average Brightness' => 'avg_brightness',
        'Current Frame Rate' => 'frame_rate',
      },
      'web_and_net_access' => {
        #'Aktive Clients' => 'clients',
      },
    },
    'de' => {
      'system' => {
        'Modell' => 'model',
        'Seriennummer' => 'serial',
        'Hardware' => 'hardware',
        'Bildsensor' => 'sensor',
        'Software Version' => 'software',
        'Laufzeit seit Neustart' => 'uptime',
      },
      'networking' => {
        'Kameraname' => 'camera_name',
        'Rechnername' => 'camera_name',
      },
      'storage' => {
        'Typ' => 'type',
        'Flash-Abnutzung' => 'wear',
        'Aktueller Speicherbedarf' => 'usage',
        'Aktueller Speicherverbrauch' => 'usage',
        'Maximalgröße' => 'max_usage',
      },
      'sensors' => {
        'PIR-Schwellwert' => 'pir_level',
        'Beleuchtung' => 'illumination',
        'Kameratemperatur' => 'temperature_int',
        'Innentemperatur' => 'temperature_int',
        'Umgebungstemperatur' => 'temperature_amb',
      },
      'image_setup' => {
        'Mittlere Helligkeit' => 'avg_brightness',
        'Akt. Bilderzeugungsrate' => 'frame_rate',
      },
      'web_and_net_access' => {
        'Aktive Clients' => 'clients',
      },
    },
    'es' => {
      'system' => {
        'Modelo' => 'model',
        'Dirección IP de Fábrica' => 'serial',
        'Hardware' => 'hardware',
        'Image Sensor' => 'sensor',
        'Software' => 'software',
        'Tiempo Operacional Actual' => 'uptime',
      },
      'networking' => {
        'Nombre de la Cámara' => 'camera_name',
      },
      'storage' => {
        'Uso Actual' => 'usage',
        'Tamaño Max.' => 'max_usage',
      },
      'sensors' => {
        'Nivel de PIR' => 'pir_level',
        'Iluminación' => 'illumination',
        'Temperatura Interna' => 'temperature_int',
      },
      'image_setup' => {
        'Brillo Medio' => 'avg_brightness',
        'Velocidad Actual' => 'frame_rate',
      },
      'web_and_net_access' => {
        '-activandos clientes-' => 'clients',
      },
    },
    'fr' => {
      'system' => {
        'Modèle' => 'model',
        'Numéro de série' => 'serial',
        'N° de série' => 'serial',
        'Matériel' => 'hardware',
        'Image Sensor' => 'sensor',
        'Capteur d\'images' => 'sensor',
        'Logiciel' => 'software',
        'Durée d\'exécution depuis le redémarrage' => 'uptime',
        'Durée d\'exécution actuelle' => 'uptime',
      },
      'networking' => {
        'Nom de la caméra' => 'camera_name',
        'Nom caméra' => 'camera_name',
      },
      'storage' => {
        'Type' => 'type',
        'Flash Wear' => 'wear',
        'Utilisation du tampon temporaire' => 'wear',
        'Espace mémoire actuellement requis' => 'usage',
        'Utilisation actuelle de la mémoire' => 'usage',
        'Taille maximum' => 'max_usage',
      },
      'recording_setup' => {
        'Activer l\'enregistrement' => 'recording', # Activé Enabled oder Désactivé(e)
      },
      'sensors' => {
        'PIR-Schwellwert' => 'pir_level',
        'Eclairage' => 'illumination',
        'Température de la caméra' => 'temperature_int',
        'todo-Umgebungstemperatur' => 'temperature_amb',
      },
      'image_setup' => {
        'Luminosité moyenne' => 'avg_brightness',
        'Luminosité' => 'avg_brightness',
        'Taux actuel de création d\'images' => 'frame_rate',
      },
      'web_and_net_access' => {
        'Active Clients' => 'clients',
        'lients actifs' => 'clients',
      },
    },

  };
  our $caminfo_tables = {
    'en' => {
      'System' => 'system',
      'Networking' => 'networking',
      'Routing' => 'routing',
      'Audio' => 'audio',
      'File Server / Flash Device' => 'storage',
      'Event and Action Setup' => 'event_action_setup',
      'Recording Setup' => 'recording_setup',
      'Sensors' => 'sensors',
      'Image Setup' => 'image_setup',
      'Web and Network Access' => 'web_and_net_access',
    },
    'de' => {
      'System' => 'system',
      'Release' => 'system',
      'Netzwerk' => 'networking',
      'Routing' => 'routing',
      'Audio' => 'audio',
      'Dateiserver / Flash-Medium' => 'storage',
      'Interner Bildspeicher' => 'storage',
      'Interner Ringpuffer' => 'storage',
      'Alarme und Aktionen' => 'event_action_setup',
      'Recording Setup' => 'recording_setup',
      'Sensoren' => 'sensors',
      'Bildeinstellungen' => 'image_setup',
      'Web- und Netzwerkzugriff' => 'web_and_net_access',
    },
    'es' => {
      'System' => 'system',
      'Red' => 'networking',
      'Enrutado' => 'routing',
      'Audio' => 'audio',
      'File Server / Flash Device' => 'storage',
      'Memoria Cíclica Interna' => 'storage',
      'Configuración de Acción y Evento' => 'event_action_setup',
      'Sensores' => 'sensors',
      'Configuración de Imagen' => 'image_setup',
      'Acceso a la Web y a la Red' => 'web_and_net_access',
    },
    'fr' => {
      'System' => 'system',
      'Système' => 'system',
      'Réseau' => 'networking',
      'Routage' => 'routing',
      'Audio' => 'audio',
      'File Server / Flash Device' => 'storage',
      'Serveur de fichiers / périphérique flash' => 'storage',
      'todo-Interner Ringpuffer' => 'storage',
      'Alarmes et actions' => 'event_action_setup',
      'Configuration des événements et actions' => 'event_action_setup',
      'Enregistrement' => 'recording_setup',
      'Configuration de l\'enregistrement' => 'recording_setup',
      'Capteurs' => 'sensors',
      'Paramètres de l\'image' => 'image_setup',
      'Configuration d\'image' => 'image_setup',
      'Accès à Internet et au réseau' => 'web_and_net_access',
      'Accès web et réseau' => 'web_and_net_access',
    },
  };
  our $caminfo_functions = {
      'lux' => sub { my ($txt) = @_;
          return $1 if $txt =~ /([\-\d\.]+).*lux/;
          return $1 if $txt =~ /([\-\d\.]+)/;
	  return undef; },
      'temperature' => sub { my ($txt) = @_;
          return $1 if $txt =~ /([\-\d\.]+).*C/;
          return $1 if $txt =~ /([\-\d\.]+)&deg;C/;
	  return $txt; },
      'frame_rate' => sub { my ($txt) = @_;
          return $1 if $txt =~ /([\d\.]+) img\/s/;
          return $1 if $txt =~ /([\d]+) B\/s/;
          return $1 if $txt =~ /([\d\.]+) Hz/;
          return $1 if $txt =~ /([\d\.]+) fps/;
          return $1 if $txt =~ /([\d\.]+) ips/;
	  return $txt; },
      'usage' => sub { my ($txt) = @_;
          return $1 if $txt =~ /\(([\d\.]+)%\)/;
          return $1 if $txt =~ /^\s*([\d\.]+)%/;
	  return $txt; },
  };
  our $caminfo_values = {
    'en' => {
      'uptime' => sub { my ($txt) = @_;
          return $1*86400 + $2*3600+$3*60+$4 if $txt =~ /(\d+) Days (\d+):(\d+):(\d+)/;
          return $1*3600+$2*60+$3 if $txt =~ /(\d+):(\d+):(\d+)/;
          return $txt; },
      'temperature_int' => $caminfo_functions->{temperature},
      'temperature_amb' => $caminfo_functions->{temperature},
      'frame_rate' => $caminfo_functions->{frame_rate},
      'clients' => sub { my ($txt) = @_;
          my $stats = {};
          $stats->{live} = $1 if $txt =~ /([\d]+) Live/;
          $stats->{play} = $1 if $txt =~ /([\d]+) Wiedergabe/;
          return $stats; },
      'usage' => $caminfo_functions->{usage},
      'pir_level' => $caminfo_functions->{usage},
      'illumination' => $caminfo_functions->{lux},
      'avg_brightness' => $caminfo_functions->{usage},
      'wear' => $caminfo_functions->{usage},
      'recording' => sub { my ($txt) = @_;
        return "enabled" if $txt eq "Enable";
        return "enabled" if $txt eq "Enabled";
        return "disabled" if $txt eq "Disabled";
        return "disabled";
      },
    },
    'de' => {
      'uptime' => sub { my ($txt) = @_;
          return $1*86400 + $2*3600+$3*60+$4 if $txt =~ /(\d+) Tage (\d+):(\d+):(\d+)/;
          return $1*3600+$2*60+$3 if $txt =~ /(\d+):(\d+):(\d+)/;
          return $txt; },
      'temperature_int' => $caminfo_functions->{temperature},
      'temperature_amb' => $caminfo_functions->{temperature},
      'frame_rate' => $caminfo_functions->{frame_rate},
      'clients' => sub { my ($txt) = @_;
          my $stats = {};
          $stats->{live} = $1 if $txt =~ /([\d]+) Live/;
          $stats->{play} = $1 if $txt =~ /([\d]+) Wiedergabe/;
          return $stats; },
      'usage' => $caminfo_functions->{usage},
      'pir_level' => $caminfo_functions->{usage},
      'illumination' => $caminfo_functions->{lux},
      'avg_brightness' => $caminfo_functions->{usage},
      'wear' => $caminfo_functions->{usage},
    },
    'es' => {
      'uptime' => sub { my ($txt) = @_;
          return $1*86400 + $2*3600+$3*60+$4 if $txt =~ /(\d+) Días (\d+):(\d+):(\d+)/;
          return $1*3600+$2*60+$3 if $txt =~ /(\d+):(\d+):(\d+)/;
          return $txt; },
      'temperature_int' => $caminfo_functions->{temperature},
      'temperature_amb' => $caminfo_functions->{temperature},
      'frame_rate' => $caminfo_functions->{frame_rate},
      'clients' => sub { my ($txt) = @_;
          my $stats = {};
          $stats->{live} = $1 if $txt =~ /([\d]+) Live/;
          $stats->{play} = $1 if $txt =~ /([\d]+) Wiedergabe/;
          return $stats; },
      'usage' => $caminfo_functions->{usage},
      'pir_level' => $caminfo_functions->{usage},
      'illumination' => $caminfo_functions->{lux},
      'avg_brightness' => $caminfo_functions->{usage},
      'wear' => $caminfo_functions->{usage},
    },
    'fr' => {
      'uptime' => sub { my ($txt) = @_;
          return $1*86400 + $2*3600+$3*60+$4 if $txt =~ /(\d+) Jours (\d+):(\d+):(\d+)/;
          return $1*3600+$2*60+$3 if $txt =~ /(\d+):(\d+):(\d+)/;
          return $txt; },
      'temperature_int' => $caminfo_functions->{temperature},
      'temperature_amb' => $caminfo_functions->{temperature},
      'frame_rate' => $caminfo_functions->{frame_rate},
      'clients' => sub { my ($txt) = @_;
          my $stats = {};
          $stats->{live} = $1 if $txt =~ /([\d]+) live/;
          $stats->{play} = $1 if $txt =~ /([\d]+) playback/;
          $stats->{live} = $1 if $txt =~ /([\d]+) chaînes en direct/;
          $stats->{play} = $1 if $txt =~ /([\d]+) chaînes de lecture/;
          return $stats; },
      'usage' => $caminfo_functions->{usage},
      'pir_level' => $caminfo_functions->{usage},
      'illumination' => $caminfo_functions->{lux},
      'avg_brightness' => $caminfo_functions->{usage},
      'wear' => $caminfo_functions->{usage},
      'recording' => sub { my ($txt) = @_;
        return "enabled" if $txt eq "Enable";
        return "enabled" if $txt eq "Enabled";
        return "enabled" if $txt eq "Activé";
        return "disabled" if $txt eq "Désactivé(e)";
        return "disabled";
      },
    },
  };
}

sub init {
  my ($self) = @_;
  $self->override_opt("username", "admin") if ! $self->opts->username;
  $self->override_opt("authpassword", "meinsm") if ! $self->opts->authpassword;
  $self->request_modules();
  if ($self->mode =~ /device::uptime/) {
    $self->analyze_and_check_environmental_subsystem("Classes::Mobotix::Component::EnvironmentalSubsystem");
  } elsif ($self->mode =~ /device::hardware::health/) {
    $self->analyze_and_check_environmental_subsystem("Classes::Mobotix::Component::EnvironmentalSubsystem");
    $self->reduce_messages_short("environmental hardware working fine");
  } elsif ($self->mode =~ /device::videophone::health/) {
    $self->analyze_and_check_environmental_subsystem("Classes::Mobotix::Component::VideoSubsystem");
  } else {
    $self->no_such_mode();
  }
}

sub request_modules {
  my ($self) = @_;
  eval "require LWP::UserAgent";
  if ($@) {
    $self->add_unknown("module LWP::UserAgent is not installed");
  }
  eval "require HTML::HeadParser";
  if ($@) {
    $self->add_unknown("module HTML::HeadParser is not installed");
  }
  eval "require HTTP::Request::Common";
  if ($@) {
    $self->add_unknown("module HTTP::Request::Common is not installed");
  }
}

sub scrape_webpage {
  my ($self, $path) = @_;
  my $ua = LWP::UserAgent->new;
  # PERL_LWP_SSL_VERIFY=0
  # my $ua = LWP::UserAgent->new(ssl_opts => { verify_hostname => 0 });
  # sonst 500
  $ua->timeout(10);
  my $url = sprintf "http%s://%s%s%s",
      #"",
      ($self->opts->ssl ? "s" : ""),
      $self->opts->hostname,
      ($self->opts->port != 161 ? ":".$self->opts->port : ""),
      $path;
  $self->debug(sprintf "request %s", $url);
  my $request = HTTP::Request::Common::GET($url);
  my $response = $ua->request($request);
  my $content = undef;
  $self->debug(sprintf "response code is %s", $response->code());
  if (! $response->is_success && ($response->code() == 401 || $response->code() == 403)) {
    $self->debug(sprintf "retry request as user %s", $self->opts->username());
    $request->authorization_basic($self->opts->username(), $self->opts->authpassword());
    $response = $ua->request($request);
  }
  if ($response->is_success) {
    $self->scrape_encoding($response->content);
    if ($self->{encoding}) {
      if ($self->{encoding} =~ /utf-8/i) {
        $self->{content_content} = $response->content();
      } else {
        #$self->{content_content} = $response->decoded_content((charset => $self->{encoding}));
        $self->{content_content} = encode_utf8($response->decoded_content());
      }
    } else {
      $self->{content_content} = $response->content;
    }
    $self->{content_type} = $response->header('content-type');
    $self->{content_size} = $response->header('Content-Length');
    $self->scrape_tables($self->{content_content});
    if ($self->opts->verbose > 15) {
      $url =~ s/\//_/g;
      $url =~ s/:/_/g;
      $url =~ s/\?.*//g;
      my $extension = $self->{content_type};
      $extension =~ s/.*\///g;
      $extension =~ s/;.*//g;
      open INFO, sprintf "> walks/camerainfo_%s_%s.%s",
          $self->{language} ? $self->{language}:"500", $url, $extension;
      print INFO $self->{content_content} if exists $self->{content_content};
      close INFO;
    }
    delete $self->{content_content};
    printf "%s\n", Data::Dumper::Dumper($self) if $self->opts->verbose > 2;
  } else {
     $self->add_unknown($response->status_line);
  }

}

sub scrape_language {
  my ($self) = @_;
  if ($self->{content_content} =~ /homepage__language="(.*)"/) {
    $self->{language} = $1;
    $self->debug('page uses language '.$self->{language});
  }
}

sub scrape_encoding {
  my ($self, $html) = @_;
  if (! defined $html) {
    $html = $self->{content_content};
  }
  if ($html =~ /Content-Type.*charset=([\w\-]+)/) {
    $self->{encoding} = $1;
    $self->debug('page uses encoding '.$self->{encoding});
  } else {
    $self->{encoding} = "utf-8";
    $self->debug('page uses encoding '.$self->{encoding});
  }
}

sub scrape_tables {
  my ($self) = @_;
  my %inside = ();
  my $tbl = -1; my $col; my $row;
  my @tables = ();
  my @tablenames = ();

  my $p = HTML::Parser->new(
    handlers => {
        start => [
            sub {
              my $tag  = shift;
              $inside{$tag} = 1;
              if ($tag eq 'tbody'){
                ++$tbl; $row = -1;
              } elsif ($tag eq 'th' && ! $inside{'tbody'}){
                $tablenames[$tbl+1] = '';
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
              $str =~ s/^(&[\w#]+?;)*//g; # &#x25BD;&#x0020;Bildeinstellungen
              if ($inside{'td'} && $inside{'tbody'}){
                $tables[$tbl][$row][$col] = $str;
              } elsif ($inside{'th'} && ! $inside{'tbody'}){
                $tablenames[$tbl+1] = $str;
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
                $tbl = 0; $row = -1;
                #++$tbl; $row = -1; die untertabellen werden hier durch th getrennt, nicht tbody wie oben
              } elsif ($tag eq 'th' && $inside{'table'}){
                ++$tbl; $row = -1;
                $tablenames[$tbl] = '';
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
              } elsif ($inside{'th'} && $inside{'table'}){
                $tablenames[$tbl] = $str;
              }
            },
            'text'
        ],
    }
  );
  $p->parse($self->{content_content});
  @tablenames = () if ! @tables;
  $t->parse($self->{content_content}) if ! @tables;
  $self->scrape_language();
  foreach my $table (@tables) {
    my $header = shift @tablenames;
    $self->debug("found table ".$header);
#printf "now table %s\n", $header;
    next if ! defined $header; # t-variante beginnt mit leerer table+undef-name
    foreach my $row (@{$table}) {
      next if ! defined $row;
      $self->debug($row->[0]." :\t".$row->[1]);
      $self->translate($header, $row);
    }
  }
}

sub translate {
  my ($self, $table, $row) = @_;
  my $lang = $self->{language};
  if (exists $Classes::Mobotix::caminfo_tables->{$lang}->{$table}) {
    $table = $Classes::Mobotix::caminfo_tables->{$lang}->{$table};
#printf "now sym %s\n", $table;
  } else {
#printf "no ! %s\n", join("___", keys %{$Classes::Mobotix::caminfo_tables->{$lang}});
  }
  if (exists $Classes::Mobotix::caminfos->{$lang}->{$table}->{$row->[0]}) {
    my $label = $Classes::Mobotix::caminfos->{$lang}->{$table}->{$row->[0]};
    if (exists $Classes::Mobotix::caminfo_values->{$lang}->{$label}) {
      $self->{$table}->{$label} = $Classes::Mobotix::caminfo_values->{$lang}->{$label}($row->[1]);
      if (ref($self->{$table}->{$label}) eq "HASH") {
        foreach (keys %{$self->{$table}->{$label}}) {
          $self->{$table}->{$label.'_'.$_} = $self->{$table}->{$label}->{$_};
        }
        delete $self->{$table}->{$label};
      } else {
        if (! defined $self->{$table}->{$label}) {
          #$self->{$table}->{$label} = "-unknown-";
        }
      }
    } else {
      $self->{$table}->{$label} = defined $row->[1] ? $row->[1] : "-unknown-";
    }
    $self->debug("scraped column ".$label);
  }
  else {
    # printf "nosuch label %s != %s\n", $row->[0], join("__", keys %{$Classes::Mobotix::caminfos->{$lang}->{$table}});
  }
}

