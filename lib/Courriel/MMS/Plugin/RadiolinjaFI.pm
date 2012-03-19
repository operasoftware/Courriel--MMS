use strict;
use warnings;

package Courriel::MMS::Plugin::RadiolinjaFI;
use namespace::autoclean;
use Moose;

extends 'Courriel::MMS';

# --- Instance methods ---

around plain_content => sub {
    my $orig = shift;
    my $self = shift;
    my $content = $self->$orig();
    return '' if $content eq 'This is a HTML message, sorry';
    return $content;
};



__PACKAGE__->meta()->make_immutable();

1;

__END__

# ABSTRACT: L<Courriel::MMS> extension for dealing with MMS messages from Telenor SE.

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
