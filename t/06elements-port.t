# $Id$

##
# this test checks the DOM element and attribute interface of XML::LibXML

use v6.c;
use Test;

#use base qw(ParentClass);
#
#sub new {
#    my $class = shift;
#    $class = ref $class if ref $class;
#    my $self = bless {}, $class;
#    $self;
#}

#1;

# Should be 187.
#use Test::More tests => 191;
plan 187;


use XML::LibXML;

my $foo       = "foo";
my $bar       = "bar";
my $nsURI     = "http://foo";
my $prefix    = "x";
my $attname1  = "A";
my $attvalue1 = "a";
my $attname2  = "B";
my $attvalue2 = "b";
my $attname3  = "C";

# TEST:$badnames=4;
my @badnames= ("1A", "<><", "&", "-:");

# 1. bound node
{
    my $doc = XML::LibXML::Document.new();
    my $elem = $doc.createElement( $foo );
    # TEST
    ok $elem, 'created element';
    isa-ok $elem, XML::LibXML::Node, 'element belongs to proper class';
    # TEST
    is $elem.name, $foo, 'element has correct tag name';

    {
        for @badnames -> $name {
            my $te = $elem;
            my $caught = 0; 
            try {
                CATCH {
                    default {
                        ok True, "setNodeName throws an exception for $name";
                        $caught = 1;
                        # cw: We may need a way to say "resume from current scope" 
                        #     because this seems to resume execution *from the 
                        #     exact point where the exception is thrown!
                        .resume;
                        # cw: For now, the offending routine is written in a 
                        #     way where this will not matter. This may not be
                        #     true for other routines.
                    }
                }
                $te.setNodeName( $name ); 
                nok True, "setNodeName did not throw an exception for $name"
                    if $caught == 0;
            
            }
        }
    }

    $elem.setAttribute( $attname1, $attvalue1 );
    # TEST
    ok $elem.hasAttribute($attname1), 'can set an element attribute';
    # TEST
    is $elem.getAttribute($attname1), $attvalue1, 'element attribute has correct value';

    my $attr = $elem.getAttributeNode($attname1);
    # TEST
    ok $attr, 'can retrieve attribute node';
    # TEST
    is $attr.name, $attname1, 'attribute name is properly set';
    # TEST
    is $attr.value, $attvalue1, 'attribute value is properly set';

    $elem.setAttribute( $attname1, $attvalue2 );
    # TEST -14 
    is $elem.getAttribute($attname1), $attvalue2, 'retrieved correct attribute value via element';
    # TEST
    is $attr.value, $attvalue2, 'new value successfully propagated to attribute';

    # TEST - 16 
    my $attr2 = $doc.createAttribute($attname2, $attvalue1);
    # TEST
    ok $attr2, 'created attribute';

    $attr2 = $doc.createAttribute($attname2 => $attvalue1);
    ok $attr2, 'created attribute using Pair syntax';

    $elem.setAttributeNode($attr2);

    # TEST
    ok $elem.hasAttribute($attname2), 'created attribute was assigned to element';
    # TEST
    is $elem.getAttribute($attname2),$attvalue1, 'created attribute has correct value';

    my $tattr = $elem.getAttributeNode($attname2);
    # TEST - ???
    ok $tattr.isSameNode($attr2), 'getAttributeNode returns same attribute object';

    $elem.setAttribute($attname2, "");
    # TEST
    ok $elem.hasAttribute($attname2), 'can assign blank attribute';
    # TEST
    is $elem.getAttribute($attname2), "", 'attribute is truly blank';

    $elem.setAttribute($attname3, "");
    # TEST
    ok $elem.hasAttribute($attname3), 'can blank a second attribute';
    # TEST
    is $elem.getAttribute($attname3), "", 'second attribute is also blank';

    # cw: Do we really need enclosing block?
    {
        for @badnames -> $name {
            try {
                my $caught = 0;
                CATCH {
                    # TEST*$badnames
                    ok True, "setAttribute throws an exception for '$name'";
                    $caught = 1;
                    .resume;
                }
                $elem.setAttribute( $name, "X" );
                nok True, "setAttribute did not throw an exception for '$name'"
                    if $caught == 0;
            }
        }
    }

    # 1.1 Namespaced Attributes

    $elem.setAttributeNS( $nsURI, "{$prefix}:{$foo}", $attvalue2 );
    # TEST
    ok $elem.hasAttributeNS( $nsURI, $foo ), 'can set a namespaced attribute';
    # TEST
    ok 
        ! $elem.hasAttribute( $foo ), 
        'attribute node is limited to its namespace';
    # TEST
    ok 
        $elem.hasAttribute( "{$prefix}:{$foo}" ), 
        'can use hasAttribute with namespace as prefix';
    # warn $elem->toString() , "\n";
    $tattr = $elem.getAttributeNodeNS( $nsURI, $foo );
    # TEST
    ok $tattr, 'can retrieve attribute node via namespace';
    # TEST
    is 
        $tattr.localname, $foo, 
        'retrieved attribute has proper name (via localname)';
    # TEST
    is 
        $tattr.name, "{$prefix}:{$foo}", 
        'name includes proper namespace';
    # TEST
    is $tattr.value, $attvalue2, 'attribute node has proper value';

    $elem.removeAttributeNode( $tattr );
    # TEST
    ok 
        !$elem.hasAttributeNS($nsURI, $foo), 
        'namespaced attribute was properly removed';

    # empty NS
    $elem.setAttributeNS( '', $foo, $attvalue2 );
    # TEST
    ok 
        $elem.hasAttribute( $foo ), 
        'can blank an attribute with a blank namespace';
    $tattr = $elem.getAttributeNode( $foo );
    # TEST
    ok $tattr, 'can retrieve an attribuet with a blank namespace';
    # TEST
    is 
        $tattr.localname, $foo, 
        'attribute with blank namespace has proper name';
    # TEST
    is $tattr.name, $foo, 'attribute full name is correct';
    # TEST
    # cw: I would assume this is the prefix field in struct _xmlAttribute, 
    #     but that is not defined in CStructs.pm. 
    #     
    #     Until that is rectified, we skip this test.
    #ok $tattr.namespaceURI, ' TODO : Add test name';
    # TEST
    is $tattr.value, $attvalue2, 'attribute value is correct';

    ok $elem.hasAttribute($foo), 'attribute can be found by name';
    # TEST
    ok 
        $elem.hasAttributeNS(Nil, $foo), 
        'attribute can be found by name using an undefined namespace';
    # TEST
    ok 
        $elem.hasAttributeNS('', $foo), 
        'attribute can be found by name using a blank namespace';

    $elem.removeAttributeNode( $tattr );
    # TEST
    ok 
        !$elem.hasAttributeNS('', $foo), 
        'attribute shown as removed with blank namespace';
    # TEST
    ok  
        !$elem.hasAttributeNS(Nil, $foo), 
        'attribute shown as removed with undefined namespace';

    # node based functions
    my $e2 = $doc.createElement($foo);
    $doc.setDocumentElement($e2);
    my $nsAttr = $doc.createAttributeNS( 
        "{$nsURI}.x", "{$prefix}:{$foo}", $bar
    );
    # TEST
    ok $nsAttr.defined, 'created dotted attribute with namespace';
    $elem.setAttributeNodeNS($nsAttr);
    # TEST
    ok 
        $elem.hasAttributeNS( "{$nsURI}.x", $foo ), 
        'found dotted, namespaced attribute in element';
    $elem.removeAttributeNS( "{$nsURI}.x", $foo );
    # TEST
    ok !$elem.hasAttributeNS("{$nsURI}.x", $foo), 
        'can remove dotted attribute from element';

}
