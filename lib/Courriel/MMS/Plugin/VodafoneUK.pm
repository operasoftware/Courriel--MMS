use strict;
use warnings;

package Courriel::MMS::Plugin::VodafoneUK;
use namespace::autoclean;
use Moose;

extends 'Courriel::MMS';

# --- Class methods ---

sub match {
    my $class = shift;
    my $email = shift;

    return 1 if $email->from =~ /mms\.vodafone\.co\.uk$/;
    return;
}


# --- Instance methods ---

around 'get_mms_images' => sub {
    my $orig = shift;
    my $self = shift;

    return grep { $_->[0] !~ m#images/vf\d+\.jpg# } $self->$orig( @_ );
};

around plain_content => sub {
    my $orig = shift;
    my $self = shift;
    my $content = $self->$orig();
    return $content if defined( $content ) and length $content and $content !~ /Message text/;
    my $html = $self->html_body_part->content;
    if( $html =~ m#<td class="subject">(.*?)</td>.*?<td class="black">(.*?)</td>#s ){
        return $2;
    }
    return;
};



__PACKAGE__->meta()->make_immutable();

1;

__END__

# ABSTRACT: L<Courriel::MMS> extension for dealing with MMS messages from Vodafone UK.

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
