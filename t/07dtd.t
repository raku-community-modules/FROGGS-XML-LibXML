use v6.c;

use Test;

# Should be 54.
#use Test::More tests => 54;
plan 57;

use XML::LibXML;
use XML::LibXML::Document;
use XML::LibXML::Dtd;

my $htmlPublic = "-//W3C//DTD XHTML 1.0 Transitional//EN";
my $htmlSystem = "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd";

{
    my $doc = XML::LibXML::Document.new;
    my $dtd = $doc.createExternalSubset( 
        "html",
        $htmlPublic,
        $htmlSystem
    );

    ok 
        $dtd.isSameNode( $doc.externalSubset ), 
        "DTD node is same as DOC''s external subset";
    is  $dtd.publicId, $htmlPublic, 
        "DTD's public ID matches \$htmlPublic";
    is  $dtd.systemId, $htmlSystem, 
        "DTD's system ID matches \$htmlSytstem";
    is  $dtd.getName, 'html', 
        "DTD name is 'html'";
}

