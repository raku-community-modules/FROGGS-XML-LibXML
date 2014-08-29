
use v6;
use NativeCall;

#~ enum xmlElementType {
    #~ XML_ELEMENT_NODE = 1
    #~ XML_ATTRIBUTE_NODE = 2
    #~ XML_TEXT_NODE = 3
    #~ XML_CDATA_SECTION_NODE = 4
    #~ XML_ENTITY_REF_NODE = 5
    #~ XML_ENTITY_NODE = 6
    #~ XML_PI_NODE = 7
    #~ XML_COMMENT_NODE = 8
    #~ XML_DOCUMENT_NODE = 9
    #~ XML_DOCUMENT_TYPE_NODE = 10
    #~ XML_DOCUMENT_FRAG_NODE = 11
    #~ XML_NOTATION_NODE = 12
    #~ XML_HTML_DOCUMENT_NODE = 13
    #~ XML_DTD_NODE = 14
    #~ XML_ELEMENT_DECL = 15
    #~ XML_ATTRIBUTE_DECL = 16
    #~ XML_ENTITY_DECL = 17
    #~ XML_NAMESPACE_DECL = 18
    #~ XML_XINCLUDE_START = 19
    #~ XML_XINCLUDE_END = 20
    #~ XML_DOCB_DOCUMENT_NODE = 21
#~ }

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

# xmlDocPtr	xmlParseFile		(const char * filename)
sub xmlParseFile(Str) returns xmlDoc is native('libxml2') { * }

say xmlParseFile('test.xml');
