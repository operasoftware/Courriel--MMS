use strict;
use warnings;

package Courriel::MMS::Plugin::SprintUS;
use namespace::autoclean;
use Moose;
use WWW::Mechanize;

extends 'Courriel::MMS';

use constant DEBUG => 0;

# --- Instance methods ---

sub plain_content {
    my $self = shift;

    my $html = $self->html_body_part->content;

    my ($body) = $html =~ m#<tr>\s+<td><pre[^>]+>(.*?)</pre></td>\s+</tr>#gs;
    return $body;
}


override 'get_mms_images' => sub {
    my $self = shift;

    my @images;
    my $html = $self->html_body_part->content;
    my ( $view_url ) = $html =~ m#<a.*?href="([^"]+)"[^>]*>View (Picture|Slideshow)</a>#;
    $view_url =~ s/&amp;/&/g;
 
    my $mech = WWW::Mechanize->new();
    $mech->agent_alias( 'Windows IE 6' );
    warn "mechanizing $view_url" if DEBUG;
    $mech->get( $view_url ); # fetch this page to get session cookies
 
    if( $mech->success && $mech->ct eq 'text/html' && $mech->content =~ /mediaURL_list/ ) {
       my $content = $mech->content;
       while( $content =~ s/mediaURL_list\[(\d+)\]\s=\s"([^"]+)";// ) {
          my $id = $1; my $image_url = $2;
          $image_url =~ s/(.*?partExt=\.jpg).*$/$1/;
 
          next if $content !~ /mediaTYPE_list\[$id\]\s=\s"image";/;
 
          warn "mechanizing images; $image_url" if DEBUG;
          $mech->get( $image_url );
 
          if( $mech->success && $mech->ct =~ m#image/jpe?g# ) {
             warn "adding image$id.jpg, bytes: ". length( $mech->content ) if DEBUG;
             push @images, [ 'image'.$id.'.jpg' => $mech->content ];
          }
       }
    }
    elsif( $mech->success ) {
       my ( $image_url ) = $html =~ m#<td align="center">\s+<img src="(http://[^"]+)"/>\s+</td>#gs;  # this is the thumbnail.
       $image_url =~ s/^(.*?inviteToken=[a-zA-Z0-9]+).*$/$1/;
 
       warn "mechanizing image; $image_url" if DEBUG;
       $mech->get( $image_url ); # get the actual picture (can't use mechanize's follow_link stuff since the image is in a popup)
 
       if( $mech->success && $mech->ct =~ m#^image/jpe?g# ) {
          push @images, [ 'image.jpg' => $mech->content ];
       }
    }
 
    return @images;
};

__PACKAGE__->meta()->make_immutable();

1;

__END__

# ABSTRACT: L<Courriel::MMS> extension for dealing with MMS messages from Sprint US.

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
