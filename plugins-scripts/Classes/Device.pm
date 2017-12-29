package Classes::Device;
our @ISA = qw(Monitoring::GLPlugin::SNMP);
use strict;

sub classify {
  my $self = shift;
  if (! ($self->opts->hostname || $self->opts->snmpwalk)) {
    $self->add_unknown('either specify a hostname or a snmpwalk file');
  } else {
    if ($self->opts->servertype && $self->opts->servertype eq 'mobotix') {
      $self->{productname} = "mobotix";
      eval "require LWP::UserAgent";
      if ($@) {
        $self->add_unknown("module LWP::UserAgent is not installed");
      }
      eval "require HTML::HeadParser";
      if ($@) {
        $self->add_unknown("module HTML::HeadParser is not installed");
      }
    } else {
      $self->check_snmp_and_model();
    }
    if (! $self->check_messages()) {
      if ($self->opts->verbose && $self->opts->verbose) {
        printf "I am a %s\n", $self->{productname};
      }
      if ($self->opts->mode =~ /^my-/) {
        $self->load_my_extension();
      } elsif ($self->{productname} =~ /mobotix/i) {
        bless $self, 'Classes::Mobotix';
        $self->debug('using Classes::Mobotix');
      } elsif ($self->implements_mib('POLYCOM-ACCESS-MANAGEMENT-MIB')) {
        bless $self, 'Classes::Polycom::RPAD';
        $self->debug('using Classes::Polycom::RPAD');
      } elsif ($self->implements_mib('POLYCOM-WEB-SUITE-MIB')) {
        bless $self, 'Classes::Polycom::WebSuite';
        $self->debug('using Classes::Polycom::WebSuite');
      } elsif ($self->implements_mib('POLYCOM-CMA-MIB')) {
        bless $self, 'Classes::Polycom::CMA';
        $self->debug('using Classes::Polycom::CMA');
      } elsif ($self->implements_mib('POLYCOM-MCU-MIB')) {
        bless $self, 'Classes::Polycom::MCU';
        $self->debug('using Classes::Polycom::MCU');
      } elsif ($self->implements_mib('UCD-SNMP-MIB')) {
        bless $self, 'Classes::UCDMIB';
        $self->debug('using Classes::Polycom::MCU');
      } else {
        if (my $class = $self->discover_suitable_class()) {
          bless $self, $class;
          $self->debug('using '.$class);
        } else {
          bless $self, 'Classes::Generic';
          $self->debug('using Classes::Generic');
        }
      }
    }
  }
  return $self;
}


package Classes::Generic;
our @ISA = qw(Classes::Device);
use strict;

sub init {
  my $self = shift;
  if ($self->mode =~ /.*/) {
    bless $self, 'Monitoring::GLPlugin::SNMP';
    $self->no_such_mode();
  }
}

