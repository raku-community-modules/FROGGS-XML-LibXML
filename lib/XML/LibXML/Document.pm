use v6;

class XML::LibXML::Document is repr('CStruct');

use NativeCall;

has OpaquePointer $._private; # application data
#~ xmlElementType	type	: XML_DOCUMENT_NODE, must be second !
has int8          $.type; # XML_DOCUMENT_NODE, must be second !
has Str           $.name; # name/filename/URI of the document
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
has int32         $.compression; # level of zlib compression
has int32         $.standalone;  # standalone document (no external refs)
#~ struct _xmlDtd *	intSubset	: the document internal subset
has OpaquePointer $.intSubset; # the document internal subset
#~ struct _xmlDtd *	extSubset	: the document external subset
has OpaquePointer $.extSubset; # the document external subset
#~ struct _xmlNs *	oldNs	: Global namespace, the old way
has OpaquePointer $.oldNs; # Global namespace, the old way
#~ const xmlChar *	version	: the XML version string
has Str           $.version; # the XML version string
#~ const xmlChar *	encoding	: external initial encoding, if any
has Str           $.encoding; # external initial encoding, if any
#~ void *	ids	: Hash table for ID attributes if any
has OpaquePointer $.ids; # Hash table for ID attributes if any
#~ void *	refs	: Hash table for IDREFs attributes if any
has OpaquePointer $.refs; # Hash table for IDREFs attributes if any
#~ const xmlChar *	URL	: The URI for that document
has Str           $.URL; # The URI for that document
#~ int	charset	: encoding of the in-memory content actua
#~ struct _xmlDict *	dict	: dict used to allocate names or NULL
#~ void *	psvi	: for type/PSVI informations
#~ int	parseFlags	: set of xmlParserOption used to parse th
#~ int	properties	: set of xmlDocProperties for this docume
