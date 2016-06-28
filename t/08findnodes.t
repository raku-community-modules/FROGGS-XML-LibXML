use v6.c;
use Test;

plan 37;

use XML::LibXML;
use XML::LibXML::CStructs :types;
use XML::LibXML::Document;
use XML::LibXML::Element;
use XML::LibXML::Enums;
use XML::LibXML::Node;
use XML::LibXML::Text;

use NativeCall;

# to test if findnodes works.
# i added findnodes to the node class, so a query can be started
# everywhere.

# For Perl6, findnodes has been changed to find(), but will be aliased for
# drop in compatibility.

my $file    = "example/dromeds.xml";

# cw: To get the proper objects, must use exported subs. If the object
#     method is to be supported, we need to look at adding methods
#     to XML:;LibXML, however it is subclassed to XML::LibXML::Parser
#my $parser = XML::LibXML.new();
my $dom    = parse-file( $file );

if $dom.defined {
    # get the root document
    my $elem   = $dom.getDocumentElement();

    # first very simple path starting at root
    my @list   = $elem.find( "species" );
    ok 
        @list.defined && @list.elems == 3, 
        'found the right number of elements ';

    my @list2 = $elem.findnodes( 'species' );
    ok
        @list2.defined && 
        # cw: Can't deep compare these since data structures recurse!
        #     so we are limited to just comparing the number of elements.
        #     Or better yet, writing our own compare op.
        @list.elems == @list2.elems,
        'alias to findnodes works';

    # a simple query starting somewhere ...
    my $node = @list[0];
    my @slist = $node.find( "humps" );
    is @slist.elems, 1, 'find from element level works properly';

    # find a single node
    @list   = $elem.find( "species[\@name='Llama']" );
    is @list.elems, 1, 'find using attribute works properly';

    # find with not conditions
    @list   = $elem.find( "species[\@name!='Llama']/disposition" );
    is @list.elems, 2, 'find using negated attribute spec works properly';

    @list = $elem.find( 'species/@name' );
    ok 
        @list.elems && @list[0].Str eq ' name="Camel"', 
        'attribute retrieval via find() works properly';

    my $x = XML::LibXML::Text.new( 1234 );
    ok 
        $x.defined && $x.getData() eq "1234", 
        'creation of text node was successful';

    my $telem = $dom.createElement('test');
    $telem.appendWellBalancedChunk('<b>c</b>');
    
    $x = finddoc($dom);
    ok 
        $x.defined && 
        $x ~~ List && 
        $x[0] ~~ XML::LibXML::Node, 
        'root node found in DOM $dom object';
}

# cw: Useless test?
# ok( $dom, ' TODO : Add test name' );

