use strict;
use warnings;

package Courriel::MMS::Plugin::O2Ie;
use namespace::autoclean;
use Moose;

extends 'Courriel::MMS';

# --- Class methods ---

sub match {
    my $class = shift;
    my $email = shift;

    return 1 if $email->from =~ /mms\.o2\.ie/;
    return;
}

sub bad_subject { $_[1] eq 'Multimedia message' }

# --- Instance methods ---

__PACKAGE__->meta()->make_immutable();

1;

__END__

# ABSTRACT: L<Courriel::MMS> extension for dealing with MMS messages from O2 Ireland.

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
