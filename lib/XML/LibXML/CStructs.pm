use v6;
use nqp;
use NativeCall;

constant XML_XML_NAMESPACE = "http://www.w3.org/XML/1998/namespace";
constant XML_XMLNS_NS      = 'http://www.w3.org/2000/xmlns/';
constant XML_XML_NS        = 'http://www.w3.org/XML/1998/namespace';

my &_nc = &nativecast;

my class CStruct is repr('CStruct') is export(:types) { }

my class  xmlAttr                    is repr('CStruct')  { ... }
my native xmlAttributeType           is repr('P6int') is Int is nativesize(32) is export(:types) { }
my class  xmlAttrPtr                 is repr('CPointer') is export(:types) { ... }
my class  xmlAutomataPtr             is repr('CPointer') { }
my class  xmlAutomataStatePtr        is repr('CPointer') { }
my class  xmlBuffer                  is repr('CStruct')  { ... }
my native xmlBufferAllocationScheme  is repr('P6int') is Int is nativesize(32) is export(:types) { }
my native xmlChar                    is repr('P6int') is Int is nativesize(8) is unsigned is export(:types) { }
my class  xmlDictPtr                 is repr('CPointer') { }
my class  xmlDtd                     is repr('CStruct')  is export(:types) { ... }  
my class  xmlDtdPtr                  is repr('CPointer') is export(:types) { }
my class  xmlDoc                     is repr('CStruct')  is export(:types) { ... }
my class  xmlDocPtr                  is repr('CPointer') is Pointer is export(:types) { }
my class  xmlError                   is repr('CStruct')  { ... }
my class  xmlElement                 is repr('CStruct')  { ... }
my class  xmlElementPtr              is repr('CPointer') is Pointer { }
my class  xmlHashTablePtr            is repr('CPointer') { }
my class  xmlNode                    is repr('CStruct')  { ... }
my class  xmlNodePtr                 is repr('CPointer') is Pointer is export(:types) { ... }
my class  xmlNodeSet                 is repr('CStruct')  { ... }
my class  xmlNs                      is repr('CStruct') is export(:types) { ... } 
my class  xmlNsPtr                   is repr('CPointer') is Pointer is export(:types) { } 
my class  xmlParserCtxt              is repr('CStruct')  { ... }
my class  xmlParserInputPtr          is repr('CPointer') is Pointer { }
my native xmlParserInputState        is repr('P6int') is Int is nativesize(32) is export(:types) { }
my native xmlParserMode              is repr('P6int') is Int is nativesize(32) is export(:types) { }
my class  xmlParserNodeInfo          is repr('CStruct')  { ... }
my class  xmlParserNodeInfoSeq       is repr('CStruct')  { ... }
my class  xmlSAXHandler              is repr('CStruct')  { ... }
my class  xmlStructuredErrorFunc     is repr('CPointer') { }
my class  xmlValidityErrorFunc       is repr('CPointer') { }
my class  xmlValidityWarningFunc     is repr('CPointer') { }
my class  xmlValidCtxt               is repr('CStruct')  { ... }
my class  xmlXPathAxisPtr            is repr('CPointer') { }
my class  xmlXPathCompExprPtr        is repr('CPointer') is export(:types) { }
my class  xmlXPathContextPtr         is repr('CPointer') is export(:types) { }
my class  xmlXPathContext            is repr('CStruct')  { ... }
my class  xmlXPathFuncLookupFunc     is repr('CPointer') { }
my class  xmlXPathObject             is repr('CStruct')  { ... }
my class  xmlXPathTypePtr            is repr('CPointer') { }
my class  xmlXPathVariableLookupFunc is repr('CPointer') { }
my class  xmlParserInputBufferPtr    is repr('CPointer')  is export(:types) { }

my role xmlNodeCasting is export(:types) {
    method getNodePtr {
        return if self ~~ xmlNodePtr;
        _nc(xmlNodePtr, self);
    }

    method getNode {
        _nc(xmlNode, self);
    }
}

