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
    is $tattr.name, $foo, 'retrieved attribute has proper name';
    # TEST
    is 
        $tattr.nodeName, "{$prefix}:{$foo}", 
        'nodeName includes proper namespace';
    # TEST
    is $tattr.value, $attvalue2, 'attribute node has proper value';

    $elem.removeAttributeNode( $tattr );
    # TEST
    ok 
        !$elem.hasAttributeNS($nsURI, $foo), 
        'namespaced attribute was properly removed';


}
