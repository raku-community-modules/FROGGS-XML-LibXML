
use v6;
use NativeCall;

class xmlDoc is repr('CStruct') {
    has OpaquePointer $._private; # application data
    #~ xmlElementType	type	: XML_DOCUMENT_NODE, must be second !
    has int8 $.type; # XML_DOCUMENT_NODE, must be second !
    has Str   $.name; # name/filename/URI of the document
    #~ struct _xmlNode *	children	: the document tree
    has OpaquePointer $.children; # the document tree
    #~ struct _xmlNode *	last	: last child link
    has OpaquePointer $.last; # last child link
    #~ struct _xmlNode *	parent	: child->parent link
    has OpaquePointer $.parent; # child->parent link
    #~ struct _xmlNode *	next	: next sibling link
    has OpaquePointer $.next; # next sibling link
    #~ struct _xmlNode *	prev	: previous sibling link
    has OpaquePointer $.prev; # previous sibling link
    #~ struct _xmlDoc *	doc	: autoreference to itself End of common p
    has OpaquePointer $.doc; # autoreference to itself End of common p
    has int32 $.compression; # level of zlib compression
    has int32 $.standalone;  # standalone document (no external refs)
    #~ struct _xmlDtd *	intSubset	: the document internal subset
    has OpaquePointer $.intSubset; # the document internal subset
    #~ struct _xmlDtd *	extSubset	: the document external subset
    has OpaquePointer $.extSubset; # the document external subset
    #~ struct _xmlNs *	oldNs	: Global namespace, the old way
    has OpaquePointer $.oldNs; # Global namespace, the old way
    #~ const xmlChar *	version	: the XML version string
    has Str $.version; # the XML version string
    #~ const xmlChar *	encoding	: external initial encoding, if any
    has Str $.encoding; # external initial encoding, if any
    #~ void *	ids	: Hash table for ID attributes if any
    has OpaquePointer $.ids; # Hash table for ID attributes if any
    #~ void *	refs	: Hash table for IDREFs attributes if any
    has OpaquePointer $.refs; # Hash table for IDREFs attributes if any
    #~ const xmlChar *	URL	: The URI for that document
    has Str $.URL; # The URI for that document
    #~ int	charset	: encoding of the in-memory content actua
    #~ struct _xmlDict *	dict	: dict used to allocate names or NULL
    #~ void *	psvi	: for type/PSVI informations
    #~ int	parseFlags	: set of xmlParserOption used to parse th
    #~ int	properties	: set of xmlDocProperties for this docume
}

class xmlNode is repr('CStruct') {
    #void *  _private    : application data
    has OpaquePointer $._private;
    #xmlElementType  type    : type number, must be second !
    has int8 $.type;
    #const xmlChar * name    : the name of the node, or the entity
    has Str $.name;
    #struct _xmlNode *   children    : parent->childs link
    has xmlNode $.children;
    #struct _xmlNode *   last    : last child link
    has xmlNode $.last;
    #struct _xmlNode *   parent  : child->parent link
    has xmlNode $.parent;
    #struct _xmlNode *   next    : next sibling link
    has xmlNode $.next;
    #struct _xmlNode *   prev    : previous sibling link
    has xmlNode $.prev;
    #struct _xmlDoc *    doc : the containing document End of common p
    has xmlDoc $.doc;
    #xmlNs * ns  : pointer to the associated namespace
    has OpaquePointer $.ns;
    has Str $.value; # the content
    #struct _xmlAttr *   properties  : properties list
    has OpaquePointer $._xmlAttr;
    #xmlNs * nsDef   : namespace definitions on this node
    has OpaquePointer $.nsDef;
    #void *  psvi    : for type/PSVI informations
    has OpaquePointer $.psvi;
    #unsigned short  line    : line number
    has int $.line;
    #unsigned short  extra   : extra data for XPath/XSLT
    has int $.extra;
}

# xmlDocPtr	xmlParseFile		(const char * filename)
sub xmlParseFile(Str) returns xmlDoc is native('libxml2') { * }

# htmlDocPtr htmlParseFile(const char * filename,
#                          const char * encoding)
sub htmlParseFile(Str, Str) returns xmlDoc is native('libxml2') { * }

say xmlParseFile('test.xml');
my $html = htmlParseFile('index.html', 'utf-8');
say $html;

my xmlNode $xmlNode = nativecast(xmlNode, $html.children);
say $xmlNode.perl;