my class xmlNodePtr does xmlNodeCasting { }

my class xmlAttrPtr does xmlNodeCasting { 
    method getAttr {
        _nc(xmlAttr, self);
    }
}

my class xmlAttr is export(:types) {
    also does xmlNodeCasting;

    has Pointer       $._private; # application data
    has int8              $.type; # (xmlElementType) XML_ATTRIBUTE_NODE, must be second !
    has Str          $.localname; # the name of the property
    has xmlNodePtr       $.children is rw; # the value of the property
    has xmlNodePtr           $.last is rw; # NULL
    has xmlNodePtr         $.parent is rw; # child->parent link
    has xmlAttrPtr           $.next is rw; # next sibling link
    has xmlAttrPtr           $.prev is rw; # previous sibling link
    has xmlDoc             $.doc; # the containing document
    has xmlNs               $.ns; # pointer to the associated namespace
    has xmlAttributeType $.atype; # the attribute type if validating
    has Pointer           $.psvi; # for type/PSVI informations

    method getAttrPtr() {
        nativecast(xmlAttrPtr, self);
    }
}

my class xmlBuffer is export(:types) {
    has Str                       $.value; # The buffer content UTF8
    has uint32                      $.use; # The buffer size used
    has uint32                     $.size; # The buffer size
    has xmlBufferAllocationScheme $.alloc; # The realloc method
    has Pointer[xmlChar]      $.contentIO; # in IO mode we may have a different base
}

my class xmlDoc is export(:types) {
    also does xmlNodeCasting;

    has OpaquePointer $._private; # application data
    has int8              $.type; # (xmlElementType) XML_DOCUMENT_NODE, must be second !
    has Str          $.localname; # name/filename/URI of the document
    has xmlNodePtr       $.children is rw; # the value of the property
    has xmlNodePtr           $.last is rw; # NULL
    has xmlNodePtr         $.parent is rw; # child->parent link
    has xmlAttrPtr           $.next is rw; # next sibling link
    has xmlAttrPtr           $.prev is rw; # previous sibling link
    has xmlDoc             $.doc; # autoreference to itself End of common p
    has int32      $.compression; # level of zlib compression
    has int32       $.standalone; # standalone document (no external refs)
    has xmlDtdPtr    $.intSubset; # the document internal subset
    has xmlDtdPtr    $.extSubset; # the document external subset
    has xmlNsPtr         $.oldNs; # Global namespace, the old way
    has Str            $.version; # the XML version string
    has Str           $.encoding; # external initial encoding, if any
    has OpaquePointer      $.ids; # Hash table for ID attributes if any
    has OpaquePointer     $.refs; # Hash table for IDREFs attributes if any
    has Str          $.uri is rw; # The URI for that document
    has int32    $.charset is rw; # encoding of the in-memory content actua
    #~ struct _xmlDict *dict: dict used to allocate names or NULL
    has Pointer           $.dict;
    #~ void *psvi: for type/PSVI informations
    has Pointer           $.psvi;
    #~ intparseFlags: set of xmlParserOption used to parse th
    has int32       $.parseFlags;
    #~ intproperties: set of xmlDocProperties for this docume
    has int32       $.properties;
}

my class xmlError is export(:types) {
    has int32       $.domain; # What part of the library raised this error
    has int32         $.code; # The error code, e.g. an xmlParserError
    has Str        $.message; # human-readable informative error message
    has int8        $._level; # how consequent is the error
    has Str           $.file; # the filename
    has int32         $.line; # the line number if available
    has Str           $.str1; # extra string information
    has Str           $.str2; # extra string information
    has Str           $.str3; # extra string information
    has int32         $.int1; # extra number information
    has int32         $.int2; # column number of the error or 0 if N/A
    has OpaquePointer $.ctxt; # the parser context if available
    has OpaquePointer $.node; # the node in the tree
}

