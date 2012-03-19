use strict;
use warnings;

package Courriel::MMS::Plugin::VodafoneDE;
use namespace::autoclean;
use Moose;

extends 'Courriel::MMS';

# --- Class methods ---

sub bad_subject { $_[1] eq 'Sie haben eine MMS erhalt' }

# --- Instance methods ---

override plain_content => sub {
    my $self = shift;
    my $part = $self->first_part_matching(
        sub {
            my $part = shift;
            my $mime = $part->mime_type();
            return if $mime ne 'text/plain';
            return if $part->content =~ m#http://www.vodafone.de#;
            return 1;
        }
    );
    return $part->content if $part;
    return;
};


__PACKAGE__->meta()->make_immutable();

1;

__END__

# ABSTRACT: L<Courriel::MMS> extension for dealing with MMS messages from Vodafone DE.

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
