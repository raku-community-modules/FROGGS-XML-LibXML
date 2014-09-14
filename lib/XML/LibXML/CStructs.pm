
use NativeCall;

my class CStruct is repr('CStruct') is export(:types) { }

my class  xmlAttrPtr           is repr('CPointer') { }
my native xmlChar              is repr('P6int') is Int is nativesize(8) is unsigned { }
my class  xmlDictPtr           is repr('CPointer') { }
my class  xmlDocPtr            is repr('CPointer') { }
my class  xmlError             is repr('CStruct')  { ... }
my class  xmlHashTablePtr      is repr('CPointer') { }
my class  xmlNodePtr           is repr('CPointer') { }
my class  xmlParserCtxt        is repr('CStruct')  { ... }
my class  xmlParserInputPtr    is repr('CPointer') { }
my native xmlParserInputState  is repr('P6int') is Int is nativesize(64) { }
my class  xmlParserMode        is repr('CPointer') { }
my class  xmlParserNodeInfo    is repr('CStruct')  { ... }
my class  xmlParserNodeInfoSeq is repr('CStruct')  { ... }
my class  xmlSAXHandler        is repr('CPointer') { }
my class  xmlValidCtxt         is repr('CPointer') { }

my class xmlError is repr('CStruct') is export(:types) {
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

my class xmlParserCtxt is repr('CStruct') is export(:types) {
    has xmlSAXHandler                  $.sax; # The SAX handler
    has OpaquePointer             $.userData; # For SAX interface only, used by DOM build
    has xmlDocPtr                    $.myDoc; # the document being built
    has int32                   $.wellFormed; # is the document well formed
    has int32              $.replaceEntities; # shall we replace entities ?
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
    has xmlParserNodeInfoSeq      $.node_seq; # info about each node parsed
    has int32                        $.errNo; # error code
    has int32            $.hasExternalSubset; # reference and external subset
    has int32                    $.hasPErefs; # the internal subset has PE refs
    has int32                     $.external; # are we parsing an external entity
    has int32                        $.valid; # is the document valid
    has int32                     $.validate; # shall we try to validate ?
    has xmlValidCtxt                 $.vctxt; # The validity context
    has xmlParserInputState        $.instate; # current type of input
    has int32                        $.token; # next char look-ahead
    has CArray[int8]             $.directory; # the data directory Node name stack
    has CArray[int8]                  $.name; # Current parsed Node
    has int32                       $.nameNr; # Depth of the parsing stack
    has int32                      $.nameMax; # Max depth of the parsing stack
    has CArray[Str]                $.nameTab; # array of nodes
    has int                        $.nbChars; # number of xmlChar processed
    has int                     $.checkIndex; # used by progressive parsing lookup
    has int32                   $!keepBlanks; # ugly but ...
    has int32                   $.disableSAX; # SAX callbacks are disabled
    has int32                     $.inSubset; # Parsing is in int 1/ext 2 subset
    has Str                     $.intSubName; # name of subset
    has Str                      $.extSubURI; # URI of external subset
    has Str                   $.extSubSystem; # SYSTEM ID of external subset xml:space
    has CArray[int]                  $.space; # Should the parser preserve spaces
    has int32                      $.spaceNr; # Depth of the parsing stack
    has int32                     $.spaceMax; # Max depth of the parsing stack
    has CArray[int]               $.spaceTab; # array of space infos
    has int32                        $.depth; # to prevent entity substitution loops
    has xmlParserInputPtr           $.entity; # used to check entities boundaries
    has int32                      $.charset; # encoding of the in-memory content actua
    has int32                      $.nodelen; # Those two fields are there to
    has int32                      $.nodemem; # Speed up large node parsing
    has int32                     $.pedantic; # signal pedantic warnings
    has OpaquePointer             $._private; # For user data, libxml won't touch it
    has int32                   $.loadsubset; # should the external subset be loaded
    has int32                  $.linenumbers; # set line number in element content
    has OpaquePointer             $.catalogs; # document's own catalog
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
    has CArray[int]              $.attallocs; # which attribute were allocated
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
    has xmlError                 $.lastError;
    has xmlParserMode            $.parseMode; # the parser mode
    has int                     $.nbentities; # number of entities references
    has int                   $.sizeentities; # size of parsed entities for use by HTML
    has xmlParserNodeInfo         $.nodeInfo; # Current NodeInfo
    has int32                   $.nodeInfoNr; # Depth of the parsing stack
    has int32                  $.nodeInfoMax; # Max depth of the parsing stack
    has xmlParserNodeInfo      $.nodeInfoTab; # array of nodeInfos
    has int32                     $.input_id; # we need to label inputs
    has int                    $.sizeentcopy; # volume of entity copy

    # XXX This can go away when rakudo supports 'is rw' on natively typed attributes
    method keep-blanks(*@a) is rw {
        Proxy.new(
            FETCH => -> $ {
                nqp::p6bool(nqp::getattr_i(nqp::decont(self), xmlParserCtxt, '$!keepBlanks'))
            },
            STORE => -> $, int32 $new {
                nqp::bindattr_i(nqp::decont(self), xmlParserCtxt, '$!keepBlanks', $new);
                $new
            }
        )
    }
}

my class xmlParserNodeInfo is repr('CStruct') is export(:types) {
    has xmlNodePtr $.node; # Position & line # that text that create
    has int   $.begin_pos;
    has int  $.begin_line;
    has int     $.end_pos;
    has int    $.end_line;
}

my class xmlParserNodeInfoSeq is repr('CStruct') is export(:types) {
    has int              $.maximum;
    has int               $.length;
    has xmlParserNodeInfo $.buffer;
}
