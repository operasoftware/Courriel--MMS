use strict;
use warnings;

package Courriel::MMS;
use namespace::autoclean;
use Moose;

extends 'Courriel';

use XWA::MIME::Util;
use Class::MOP;

my @subclasses = qw(
Courriel::MMS::MymtsRu
Courriel::MMS::TmobileUK
Courriel::MMS::TmobileUS
);


# --- Class methods ---
around 'parse' => sub {
    my $orig = shift;
    my $self = shift;
    my $email = $self->$orig( @_ );

    for my $class ( @subclasses ){
        Class::MOP::load_class( $class );
        return bless( $email, $class ) if $class->match( $email );
    }
    return $email;
};

# sub parse {
#     my $class = shift;
#     my $email = $class->SUPER::parse( @_ );
#     if ( $email->from =~ /mms\.mymts\.ru/i ){
#         require Courriel::MMS::MymtsRu;
#         return bless( $email, 'Courriel::MMS::MymtsRu' );
#     }
#     return $email;
# }

# --- Instance methods ---

sub _get_image_parts {
    my $self = shift;
    return $self->all_parts_matching( 
        sub {
            my $part = shift;
            my $mime = $part->mime_type();
            return 1 if ($mime =~ 'image/(jpeg|gif|png)');
            return;
        }
    );
}

sub get_mms_images {
    my $self = shift;
    my @result;
    for my $part ( $self->_get_image_parts ){
        my $name = $part->filename 
            // $part->disposition->get_attribute( 'name' ) 
            // $part->content_type->get_attribute( 'name' )
            // create_random_image_name( $part->mime_type );
        push @result, [ $name, $part->content ];
    }
    return @result;

}

# --- Functions ---

sub create_random_image_name {
    my ($mime_type) = @_;
    my $mime_util   = XWA::MIME::Util->new();
    my $suffix      = $mime_util->get_extension($mime_type, {must_be_media => "image"});
    my @r = ("A" .. "Z", "a" .. "z", 1 .. 9);
    my $filename = join q{}, map { $r[ rand @r ] } (1 .. 8);

    return join q{.} => ($filename, $suffix);
}

__PACKAGE__->meta()->make_immutable();

1;

__END__

=pod

=head1 NAME

Courriel::MMS - L<Courriel> extension for dealing with MMS messages

=head1 SYNOPSIS

=head1 DESCRIPTION

=head1 CLASS METHODS

=head1 INSTANCE METHODS

=head2 C<get_mms_images>

=head1 SEE ALSO

=head2 L<<< Courriel >>>

=head1 AUTHOR

Zbigniew Łukasiak, E<lt>zlukasiak@opera.comE<gt>

=head1 LICENSE AND COPYRIGHT

Copyright (c), 2011 Opera Software ASA.
All rights reserved.
