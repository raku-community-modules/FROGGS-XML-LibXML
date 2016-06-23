use v6.c;
use test;

# Should be 45.
plan 44;

use XML::LibXML;
use XML::LibXML::Node;
use XML::LibXML::Element;

# to test if findnodes works.
# i added findnodes to the node class, so a query can be started
# everywhere.

# For Perl6, findnodes has been changed to find(), but will be aliased for
# drop in compatibility.

my $file    = "example/dromeds.xml";

# init the file parser
my $parser = XML::LibXML.new();
my $dom    = $parser.parse_file( $file );

if $dom.defined {
    # get the root document
    my $elem   = $dom.getDocumentElement();

    # first very simple path starting at root
    my @list   = $elem.find( "species" );
    # TEST
    ok 
        @list.defined 
        @list.elems, 3, 'found the right number of elements ';
    my @list2   = $elem.findnodes( 'species' );
    
    ok
        @list2.defined && @list eqv @list2,
        'alias to findnodes works';

    # a simple query starting somewhere ...
    my $node = $list[0];
    my @slist = $node.find( "humps" );
    # TEST
    is @slist.elems, 1, 'find from element level works properly';

    # find a single node
    @list   = $elem.find( "species[\@name='Llama']" );
    # TEST
    is @list.elems, 1, 'find using attribute works properly';

    # find with not conditions
    @list   = $elem.find( "species[\@name!='Llama']/disposition" );
    # TEST
    is @list.elems, 2, 'find using negated attribute spec works properly';


    @list   = $elem.find( 'species/@name' );
    # warn $elem->toString();

    # TEST

    ok 
        @list.elems && $list[0]->toString() eq ' name="Camel"', 
        'attribute retrieval via find() works properly';

    # cw: Eep! New class.
    my $x = XML::LibXML::Text.new( 1234 );
    ok $
        x.defined && $x.getData() eq "1234", 
        'creation of text node was successful';

    my $telem = $dom.createElement('test');
    $telem.appendWellBalancedChunk('<b>c</b>');

    finddoc($dom);
    # TEST
    ok(1, ' TODO : Add test name');
}
# TEST

ok( $dom, ' TODO : Add test name' );

# test to make sure that multiple array findnodes() returns
# don't segfault perl; it'll happen after the second one if it does
for (0..3) {
    my $doc = XML::LibXML->new->parse_string(
'<?xml version="1.0" encoding="UTF-8"?>
<?xsl-stylesheet type="text/xsl" href="a.xsl"?>
<a />');
    my @nds = $doc.find("processing-instruction('xsl-stylesheet')");
}

my $doc = $parser->parse_string(<<'EOT');
<a:foo xmlns:a="http://foo.com" xmlns:b="http://bar.com">
 <b:bar>
  <a:foo xmlns:a="http://other.com"/>
 </b:bar>
</a:foo>
EOT

my $root = $doc->getDocumentElement;
my @a = $root.find('//a:foo');
# TEST

is(@a, 1, ' TODO : Add test name');

my @b = $root.find('//b:bar');
# TEST

is(@b, 1, ' TODO : Add test name');

my @none = $root.find('//b:foo');
@none = (@none, $root.find('//foo'));
# TEST

is(@none, 0, ' TODO : Add test name');

my @doc = $root.find('document("example/test.xml")');
# TEST

ok(@doc, ' TODO : Add test name');
# warn($doc[0]->toString);

# this query should result an empty array!
my @nodes = $root.find( "/humpty/dumpty" );
# TEST

is( scalar(@nodes), 0, ' TODO : Add test name' );


my $docstring = q{
<foo xmlns="http://kungfoo" xmlns:bar="http://foo"/>
};
 $doc = $parser->parse_string( $docstring );
 $root = $doc->documentElement;

my @ns = $root.find('namespace::*');
# TEST

is(scalar(@ns), 2, ' TODO : Add test name' );

# bad xpaths
# TEST:$badxpath=4;
my @badxpath = (
    'abc:::def',
    'foo///bar',
    '...',
    '/-',
               );

foreach my $xp ( @badxpath ) {
    my $res;
    eval { $res = $root.find( $xp ); };
    # TEST*$badxpath
    ok($@, ' TODO : Add test name');
    eval { $res = $root->find( $xp ); };
    # TEST*$badxpath
    ok($@, ' TODO : Add test name');
    eval { $res = $root->findvalue( $xp ); };
    # TEST*$badxpath
    ok($@, ' TODO : Add test name');
    eval { $res = $root.find( encodeToUTF8( "iso-8859-1", $xp ) ); };
    # TEST*$badxpath
    ok($@, ' TODO : Add test name');
    eval { $res = $root->find( encodeToUTF8( "iso-8859-1", $xp ) );};
    # TEST*$badxpath
    ok($@, ' TODO : Add test name');
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
    my $doc = XML::LibXML->createDocument();
    my $root= $doc->createElement( "A" );
    $doc->setDocumentElement($root);

    my $b= $doc->createElement( "B" );
    $root->appendChild( $b );

    my @list = $doc.find( '//A' );
    # TEST
    ok( scalar @list, ' TODO : Add test name' );
    # TEST
    ok( $list[0]->isSameNode( $root ), ' TODO : Add test name' );

    @list = $doc.find( '//B' );
    # TEST
    ok( scalar @list, ' TODO : Add test name' );
    # TEST
    ok( $list[0]->isSameNode( $b ), ' TODO : Add test name' );


    # @list = $doc->getElementsByTagName( "A" );
    # ok( scalar @list );
    # ok( $list[0]->isSameNode( $root ) );

    @list = $root->getElementsByTagName( 'B' );
    # TEST
    ok( scalar @list, ' TODO : Add test name' );
    # TEST
    ok( $list[0]->isSameNode( $b ), ' TODO : Add test name' );
}

{
    # test potential unbinding-segfault-problem
    my $doc = XML::LibXML->createDocument();
    my $root= $doc->createElement( "A" );
    $doc->setDocumentElement($root);

    my $b= $doc->createElement( "B" );
    $root->appendChild( $b );
    my $c= $doc->createElement( "C" );
    $b->appendChild( $c );
    $b= $doc->createElement( "B" );
    $root->appendChild( $b );
    $c= $doc->createElement( "C" );
    $b->appendChild( $c );

    my @list = $root.find( "B" );
    # TEST
    is( scalar(@list) , 2, ' TODO : Add test name' );
    foreach my $node ( @list ) {
        my @subnodes = $node.find( "C" );
        $node->unbindNode() if ( scalar( @subnodes ) );
        # TEST*2
        ok(1, ' TODO : Add test name');
    }
}

{
    # findnode remove problem

    my $xmlstr = "<a><b><c>1</c><c>2</c></b></a>";

    my $doc       = $parser->parse_string( $xmlstr );
    my $root      = $doc->documentElement;
    my ( $lastc ) = $root.find( 'b/c[last()]' );
    # TEST
    ok( $lastc, ' TODO : Add test name' );

    $root->removeChild( $lastc );
    # TEST
    is( $root->toString(), $xmlstr, ' TODO : Add test name' );
}

# --------------------------------------------------------------------------- #
sub finddoc($n) {
    return unless $n.defined && $n.documentElement.defined;
    
    $n.documentElement.find("/");
}
