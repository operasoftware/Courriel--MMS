use strict;
use warnings;

package Courriel::MMS;
# use namespace::autoclean;
# unfortunately autoclean does not work with Module::Pluggable
use Moose;

extends 'Courriel';

use MIME::Types;
use Module::Pluggable require => 1;

# --- Attributes ---

has mime_types => ( is => 'ro', lazy_build => 1 );

sub _build_mime_types { MIME::Types->new() }


# --- Class methods ---
around 'parse' => sub {
    my $orig = shift;
    my $self = shift;
    my $email = $self->$orig( @_ );

    for my $class ( $email->plugins ){
        return $class->rebless( $email ) if $class->match( $email );
    }
    return $email;
};

sub rebless {
    my( $class, $email ) = @_;
    return bless $email, $class;
}

sub bad_subject {}

# --- Instance methods ---

around subject => sub {
    my $orig = shift;
    my $self = shift;
    my $subject = $self->$orig( @_ );
    if( $self->bad_subject( $subject ) ){
        $subject = '';
    }
    if( !length( $subject ) ) {
        my $plain_content = $self->plain_content;
        if( length( $plain_content ) ) { 
            ( $subject ) = $plain_content =~ /^([^\.]+\.)/g; # use the first sentence.
            if( !$subject ) {
                $subject = substr( $plain_content, 0, 25 ); # if still not subject, use some of the text
            }
        }
        else{
            my @images = $self->get_mms_images;
            if( @images ) { 
                $subject = $images[0][0]; # set subject to image filename
            }
        }
    }
    return $subject;
};


sub plain_content { 
    my $self = shift;
    my $part = $self->plain_body_part;
    return '' if !defined $part;
    return $part->content 
}

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
            // $self->create_random_image_name( $part->mime_type );
        push @result, [ $name, $part->content ];
    }
    return @result;

}

sub create_random_image_name {
    my ( $self, $mime_type ) = @_;

    # Workaround for MSIE6 sending image/pjpeg for JPEG images, wtf! 
    #   http://www.webmasterworld.com/forum88/5931.htm
    # The MIME::Types modules does not list it: 
    #   http://search.cpan.org/src/MARKOV/MIME-Types-1.20/lib/MIME/Types.pm
    # -- nicolasm 2007-09-06
    if ($mime_type eq 'image/pjpeg') {
        $mime_type = 'image/jpeg';
    }
    my $this_type  = $self->mime_types->type( $mime_type );
    return if not $this_type;
    return if $this_type->mediaType ne 'image';
    
    # Choose the first three character extension.
    my $extension;
    EXTENSION:
    for my $cur_extension ( $this_type->extensions ) {
        $extension = $cur_extension;
        last EXTENSION if length $cur_extension == 3;
    }


    my @r = ("A" .. "Z", "a" .. "z", 1 .. 9);
    my $filename = join q{}, map { $r[ rand @r ] } (1 .. 8);

    return join q{.} => ( $filename, $extension );
}

# --- Functions ---

__PACKAGE__->meta()->make_immutable();

1;

__END__

# ABSTRACT: L<Courriel> extension for dealing with MMS messages

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
