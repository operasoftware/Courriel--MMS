package Courriel::MMS::Factory;
use Moose;
use JSON;
use File::Slurp 'slurp';
use Courriel::MMS;
use Module::Pluggable search_path => 'Courriel::MMS::Plugin', require => 1;
use Data::Dumper;

has 'source_file' => ( is => 'ro', required => 1 ); 
has 'providers'   => (
    is      => 'ro',
    traits  => ['Hash'],
    handles => { get_provider => 'get' },
    lazy_build => 1,
);

sub _build_providers { decode_json slurp shift->source_file; }

sub BUILD { shift->plugins }

sub parse {
    my $self = shift;
    my $email    = Courriel::MMS->parse(@_);
    my $provider = $self->get_provider($email->from->host);
    if ($provider) {
        return $provider->rebless($email);
    }
    return $email;
}

__PACKAGE__->meta()->make_immutable();

1;
