use strict;
use warnings;

use Test::More;

use Courriel::MMS;
use Courriel::Builder;
use File::Slurp 'slurp';

my $email = Courriel::MMS->parse( text => scalar( slurp( 't/data/MymtsRu.eml' ) ) );

isa_ok( $email, 'Courriel::MMS::MymtsRu', 'MMS from mms.mymts.ru' );

my @images = $email->get_mms_images;
is( scalar( @images ), 1, 'Logo filtered out' );

ok( $email->create_random_image_name( 'image/jpeg' ) =~ /\.jpg$/, 'random image extension' );

$email = build_email(
    subject('aaa'),
    from('aaa@tmomail.net'),
    to( 'example@example.com' ),
    plain_body( 'test' ),
    attach( file => 't/data/cool.gif', filename => 'masthead.gif' ),
);
$email = Courriel::MMS->parse( text => $email->as_string );
isa_ok( $email, 'Courriel::MMS::TmobileUS', 'MMS from tmomail.net' );
@images = $email->get_mms_images;
is( scalar( @images ), 0, 'Logo filtered out' );



done_testing();