my class xmlDtd is export(:types) {
    also does xmlNodeCasting;

    has OpaquePointer    $.private;  # application data
    has int8             $.type;  # xmlElementType type number, must be second!
    has Str              $.name;  # Element name
    has xmlNodePtr       $.children is rw; # the value of the property
    has xmlNodePtr       $.last is rw; # NULL
    has xmlNodePtr       $.parent is rw; # child->parent link
    has xmlAttrPtr       $.next is rw; # next sibling link
    has xmlAttrPtr       $.prev is rw; # previous sibling link
    has xmlDoc           $.doc; # autoreference to itself End of common p
    has OpaquePointer    $.notations;  # Hash table for notations if any
    has OpaquePointer    $.elements;   # Hash table for elements if any
    has OpaquePointer    $.attributes; # Hash table for attributes if any
    has OpaquePointer    $.entities;   # Hash table for entities if any
    has Str              $.ExternalID; # External identifier for PUBLIC DTD
    has Str              $.SystemID;   # URI for a SYSTEM or PUBLIC DTD
    has OpaquePointer    $.pentities;  # Hash table for param entities if any

    method getPtr() {
        nativecast(xmlDtdPtr, self);
    }

    method setType($type) {
        $!type = $type;
    }
}

my class xmlElement is export(:types) {
    also does xmlNodeCasting;

    has OpaquePointer $.private;  # application data
    has int8             $.type;  # xmlElementType type number, must be second!
    has Str              $.name;  # Element name
    has xmlNodePtr       $.children is rw; # the value of the property
    has xmlNodePtr           $.last is rw; # NULL
    has xmlNodePtr         $.parent is rw; # child->parent link
    has xmlAttrPtr           $.next is rw; # next sibling link
    has xmlAttrPtr           $.prev is rw; # previous sibling link
    has xmlDoc              $.doc; # autoreference to itself End of common p
    has int8              $.etype; # The type
    has OpaquePointer   $.content; # The allowed element content
    has xmlAttrPtr   $.attributes; # List of declared attributes
    has Str              $.prefix;
    has OpaquePointer $.contModel; # The validating regexp.

    #method setName(xmlElement:D: $name) {
    #    $!name = $name;
    #}
}

my class xmlNode is export(:types) {
    also does xmlNodeCasting;

    has OpaquePointer   $._private; # application data
    has int8            $.type; # (xmlElementType) type number, must be second !
    has Str             $.localname; # name/filename/URI of the document
    has xmlNodePtr      $.children is rw; # the value of the property
    has xmlNodePtr      $.last is rw; # NULL
    has xmlNodePtr      $.parent is rw; # child->parent link
    has xmlAttrPtr      $.next is rw; # next sibling link
    has xmlAttrPtr      $.prev is rw; # previous sibling link
    has xmlDoc          $.doc; # autoreference to itself End of common p
    has xmlNs           $.ns; # pointer to the associated namespace
    has Str             $.value; # the content
    has xmlAttr         $.properties; # properties list
    has xmlNs           $.nsDef; # namespace definitions on this node
    has OpaquePointer   $.psvi; # for type/PSVI informations
    #~ unsigned shortline: line number
    has uint16          $.line;
    #~ unsigned shortextra: extra data for XPath/XSLT
    has uint16          $.extra;
}

my class xmlNodeSet is export(:types) {
    has int32            $.nodeNr; # number of nodes in the set
    has int32           $.nodeMax; # size of the array as allocated
    has CArray[xmlNode] $.nodeTab; # array of nodes in no particular order @
}

my class xmlNs is export(:types) {
    has xmlNs             $.next; # next Ns link for this node
    has int8              $.type; # (xmlElementType) global or local
    has Str                $.uri; # URL for the namespace
    has Str               $.name; # prefix for the namespace
    has OpaquePointer $._private; # application data
    has xmlDoc         $.context; # normally an xmlDoc
}

my class xmlParserNodeInfo is export(:types) {
    has xmlNodePtr   $.node; # Position & line # that text that create
    has ulong   $.begin_pos;
    has ulong  $.begin_line;
    has ulong     $.end_pos;
    has ulong    $.end_line;
}

