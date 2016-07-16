use v6.c;

use Test;

# Should be 54.
#use Test::More tests => 54;
plan 57;

use XML::LibXML;
use XML::LibXML::Document;
use XML::LibXML::Dtd;
use XML::LibXML::Enums;

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
        "doc's external subset is not defined after setting internal subset";
    ok  $dtd.isSameNode( $doc.internalSubset ), 
        "DTD is same as DOC's internal subset";

    my $dtd2 = $doc.createDTD( 
        "huhu",
        "-//W3C//DTD XHTML 1.0 Transitional//EN",
        "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd"
    );

    $doc.setInternalSubset( $dtd2 );
    ok  $doc.internalSubset.defined,
        "doc internal subset was assigned correctly";
    nok $dtd.parentNode.defined, 
        "original DTD node was orphaned when DOC's internal subset was re-assigned";
    ok  $dtd2.isSameNode( $doc.internalSubset ), 
        "new DTD node is same as DOC's internal subset";

    my $dtd3 = $doc.removeInternalSubset;
    ok  $dtd3.isSameNode($dtd2), 
        "removed internal subset is the same as \$dtd2";
    nok $doc.internalSubset.defined, 
        'doc no longer has an internal subset';

    $doc.setExternalSubset( $dtd2 );
    ok  $doc.externalSubset,
        "doc external subset was assigned correctly";
    $dtd3 = $doc.removeExternalSubset;
    ok $dtd3.isSameNode($dtd2), 
       "removed external subset is the same as \$dtd2";
    nok $doc.externalSubset.defined, 
        "doc no longer has an external subset";
}
{
    my $parser = XML::LibXML.new;
    my $doc = $parser.parse-file( "example/dtd.xml" );
    ok $doc.defined, 'dtd file parsed successfully';

    my $dtd = $doc.internalSubset;
    is $dtd.getName, 'doc', 'dtd has the correct name';
    nok $dtd.publicId.defined, 'dtd has a blank public ID';
    nok $dtd.systemId.defined, 'dtd has a blank system ID';

    my  $entity = $doc.createEntityReference( "foo" );
    ok $entity.defined, 'entity reference created successfully';
    is  $entity.nodeType, XML_ENTITY_REF_NODE, 
        'entity reference has the properl type';

    ok $entity.hasChildNodes, 'entity reference has descendants';
    is $entity.firstChild.nodeType, XML_ENTITY_DECL,
       "entity's first child is an entity declaration";
    is $entity.firstChild.nodeValue, ' test ', 
       "entitys first child has the correct value";

    my $edcl = $entity.firstChild;
    is $edcl.previousSibling.nodeType, XML_ELEMENT_DECL, 
       "first child's previous sibling is an element declaration";

    {
        my $doc2  = XML::LibXML::Document.new;
        my $e = $doc2.createElement("foo");
        $doc2.setDocumentElement( $e );

        my $dtd2 = $doc.internalSubset.cloneNode(1);
        ok $dtd2.defined, 'node cloned successfully';

#        $doc2->setInternalSubset( $dtd2 );
#        warn $doc2->toString;

#        $e->appendChild( $entity );
#        warn $doc2->toString;
    }
}