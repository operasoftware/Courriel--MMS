use strict;
use warnings;

package Courriel::MMS::Plugin::MymtsRu;
use namespace::autoclean;
use Moose;

extends 'Courriel::MMS';

# --- Class methods ---

sub match {
    my( $class, $email ) = @_;

    return 1 if $email->from =~ /mms\.mymts\.ru$/i;
    return;
}

# --- Instance methods ---

around '_get_image_parts' => sub {
    my $orig = shift;
    my $self = shift;
    my @images;
    for my $image ( $self->$orig( @_ ) ){
        my( $content_id ) = $image->headers()->get_values( 'Content-ID' );
        push @images, $image if !defined( $content_id ) || $content_id !~ /mts_logo/;
    }
    return @images;
};

__PACKAGE__->meta()->make_immutable();

1;

__END__

# ABSTRACT: L<Courriel::MMS> extension for dealing with MMS messages from mms.mymts.ru

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