my class xmlParserNodeInfoSeq is export(:types) {
    has ulong            $.maximum;
    has ulong             $.length;
    has xmlParserNodeInfo $.buffer;
}

my class xmlValidCtxt is export(:types) {
    has Pointer                $.userData; # user specific data block
    has xmlValidityErrorFunc      $.error; # the callback in case of errors
    has xmlValidityWarningFunc  $.warning; # the callback in case of warning
    # Node analysis stack used when validating within entities
    has xmlNodePtr                 $.node; # Current parsed Node
    has int32                    $.nodeNr; # Depth of the parsing stack
    has int32                   $.nodeMax; # Max depth of the parsing stack
    has Pointer[xmlNodePtr]     $.nodeTab; # array of nodes
    has uint32                $.finishDtd; # finished validating the Dtd ?
    has Pointer[xmlDoc]             $.doc; # the document
    has int32                     $.valid; # temporary validity check result
    # state state used for non-determinist content validation
    has Pointer                  $.vstate; # current state
    has int32                  $.vstateNr; # Depth of the validation stack
    has int32                 $.vstateMax; # Max depth of the validation stack
    has Pointer               $.vstateTab; # array of validation states
    has xmlAutomataPtr               $.am; # the automata
    has xmlAutomataStatePtr       $.state; # used to build the automata

    method reset {
        $!nodeNr = 0;
        $!vstateNr = 0;
        #$!nodeTab = Pointer;
        #$!vstateTab = Pointer;
    }
}

