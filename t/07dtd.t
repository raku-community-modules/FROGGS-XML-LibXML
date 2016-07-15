use v6.c;

use Test;

# Should be 54.
#use Test::More tests => 54;
plan 57;

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
        "DTD node is same as DOC's external subset";
    is  $dtd.publicId, $htmlPublic, 
        "DTD's public ID matches \$htmlPublic";
    is  $dtd.systemId, $htmlSystem, 
        "DTD's system ID matches \$htmlSytstem";
    is  $dtd.getName, 'html', 
        "DTD name is 'html'";
}

{
    my $doc = XML::LibXML::Document.new;
    my $dtd = $doc.createInternalSubset( 
        'html',
        $htmlPublic,
        $htmlSystem
    );
    ok  $dtd.isSameNode( $doc.internalSubset ), 
        "DTD node is same as DOC's internal subset";

    $doc.setExternalSubset( $dtd );
    nok $doc.internalSubset.defined, 
        'DOC internal subset is not defined after setting external subset';
    ok  $dtd.isSameNode( $doc.externalSubset ), 
        'DOC external subset is same as DTD';

    is  $dtd.getPublicId, $htmlPublic, 
        "DTD's public ID matches \$htmlPublic";
    is  $dtd.getSystemId, $htmlSystem, 
        "DTD's system ID matches \$htmlSystem";

    $doc.setInternalSubset( $dtd );
    nok $doc.externalSubset.defined, 
        "DOC's external subset is not defined after setting internal subset";
    ok  $dtd.isSameNode( $doc.internalSubset ), 
        "DTD is same as DOC's internal subset";

    my $dtd2 = $doc.createDTD( 
        "huhu",
        "-//W3C//DTD XHTML 1.0 Transitional//EN",
        "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd"
    );

    $doc.setInternalSubset( $dtd2 );
    ok  $doc.internalSubset,
        "DOC internal subset was assigned correctly";
    nok $dtd.parentNode.defined, 
        "Original DTD node was orphaned when DOC's internal subset was re-assigned";
    ok  $dtd2.isSameNode( $doc.internalSubset ), 
        "New DTD node is same as DOC's internal subset";


    my $dtd3 = $doc.removeInternalSubset;
    ok  $dtd3.isSameNode($dtd2), 
        "Removed internal subset is the same as \$dtd2";
    nok $doc.internalSubset.defined, 
        'DOC no longer has an internal subset';

    $doc.setExternalSubset( $dtd2 );
    ok  $doc.externalSubset,
        "DOC external subset was assigned correctly";
    $dtd3 = $doc.removeExternalSubset;
    ok $dtd3.isSameNode($dtd2), 
       "Removed external subset is the same as \$dtd2";
    nok $doc.externalSubset, 
        "DOC no longer has an external subset";
}