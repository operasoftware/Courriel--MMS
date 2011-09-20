use strict;
use warnings;

use Test::More;

use Courriel::MMS;
use Courriel::Builder;
use File::Slurp 'slurp';

{
    my $template_path = 't/data/photo-ferreiro.txt';
    open F, '<:utf8', $template_path;
    my $message = join("", <F>);
    close F;
    my $address = 'photo+qjwdepoa@my.opera.com';
    $message =~ s/\%MMSADDRESS\%/$address/go;


    my $email = Courriel::MMS->parse( text => $message );

    isa_ok( $email, 'Courriel::MMS', 'MMS' );

    my @images = $email->get_mms_images;
    is( scalar( @images ), 1, 'There are images' );
    is( $images[0][0], "Iv\x{00E1}n Ferreiro.jpeg");
}

{
    my $email = Courriel::MMS->parse( text => scalar( slurp( 't/data/MymtsRu.eml' ) ) );

    isa_ok( $email, 'Courriel::MMS::Plugin::MymtsRu', 'MMS from mms.mymts.ru' );

    my @images = $email->get_mms_images;
    is( scalar( @images ), 1, 'Logo filtered out' );

    ok( $email->create_random_image_name( 'image/jpeg' ) =~ /\.jpg$/, 'random image extension' );
}

{
    my $c_email = build_email(
        subject('aaa'),
        from('aaa@tmomail.net'),
        to( 'example@example.com' ),
        plain_body( 'test' ),
        attach( file => 't/data/cool.gif', filename => 'masthead.gif' ),
    );
    my $email = Courriel::MMS->parse( text => $c_email->as_string );
    isa_ok( $email, 'Courriel::MMS::Plugin::TmobileUS', 'MMS from tmomail.net' );
    my @images = $email->get_mms_images;
    is( scalar( @images ), 0, 'Logo filtered out' );
    is( $email->plain_content, 'test', 'plain_content' );
    is( $email->plain_content( 1 ), '', 'plain_content with mmsstrip' );
}

{
    my $c_email = build_email(
        subject('aaa'),
        from( 'aaa@pm.sprint.com' ),
        to( 'example@example.com' ),
        html_body( '<html><body><table><tr> <td><pre >some text</pre></td> </tr></table></body></html>' ),
    );
    my $email = Courriel::MMS->parse( text => $c_email->as_string );
    isa_ok( $email, 'Courriel::MMS::Plugin::SprintUS', 'MMS from sprint' );
    is( $email->plain_content, 'some text', 'plain_content extracted from html' );
}

{
    my $c_email = build_email(
        subject('Multimedia message'),
        from( 'aaa@mms.o2.ie' ),
        to( 'example@example.com' ),
        plain_body( '' ),
    );
    my $email = Courriel::MMS->parse( text => $c_email->as_string );
    isa_ok( $email, 'Courriel::MMS::Plugin::O2Ie', 'MMS from O2 Ireland' );
    is( $email->subject, '', 'subject cleared for O2Ie' );
}

{
    my $c_email = build_email(
        subject('Sie haben eine MMS erhalt'),
        from( 'aaa@mmsmail.vodafone.de' ),
        to( 'example@example.com' ),
        plain_body( 'http://www.vodafone.de' ),
        attach( mime_type => 'text/plain', content => 'some text' ),
        html_body( '<html><body><table><tr> <td><pre >some text</pre></td> </tr></table></body></html>' ),
    );
    my $email = Courriel::MMS->parse( text => $c_email->as_string );
    isa_ok( $email, 'Courriel::MMS::Plugin::VodafoneDE', 'MMS from Vodafone DE' );
    is( $email->subject, 'some text', 'subject cleared for VodafoneDE' );
    is( $email->plain_content, 'some text', 'plain_content ignored http://www.vodafone.de' );
}

{
    my $c_email = build_email(
        subject('aaa'),
        from('aaa@mms2mail.vodafone.nl'),
        to( 'example@example.com' ),
        plain_body( 'test' ),
        attach( file => 't/data/cool.gif', filename => 'met:h_left.jpg' ),
    );
    my $email = Courriel::MMS->parse( text => $c_email->as_string );
    isa_ok( $email, 'Courriel::MMS::Plugin::VodafoneNL', 'MMS from vodafone.nl' );
    my @images = $email->get_mms_images;
    is( scalar( @images ), 0, 'Logo filtered out' );
}

{
    my $c_email = build_email(
        subject('You have a PXT from aaa'),
        from( 'aaa@pxt.vodafone.net.nz' ),
        to( 'example@example.com' ),
        plain_body( 'test' ),
    );
    my $email = Courriel::MMS->parse( text => $c_email->as_string );
    isa_ok( $email, 'Courriel::MMS::Plugin::VodafoneNZ', 'MMS from Vodafone New Zealand' );
    is( $email->subject, 'test', 'subject cleared for VodafoneNZ' );
}

{
    my $c_email = build_email(
        subject('Subject'),
        from( 'aaa@mms.vodafone.co.uk' ),
        to( 'example@example.com' ),
        plain_body( 'Message text' ),
        html_body( '<td class="subject">aaa</td>bbb<td class="black">some text</td>' ),
        attach( file => 't/data/cool.gif', filename => 'images/vf00.jpg' ),
    );
    my $mtext = $c_email->as_string;
    $mtext =~ s/vf00.jpg/images\/vf00.jpg/;
    my $email = Courriel::MMS->parse( text => $mtext );
    isa_ok( $email, 'Courriel::MMS::Plugin::VodafoneUK', 'MMS from Vodafone UK' );
    is( $email->plain_content, 'some text', 'plain_content from html' );
    my @images = $email->get_mms_images;
    is( scalar( @images ), 0, 'Logo filtered out' );
}

{
    my $c_email = build_email(
        subject('Subject'),
        from( 'aaa@mms-email.telenor.se' ),
        to( 'example@example.com' ),
        html_body( "<h1>aaa</h1></div>\n<div class=\"text-400\">\nsome text\n</div>" ),
    );
    my $email = Courriel::MMS->parse( text => $c_email->as_string );
    isa_ok( $email, 'Courriel::MMS::Plugin::TelenorSE', 'MMS from Telenor SE' );
    is( $email->plain_content, 'some text', 'plain_content from html' );
}

{
    my $c_email = build_email(
        subject('MMS via e-mail'),
        from( 'aaa@mms.tele2.lt' ),
        to( 'example@example.com' ),
        plain_body( 'test' ),
    );
    my $email = Courriel::MMS->parse( text => $c_email->as_string );
    isa_ok( $email, 'Courriel::MMS::Plugin::Tele2LT', 'MMS from Tele2 Lithuania' );
    is( $email->subject, 'test', 'subject cleared for Tele2LT' );
}

{
    my $c_email = build_email(
        subject('Multimedia message'),
        from( 'aaa@mmsc.radiolinja.fi' ),
        to( 'example@example.com' ),
        plain_body( 'This is a HTML message, sorry' ),
    );
    my $email = Courriel::MMS->parse( text => $c_email->as_string );
    isa_ok( $email, 'Courriel::MMS::Plugin::RadiolinjaFI', 'MMS from Radiolinja Finland' );
    is( $email->plain_content, '', 'content cleared for Radiolinja' );
}

done_testing();