my class xmlSAXHandler is export(:types) {
    #~ internalSubsetSAXFunc internalSubset;
    #~ isStandaloneSAXFunc isStandalone;
    #~ hasInternalSubsetSAXFunc hasInternalSubset;
    #~ hasExternalSubsetSAXFunc hasExternalSubset;
    #~ resolveEntitySAXFunc resolveEntity;
    #~ getEntitySAXFunc getEntity;
    #~ entityDeclSAXFunc entityDecl;
    #~ notationDeclSAXFunc notationDecl;
    #~ attributeDeclSAXFunc attributeDecl;
    #~ elementDeclSAXFunc elementDecl;
    #~ unparsedEntityDeclSAXFunc unparsedEntityDecl;
    #~ setDocumentLocatorSAXFunc setDocumentLocator;
    #~ startDocumentSAXFunc startDocument;
    #~ endDocumentSAXFunc endDocument;
    #~ startElementSAXFunc startElement;
    #~ endElementSAXFunc endElement;
    #~ referenceSAXFunc reference;
    #~ charactersSAXFunc characters;
    #~ ignorableWhitespaceSAXFunc ignorableWhitespace;
    #~ processingInstructionSAXFunc processingInstruction;
    #~ commentSAXFunc comment;
    #~ warningSAXFunc warning;
    #~ errorSAXFunc error;
    #~ fatalErrorSAXFunc fatalError; /* unused error() get all the errors */
    #~ getParameterEntitySAXFunc getParameterEntity;
    #~ cdataBlockSAXFunc cdataBlock;
    #~ externalSubsetSAXFunc externalSubset;
    has uint32 $.initialized;
    # The following fields are extensions available only on version 2
    has Pointer $._private;
    #~ startElementNsSAX2Func startElementNs;
    #~ endElementNsSAX2Func endElementNs;
    #~ xmlStructuredErrorFunc serror;
}
my class xmlParserCtxt is export(:types) {
    has xmlSAXHandler                  $.sax; # The SAX handler
    has OpaquePointer             $.userData; # For SAX interface only, used by DOM build
    has xmlDoc                       $.myDoc; # the document being built
    has int32                   $.wellFormed; # is the document well formed
    has int32       $.replace-entities is rw; # shall we replace entities ?
    has Str                        $.version; # the XML version string
    has Str                       $.encoding; # the declared encoding, if any
    has int32                   $.standalone; # standalone document
    has int32                         $.html; # an HTML(1)/Docbook(2) document * 3 is H
    has xmlParserInputPtr            $.input; # Current input stream
    has int32                      $.inputNr; # Number of current input streams
    has int32                     $.inputMax; # Max number of input streams
    has CArray[xmlParserInputPtr] $.inputTab; # stack of inputs Node analysis stack onl
    has xmlNodePtr                    $.node; # Current parsed Node
    has int32                       $.nodeNr; # Depth of the parsing stack
    has int32                      $.nodeMax; # Max depth of the parsing stack
    has CArray[xmlNodePtr]         $.nodeTab; # array of nodes
    has int32                  $.record_info; # Whether node info should be kept
    HAS xmlParserNodeInfoSeq      $.node_seq; # info about each node parsed
    has int32                        $.errNo; # error code
    has int32            $.hasExternalSubset; # reference and external subset
    has int32                    $.hasPErefs; # the internal subset has PE refs
    has int32                     $.external; # are we parsing an external entity
    has int32                        $.valid; # is the document valid
    has int32               $.validate is rw; # shall we try to validate ?
    HAS xmlValidCtxt                 $.vctxt; # The validity context
    has xmlParserInputState        $.instate; # current type of input
    has int32                        $.token; # next char look-ahead
    has Str                      $.directory; # the data directory Node name stack
    has Str                           $.name; # Current parsed Node
    has int32                       $.nameNr; # Depth of the parsing stack
    has int32                      $.nameMax; # Max depth of the parsing stack
    has CArray[Str]                $.nameTab; # array of nodes
    has long                       $.nbChars; # number of xmlChar processed
    has long                    $.checkIndex; # used by progressive parsing lookup
    has int32            $.keep-blanks is rw; # ugly but ...
    has int32                   $.disableSAX; # SAX callbacks are disabled
    has int32                     $.inSubset; # Parsing is in int 1/ext 2 subset
    has Str                     $.intSubName; # name of subset
    has Str                      $.extSubURI; # URI of external subset
    has Str                   $.extSubSystem; # SYSTEM ID of external subset xml:space
    has CArray[int32]                $.space; # Should the parser preserve spaces
    has int32                      $.spaceNr; # Depth of the parsing stack
    has int32                     $.spaceMax; # Max depth of the parsing stack
    has CArray[int32]             $.spaceTab; # array of space infos
    has int32                        $.depth; # to prevent entity substitution loops
    has xmlParserInputPtr           $.entity; # used to check entities boundaries
    has int32                      $.charset; # encoding of the in-memory content actua
    has int32                      $.nodelen; # Those two fields are there to
    has int32                      $.nodemem; # Speed up large node parsing
    has int32               $.pedantic is rw; # signal pedantic warnings
    has Pointer                   $._private; # For user data, libxml won't touch it
    has int32                   $.loadsubset; # should the external subset be loaded
    has int32            $.linenumbers is rw; # set line number in element content
    has Pointer                   $.catalogs; # document's own catalog
    has int32                     $.recovery; # run in recovery mode
    has int32                  $.progressive; # is this a progressive parsing
    has xmlDictPtr                    $.dict; # dictionnary for the parser
    has CArray[Str]                   $.atts; # array for the attributes callbacks
    has int32                      $.maxatts; # the size of the array
    has int32                      $.docdict; # * pre-interned strings *
    has Str                        $.str_xml;
    has Str                      $.str_xmlns;
    has Str                     $.str_xml_ns; # * Everything below is used only by the n
    has int32                         $.sax2; # operating in the new SAX mode
    has int32                         $.nsNr; # the number of inherited namespaces
    has int32                        $.nsMax; # the size of the arrays
    has CArray[Str]                  $.nsTab; # the array of prefix/namespace name
    has CArray[int32]            $.attallocs; # which attribute were allocated
    has CArray[OpaquePointer]      $.pushTab; # array of data for push
    has xmlHashTablePtr        $.attsDefault; # defaulted attributes if any
    has xmlHashTablePtr        $.attsSpecial; # non-CDATA attributes if any
    has int32                 $.nsWellFormed; # is the document XML Nanespace okay
    has int32                      $.options; # * Those fields are needed only for tream
    has int32                    $.dictNames; # Use dictionary names for the tree
    has int32                  $.freeElemsNr; # number of freed element nodes
    has xmlNodePtr               $.freeElems; # List of freed element nodes
    has int32                  $.freeAttrsNr; # number of freed attributes nodes
    has xmlAttrPtr               $.freeAttrs; # * the complete error informations for th
    HAS xmlError                 $.lastError;
    has xmlParserMode            $.parseMode; # the parser mode
    has ulong                   $.nbentities; # number of entities references
    has ulong                 $.sizeentities; # size of parsed entities for use by HTML
    has xmlParserNodeInfo         $.nodeInfo; # Current NodeInfo
    has int32                   $.nodeInfoNr; # Depth of the parsing stack
    has int32                  $.nodeInfoMax; # Max depth of the parsing stack
    has xmlParserNodeInfo      $.nodeInfoTab; # array of nodeInfos
    has int32                     $.input_id; # we need to label inputs
    has ulong                  $.sizeentcopy; # volume of entity copy
}

