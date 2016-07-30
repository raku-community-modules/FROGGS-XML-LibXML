use v6.c;

use Test;

# Should be 54.
#use Test::More tests => 54;

# cw: Removed 2 tests. See comments, below.
plan 52;

use XML::LibXML;
use XML::LibXML::Document;
use XML::LibXML::Dtd;
use XML::LibXML::Enums;

# -XXX- Remove!
use XML::LibXML::Subs;
use XML::LibXML::CStructs :types;

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
        "doc's internal subset is not defined after setting external subset";
    ok  $dtd.isSameNode( $doc.externalSubset ), 
        "doc's external subset is same as DTD";

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
    #my $parser = XML::LibXML.new;
    my $doc = parse-file( "example/dtd.xml" );
    ok $doc.defined, 'dtd file parsed successfully';

    my $dtd = $doc.internalSubset;
    is $dtd.getName, 'doc', 'dtd has the correct name';
    nok $dtd.publicId.defined, 'dtd has a blank public ID';
    nok $dtd.systemId.defined, 'dtd has a blank system ID';

    my  $entity = $doc.createEntityReference( "foo" );
    ok $entity.defined, 'entity reference created successfully';
    is  $entity.type, XML_ENTITY_REF_NODE, 
        'entity reference has the properl type';

    ok $entity.hasChildNodes, 'entity reference has descendants';
    is $entity.firstChild.type, XML_ENTITY_DECL,
       "entity's first child is an entity declaration";
    is $entity.firstChild.value, ' test ', 
       "entity's first child has the correct value";

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
{
    #my $parser = XML::LibXML.new;
    #$parser->validation(1);
    #$parser->keep_blanks(1);
    my $doc_str = "<?xml version='1.0'?>
<!DOCTYPE test [
 <!ELEMENT test (#PCDATA)>
]>
<test>
</test>
";
    #my $doc = parse-string($doc_str, :flags(XML_PARSE_DTDVALID));
    my $doc = parse-string(
        $doc_str, 
        :flags(XML_PARSE_DTDVALID + XML_PARSE_DTDLOAD)
    );

    if ($doc ~~ XML::LibXML::Document) {
        ok  $doc.validate, 
            'parsed document is valid according to validate()';
    } else {
        flunk 'error when parsing document'
    }

    # Skipping because is_valid is pretty much an alias for validate()
    #ok $doc->is_valid(), ' TODO : Add test name');
}
{
    #my $parser = XML::LibXML->new();
    #$parser->validation(0);
    #$parser->load_ext_dtd(0); # This should make libxml not try to get the DTD

    my $xml = '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://localhost/does_not_exist.dtd">
    <html xmlns="http://www.w3.org/1999/xhtml"><head><title>foo</title></head><body><p>bar</p></body></html>';
    my $doc;
    lives-ok {
        $doc = parse-string( $xml, :flags(XML_PARSE_DTDLOAD) );
    }, 'can parse sample XML properly...';

    isa-ok  $doc, XML::LibXML::Document, 
            '..and return a proper Document object';
}

{
    my $bad = 'example/bad.dtd';
    fail "Example file example/bad.dtd does not exist. Cannot continue with tests."
        unless $bad.IO.f;

    my $dtd_p;
    dies-ok { 
        $dtd_p = XML::LibXML::DTD.new(
            "-//Foo//Test DTD 1.0//EN", 'example/bad.dtd'
        ) 
    }, 'throws exception on bad invocation';

    my $dtd = $bad.IO.open(:bin).slurp-rest;
    fail "Example file could not be read into memory. Cannot continue with tests."
        unless $dtd.defined;    

    dies-ok { 
        $dtd_p = XML::LibXML::DTD.parse_string($dtd) 
    }, 'throws exception parsing bad file input';
    

    my $xml = "<!DOCTYPE test SYSTEM \"example/bad.dtd\">\n<test/>";

    {
        #my $parser = XML::LibXML->new;
        #$parser->load_ext_dtd(0);
        #$parser->validation(0);
        my $doc = parse-string($xml);
        isa-ok  $doc, XML::LibXML::Document, 
                'example string parsed successfully';
    }
    {
        #my $parser = XML::LibXML->new;
        #$parser->load_ext_dtd(1);
        #$parser->validation(0);
        #undef $@;
        my $doc;
        dies-ok { 
            $doc = parse-string( $xml, :flags(XML_PARSE_DTDLOAD) ); 
            $doc;
        }, 
        'parsing example string with XML_PARSE_DTDLOAD throws exception';
    }
}

{
    # RT #71076: https://rt.cpan.org/Public/Bug/Display.html?id=71076

    #my $parser = XML::LibXML->new();
    my $doc = parse-string('
<!DOCTYPE test [
 <!ELEMENT test (#PCDATA)>
 <!ATTLIST test
  attr CDATA #IMPLIED
 >
]>
<test>
</test>
');

    my $dtd = $doc.internalSubset;
    nok $dtd.hasAttributes, 'parsed DTD has no defined attributes';
    
    # cw: -YYY-
    # cw: The next test is a verification of .hasAttributes(). 
    #     Of course, attributes() will be a pain in the ass to
    #     port. I will circle back to it, later.
    #is_deeply( [ $dtd->attributes ], [], 'attributes' );
}

sub test_remove_dtd {
    my ($test_name, &remove_sub) = @_;

    #my $parser = XML::LibXML->new;
    my $doc    = parse-file('example/dtd.xml');
    my $dtd    = $doc.internalSubset;

    diag "T1 {$doc.intSubset.defined} {+$doc.intSubset.getP}";
    diag "T1a {+$doc.intSubset.getDtd.doc.getP} {+$doc.getP} {+$dtd.doc.getP}";

    &remove_sub($doc, $dtd);

    # cw: This is a gotcha. Is this due to scope limitations?
    # -XXX- Testing only. REMOVE.
    #setObjAttr($doc, '$!intSubset', xmlDtdPtr, :what(xmlDoc));

    say "IS {$doc.intSubset.defined}";

    nok $doc.internalSubset.defined, "removed DTD via {$test_name}";
    
    diag "T2 {$doc.intSubset.defined} {+$doc.intSubset.getP}";
}

test_remove_dtd( "unbindNode", sub ($doc, $dtd) {
    $dtd.unbindNode;
} );

test_remove_dtd( "removeChild",sub ($doc, $dtd) {
    $doc.removeChild($dtd);
} );

test_remove_dtd( "removeChildNodes", sub ($doc, $dtd) {
    $doc.removeChildNodes;
} );

sub test_insert_dtd {
    my ($test_name, &insert_sub) = @_;

    #my $parser  = XML::LibXML->new;
    my $src_doc = parse-file('example/dtd.xml');
    my $dtd     = $src_doc.internalSubset;
    my $doc     = parse-file('example/dtd.xml');

    &insert_sub($doc, $dtd);

    ok $doc.internalSubset.isSameNode($dtd), 
       "insert DTD via $test_name";
}

test_insert_dtd( "insertBefore internalSubset", sub ($doc, $dtd) {
    $doc.insertBefore($dtd, $doc.internalSubset);
} );
test_insert_dtd( "insertBefore documentElement", sub ($doc, $dtd) {
    $doc.insertBefore($dtd, $doc.documentElement);
} );
test_insert_dtd( "insertAfter internalSubset", sub ($doc, $dtd) {
    $doc.insertAfter($dtd, $doc.internalSubset);
} );
test_insert_dtd( "insertAfter documentElement", sub ($doc, $dtd) {
    $doc.insertAfter($dtd, $doc.documentElement);
} );
test_insert_dtd( "replaceChild internalSubset", sub ($doc, $dtd) {
    $doc.replaceChild($dtd, $doc.internalSubset);
} );
test_insert_dtd( "replaceChild documentElement", sub ($doc, $dtd) {
    $doc.replaceChild($dtd, $doc.documentElement);
} );
test_insert_dtd( "replaceNode internalSubset", sub ($doc, $dtd) {
    $doc.internalSubset.replaceNode($dtd);
} );
test_insert_dtd( "replaceNode documentElement", sub ($doc, $dtd) {
    $doc.documentElement.replaceNode($dtd);
} );
test_insert_dtd( "appendChild", sub ($doc, $dtd) {
    $doc.appendChild($dtd);
} );
test_insert_dtd( "addSibling internalSubset", sub ($doc, $dtd) {
    $doc.internalSubset.addSibling($dtd);
} );
test_insert_dtd( "addSibling documentElement", sub ($doc, $dtd) {
    $doc.documentElement.addSibling($dtd);
} );