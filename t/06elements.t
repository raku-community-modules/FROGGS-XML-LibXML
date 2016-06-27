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
my $doc = XML::LibXML::Document.new();
my $elem = $doc.createElement( $foo );
# TEST
ok $elem, 'created element';
ok $elem ~~ XML::LibXML::Nodish, 'element object looks like a node';
# TEST
is $elem.name, $foo, 'element has correct tag name';

{
    for @badnames -> $name {
        my $te = $elem;
        my $caught = 0; 
        try {
            CATCH {
                default {
                    pass "setNodeName throws an exception for $name";
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
            fail "setNodeName did not throw an exception for $name"
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
                pass "setAttribute throws an exception for '$name'";
                $caught = 1;
                .resume;
            }
            $elem.setAttribute( $name, "X" );
            fail "setAttribute did not throw an exception for '$name'"
                if $caught == 0;
        }
    }
}

# 1.1 Namespaced Attributes

$elem.setAttributeNS( $nsURI, "{$prefix}:{$foo}", $attvalue2 );
# TEST
ok $elem.hasAttributeNS( $nsURI, $foo ), 'can set a namespaced attribute';
# TEST
nok 
    $elem.hasAttribute( $foo ), 
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
nok 
    $elem.hasAttributeNS($nsURI, $foo), 
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
nok 
    $elem.hasAttributeNS('', $foo), 
    'attribute shown as removed with blank namespace';
# TEST
nok  
    $elem.hasAttributeNS(Nil, $foo), 
    'attribute shown as removed with undefined namespace';

# node based functions
my $e2 = $doc.createElement($foo);
$doc.setDocumentElement($e2);
my $nsAttr = $doc.createAttributeNS( 
    "{$nsURI}.x", "{$prefix}:{$foo}", $bar
);
# TEST
ok $nsAttr, 'created attribute with XML namespace';
$elem.setAttributeNodeNS($nsAttr);

diag $elem;

# TEST
ok 
    $elem.hasAttributeNS( "{$nsURI}.x", $foo ), 
    'found attribute with XML namespace in element';

$elem.removeAttributeNS( "{$nsURI}.x", $foo );
# TEST
nok $elem.hasAttributeNS("{$nsURI}.x", $foo), 
    'can remove attribute with XML namespace from element';

$elem.setAttributeNS( $nsURI, "{$prefix}:{$attname1}", $attvalue2 );
$elem.removeAttributeNS( '', $attname1 );

# TEST
nok  
    $elem.hasAttribute($attname1), 
    "hasAttribute() should not find attribute '$attname1'";
# TEST
ok 
    $elem.hasAttributeNS( $nsURI, $attname1 ), 
    "hasAttributeNS can find attribute '$attname1'";

{
    for @badnames -> $name {
        try {
            my $caught = 0;
            CATCH {
                # TEST*$badnames
                pass "setAttributeNS throws an exception for '$name'";
                $caught = 1;
                .resume;
            }
            $elem.setAttributeNS( Nil, $name, 'X' );
            fail "setAttributeNS did not throw an exception for '$name'"
                unless $caught;
        }
    }
}

# 2. unbound node
$elem = XML::LibXML::Element.new($foo);
# TEST
isa-ok $elem, XML::LibXML::Element, 'created element object';
# TEST
is $elem.tagName, $foo, 'element is named properly';

$elem.setAttribute( $attname1, $attvalue1 );
# TEST
ok 
    $elem.hasAttribute($attname1), 
    "successfully added attribute '$attname1' to element";
# TEST
is 
    $elem.getAttribute($attname1), $attvalue1, 
    'attribute value is correct';

$attr = $elem.getAttributeNode($attname1);
# TEST
isa-ok 
    $attr, XML::LibXML::Attr, 
    "can retrieve attribute node for '$attname1'";
# TEST
is $attr.name, $attname1, 'attribute node is named correctly';
# TEST
is $attr.value, $attvalue1, 'attribute node has correct value';

$elem.setAttributeNS( $nsURI, $prefix ~ ':' ~ $foo, $attvalue2 );
# TEST
ok 
    $elem.hasAttributeNS( $nsURI, $foo ), 
    'can set attribute with namespace';
# warn $elem->toString() , "\n";
$tattr = $elem.getAttributeNodeNS( $nsURI, $foo );
# TEST
ok $tattr, 'can retrieve attribute node with namespace';
# TEST
is $tattr.localname, $foo, 'attribute node is named correclty';
# TEST
is 
    $tattr.name, $prefix ~ ':' ~ $foo, 
    'attribute node has correct proper name';
# TEST
is $tattr.value, $attvalue2, 'attribute node has correct value';

$elem.removeAttributeNode( $tattr );
# TEST
nok $elem.hasAttributeNS($nsURI, $foo), 'attribute was properly removed';
# warn $elem->toString() , "\n";

# 3. Namespace handling
# 3.1 Namespace switching
{
    my $elem = XML::LibXML::Element.new($foo);
    # TEST
    ok $elem, 'created element successfully';

    my $doc = XML::LibXML::Document.new();
    my $e2 = $doc.createElement($foo);
    $doc.setDocumentElement($e2);
    my $nsAttr = $doc.createAttributeNS( 
        $nsURI, $prefix ~ ':"' ~ $foo, $bar
    );
    # TEST
    ok $nsAttr, 'created attribute with namespace successfully';

    $elem.setAttributeNodeNS($nsAttr);
    # TEST
    ok  
        $elem.hasAttributeNS($nsURI, $foo), 
        'attribute successfully attached to element';

    # TEST
    # cw: $nsAttr was created with the document, but was then bound
    #     to $elem, which is NOT bound to a document. Therefore 
    #     ownerDocument should not be defined. (???)
    nok 
        $nsAttr.ownerDocument.defined, 
        'ownerDocument should not be defined';
    # warn $elem->toString() , "\n";
}

# 3.2 default Namespace and Attributes
{
    my $doc  = XML::LibXML::Document.new();
    my $elem = $doc.createElementNS( "foo", "root" );
    $doc.setDocumentElement( $elem );

    $elem.setNamespace( "foo", "bar" );

    $elem.setAttributeNS( "foo", "x:attr",  "test" );
    $elem.setAttributeNS( Str, "attr2",  "test" );

    # TEST

    is 
        $elem.getAttributeNS( "foo", "attr" ), "test", 
        'can retrieve proper attribute value in namespace "foo"';
    # TEST
    is  
        $elem.getAttributeNS( "", "attr2" ), "test", 
        'can retrieve proper attribute value from blank namespace';

    # warn $doc->toString;
    # actually this doesn't work correctly with libxml2 <= 2.4.23
    $elem.setAttributeNS( "foo", "attr2",  "bar" );
    # TEST
    is 
        $elem.getAttributeNS( "foo", "attr2" ), "bar", 
        'can properly reset an attribute in namespace "foo"';
    # warn $doc->toString;
}

# 4. Text Append and Normalization
# 4.1 Normalization on an Element node
{
    my $doc = XML::LibXML::Document.new();
    my $t1 = $doc.createTextNode( "bar1" );
    my $t2 = $doc.createTextNode( "bar2" );
    my $t3 = $doc.createTextNode( "bar3" );
    my $e  = $doc.createElement("foo");
    my $e2 = $doc.createElement("bar");
    $e.appendChild( $e2 );
    $e.appendChild( $t1 );
    $e.appendChild( $t2 );
    $e.appendChild( $t3 );

    my @cn = $e.childNodes;

    # this is the correct behaviour for DOM. the nodes are still
    # referred
    # TEST
    # cw: This test doesn't look relevant anymore as the text nodes 
    #     already appear to be normalized.
    #is @cn.elems, 4, 'created element has correct number of children';
    #
    #$e.normalize;

    @cn = $e.childNodes;
    # TEST
    is 
        @cn.elems, 2, 
        'element has correct number of children after elem normalization';

    # TEST
    #nok $t2.parentNode.defined, '2nd text node has no parent';
    # TEST
    #nok $t3.parentNode.defined, '3rd text node has no parent';
}

# 4.2 Normalization on a Document node
{
    my $doc = XML::LibXML::Document.new();
    my $t1 = $doc.createTextNode( "bar1" );
    my $t2 = $doc.createTextNode( "bar2" );
    my $t3 = $doc.createTextNode( "bar3" );
    my $e  = $doc.createElement("foo");
    my $e2 = $doc.createElement("bar");
    $doc.setDocumentElement($e);
    $e.appendChild( $e2 );
    $e.appendChild( $t1 );
    $e.appendChild( $t2 );
    $e.appendChild( $t3 );

    # this is the correct behaviour for DOM. the nodes are still
    # referred
    # TEST
    #is 
    #    $e.childNodes.elems, 4, 
    #    'element has corrent number of children before normalization';
    #$doc.normalize;

    # TEST
    is
         $e.childNodes.elems, 2, 
         'element has correct number of children after doc normalization';

    # TEST
    #nok $t2.parentNode.defined, ' TODO : Add test name');
    # TEST
    #nok $t3.parentNode.defined, ' TODO : Add test name');
}

# 5. XML::LibXML extensions
{
    my $plainstring = "foo";
    my $stdentstring= "$foo \& this";

    my $doc = XML::LibXML::Document.new();
    my $elem = $doc.createElement( $foo );
    $doc.setDocumentElement( $elem );

    $elem.appendText( $plainstring );
    # TEST
    is
        $elem.string_value , $plainstring, 
        'element has correct string_value';

    $elem.appendText( $stdentstring );
    # TEST
    is 
        $elem.string_value, $plainstring ~ $stdentstring, 
        'text was properly appended to element text';

    $elem.appendTextChild( "foo" );
    $elem.appendTextChild( "foo" => "foo\&bar" );

    my @cn = $elem.childNodes;
    # TEST
    #ok( scalar(@cn), ' TODO : Add test name' );
    # TEST
    is 
        @cn.elems, 3, 
        'element has correct number of children';
    # TEST
    nok @cn[1].hasChildNodes, 'second child has no descendants';
    # TEST
    # cw: Missing text node as descendant.
    ok  @cn[2].hasChildNodes, 'third child has descendants';
    # TEST (new) - See if two methods of counting children agree.
    # cw: -XXX- Is this a fair test? Why does it fail?
    ok  
        @cn[2].childNodes.elems == @cn[2].elems,
        'child count between perl6 and libxml2 agree';
}

# 6. XML::LibXML::Attr nodes
{
    my $dtd = q:to"EOF";
<!DOCTYPE root [
<!ELEMENT root EMPTY>
<!ATTLIST root fixed CDATA  #FIXED "foo">
<!ATTLIST root a:ns_fixed CDATA  #FIXED "ns_foo">
<!ATTLIST root name NMTOKEN #IMPLIED>
<!ENTITY ent "ENT">
]>
EOF

    my $ns = 'urn:xx';
    my $xml_nons = '<root foo="&quot;bar&ent;&quot;" xmlns:a="$ns"/>';
    my $xml_ns = '<root xmlns="$ns" xmlns:a="$ns" foo="&quot;bar&ent;&quot;"/>';

    # TEST:$xml=2;
    for ($xml_nons, $xml_ns) -> $xml {
        my $parser = XML::LibXML.new;
        # cw: NYI?
        #$parser.complete_attributes(0);
        $parser.replace-entities = 0;
        #$parser.expand_entities(0);
        my $doc = $parser.parse-string($dtd ~ $xml);
        my $nsorno = $xml eq $xml_nons ?? 'No NS' !! 'NS';

        # TEST*$xml

        ok $doc.defined, 'successfully parsed document';
        my $root = $doc.getDocumentElement;
        {
            my $attr = $root.getAttributeNode('foo');
            # TEST*$xml
            ok $attr, "[{$nsorno}] successfully retrieved attribute node";
            # TEST*$xml
            isa-ok 
                $attr, XML::LibXML::Attr, 
                "[{$nsorno}] attribute node is typed correctly";
            # TEST*$xml
            ok 
                $root.isSameNode($attr.ownerElement), 
                "[{$nsorno}] root and attribute nodes are the same";
            # TEST*$xml
            is 
                $attr.value, '"barENT"', 
                "[{$nsorno}] attribute has the correct value";
            # TEST*$xml
            is 
                #$attr.serializeContent, '&quot;bar&ent;&quot;', 
                $attr.getContent(), '&quot;bar&ent;&quot;',
                "[{$nsorno}] attribute value can be serialized properly";
            # TEST*$xml
            is 
                $attr.toString, ' foo="&quot;bar&ent;&quot;"', 
                "[{$nsorno}] attribute can be cast to string correctly";
        }
        {
            my $attr = $root.getAttributeNodeNS(Str, 'foo');
            # TEST*$xml
            ok 
                $attr.defined, 
                'successfully retrieved attribute with undefined namespace';
            # TEST*$xml
            isa-ok $attr, XML::LibXML::Attr, 'attributre has correct type';
            # TEST*$xml
            ok 
                $root.isSameNode($attr.ownerElement), 
                'attribute root node is the document root';
            # TEST*$xml
            is $attr.value, '"barENT"', 'attribute has correct value';
        }

        is 
            $root.getAttributeNS($ns, 'ns_fixed'), 'ns_foo', 
            'ns_fixed is ns_foo';

    }
}