my class xmlXPathContext is export(:types) {
    has xmlDoc                               $.doc; # The current document
    has xmlNode                             $.node; # The current node
    has int32                $.nb_variables_unused; # unused (hash table)
    has int32               $.max_variables_unused; # unused (hash table)
    has xmlHashTablePtr                  $.varHash; # Hash table of defined variables
    has int32                           $.nb_types; # number of defined types
    has int32                          $.max_types; # max number of types
    has xmlXPathTypePtr                    $.types; # Array of defined types
    has int32                    $.nb_funcs_unused; # unused (hash table)
    has int32                   $.max_funcs_unused; # unused (hash table)
    has xmlHashTablePtr                 $.funcHash; # Hash table of defined funcs
    has int32                            $.nb_axis; # number of defined axis
    has int32                           $.max_axis; # max number of axis
    has xmlXPathAxisPtr                     $.axis; # Array of defined axis the namespace nod
    has xmlNs                         $.namespaces; # Array of namespaces
    has int32                               $.nsNr; # number of namespace in scope
    has OpaquePointer                       $.user; # function to free extra variables
    has int32                        $.contextSize; # the context size
    has int32                  $.proximityPosition; # the proximity position extra stuff for
    has int32                               $.xptr; # is this an XPointer context?
    has xmlNode                             $.here; # for here()
    has xmlNode                           $.origin; # for origin() the set of namespace decla
    has xmlHashTablePtr                   $.nsHash; # The namespaces hash table
    has xmlXPathVariableLookupFunc $.varLookupFunc; # variable lookup func
    has OpaquePointer              $.varLookupData; # variable lookup data Possibility to lin
    has OpaquePointer                      $.extra; # needed for XSLT The function name and U
    has Str                             $.function;
    has Str                          $.functionURI; # function lookup function and data
    has xmlXPathFuncLookupFunc    $.funcLookupFunc; # function lookup func
    has OpaquePointer             $.funcLookupData; # function lookup data temporary namespac
    has xmlNsPtr                       $.tmpNsList; # Array of namespaces
    has int32                            $.tmpNsNr; # number of namespaces in scope error rep
    has OpaquePointer                   $.userData; # user specific data block
    has xmlStructuredErrorFunc             $.error; # the callback in case of errors
    HAS xmlError                       $.lastError; # the last error
    has xmlNodePtr                     $.debugNode; # the source node XSLT dictionary
    has xmlDictPtr                          $.dict; # dictionary if any
    has int32                              $.flags; # flags to control compilation Cache for
    has OpaquePointer                      $.cache;
}

my class xmlXPathObject is export(:types) {
    has int8             $.type; # xmlXPathObjectType
    has xmlNodeSet $.nodesetval;
    has int32         $.boolval;
    has num64        $.floatval;
    has Str         $.stringval;
    has Pointer          $.user;
    has int32           $.index;
    has Pointer         $.user2;
    has int32          $.index2;
}