# test to make sure that multiple array findnodes() returns
# don't segfault perl; it'll happen after the second one if it does
for (^3) {
    my $doc = parse-string(
'<?xml version="1.0" encoding="UTF-8"?>
<?xsl-stylesheet type="text/xsl" href="a.xsl"?>
<a />');
    my @nds = $doc.find("processing-instruction('xsl-stylesheet')");
}
pass 'No segfault after multiple find() calls';

# cw: Old test failed because namespaces must be registered 
#     before find can be used.
#
#     Just noticed that the first <a:foo> tag defines both 
#     namespaces. Still...libxml2 chokes on the //a:foo 
#     and //b:bar expressions without these changes.
my $doc = parse-string('
<a:foo xmlns:a="http://foo.com" xmlns:b="http://bar.com">
 <b:bar>
  <a:foo xmlns:a="http://other.com"/>
 </b:bar>
</a:foo>
');

my $root = $doc.getDocumentElement;
# cw: I know the addition to find() might be a little ugly. However, the 
#     next tests need some mechanism of adding namespaces to work.
#
my @a = $root.find( '//a:foo', :opts( namespaces => ['a', 'http://foo.com'] ));
is @a.elems, 1, 'found single node foo in namespace a with http://foo.com URI';
# cw: Also, due to name spaces, I had to add this tests, since 
#     same namespace, but different URIs
@a = $root.find( '//a:foo', :opts( namespaces => ['a', 'http://other.com'] ));
is @a.elems, 1, 'found single node foo in namespace a with http://other.com URI';

my @b = $root.find('//b:bar', :opts( namespaces => ['b', 'http://bar.com'] ));
is @b.elems, 1, 'found node bar in namespace b';

my @none = ( $root.find('//b:foo', :opts( namespaces => ['b', 'http://bar.com'] )) );
@none.push( $root.find('//foo') );
nok @none[0].defined && @none[1].defined, 'nodes b:foo and foo were not found';

# cw: Near as I can telll, document() has been removed from libxml2
# "xmlXPathCompOpEval: function document not found"
#my @doc = $root.find('document("example/test.xml")');
#ok @doc.defined, 'find() can parse external document';
# warn($doc[0]->toString);

# this query should result an empty array!
my @nodes = $root.find( "/humpty/dumpty" );
nok @nodes, 'invalid expression properly returns no results';

my $docstring = q{
<foo xmlns="http://kungfoo" xmlns:bar="http://foo"/>
};
$doc = parse-string( $docstring );
$root = $doc.documentElement;
my @ns = $root.find('namespace::*');
# cw: For some reason this pulls out "http://www.w3.org/XML/1998/namespace"
#     which is not specified in $docstring, so it has to be added by
#     libxml2.
is @ns.elems, 3, 'found correct number of namespace:: declarations in node';

# bad xpaths
# TEST:$badxpath=4;
my @badxpath = (
    'abc:::def',
    'foo///bar',
    '...',
    '/-',
    '!@$%'
);

for @badxpath -> $xp {
    my $res;

    try $res = $root.find( $xp ); 
    nok $!, "find throws exception with expression '{$xp}'";

    try $res = $root.findvalue( $xp );
    nok $!, "findvalue throws exception with expression '{$xp}";

    # cw: Aren't these meaningless in Perl6 since it's already unicode-aware?
    #
    #try $res = $root.find( encodeToUTF8( "iso-8859-1", $xp ) );
    #nok $!, "find throws exception with UTF8 expression '{$res}'";

    #try $res = $root.find( encodeToUTF8( "iso-8859-1", $xp ) );
    #nok $!, "findvalue throws exception with UTF8 expression '{$res}";
}


{
    # as reported by jian lou:
    # 1. getElementByTagName("myTag") is not working is
    # "myTag" is a node directly under root. Same problem
    # for findNodes("//myTag")
    # 2. When I add new nodes into DOM tree by
    # appendChild(). Then try to find them by
    # getElementByTagName("newNodeTag"), the newly created
    # nodes are not returned. ...
    #
    # this seems not to be a problem by XML::LibXML itself, but newer versions
    # of libxml2 (newer is 2.4.27 or later)
    #
    my $doc = XML::LibXML::Document.new();
    my $root = $doc.createElement( "A" );
    $doc.setDocumentElement($root);

    my $b = $doc.createElement( "B" );
    $root.appendChild( $b );
    ok $b.defined, 'created node B as $b';

    my @list = $doc.find( '//A' );
    ok @list, 'found procedurally created node A...';
    ok @list[0].isSameNode( $root ), '...and node has proper root';

    @list = $doc.find( '//B' );
    ok @list, 'found node B ...';
    ok @list[0].isSameNode( $b ), '...which is equivalent to $b';

    # @list = $doc->getElementsByTagName( "A" );
    # ok( scalar @list );
    # ok( $list[0]->isSameNode( $root ) );

    @list = $root.getElementsByTagName( 'B' );
    ok  @list.elems, 'getElementsByTagName() found node B...';
    ok 
        @list.elems && @list[0].isSameNode( $b ), 
        '...which is also equivalent $b';
}

{
    # test potential unbinding-segfault-problem
    my $doc = XML::LibXML::Document.new();
    my $root= $doc.createElement( "A" );
    $doc.setDocumentElement($root);

    my $b = $doc.createElement( "B" );
    $root.appendChild( $b );
    my $c = $doc.createElement( "C" );
    $b.appendChild( $c );
    $b = $doc.createElement( "B" );
    $root.appendChild( $b );
    $c = $doc.createElement( "C" );
    $b.appendChild( $c );

    my @list = $root.find( "B" );
    # TEST
    is  @list.elems, 2, 'elements created successfully';
    for @list -> $node {
        my @subnodes = $node.find( "C" );
        $node.unbindNode() if @subnodes;
        pass "no segfault when unbinding node.";
    }
}

{
    # findnode remove problem

    my $xmlstr = "<a><b><c>1</c><c>2</c></b></a>";

    my $doc       = parse-string( $xmlstr );
    my $root      = $doc.documentElement;
    my @lastc     = $root.find( 'b/c[last()]' );
    my $c_val;
    $c_val = @lastc[0].string_value
        if @lastc.defined  && @lastc.elems == 1   && 
           @lastc[0].string_value.defined;
    is $c_val, '2', 'found last c node in node b';

    $root.removeChild( @lastc[0] ) if @lastc.defined && @lastc[0].defined;
    is $root.Str(:format<0>), $xmlstr, 'DOM remained unchained after bad removal';
}

# --------------------------------------------------------------------------- #
sub finddoc($n) {
    return unless $n.defined && $n.documentElement.defined;    
    $n.documentElement.find("/");
}
