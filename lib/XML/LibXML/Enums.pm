use v6;

unit module XML::LibXML::Enums;

enum xmlC14NMode is export (
    XML_C14N_1_0           =>  0, # Origianal C14N 1.0 spec
    XML_C14N_EXCLUSIVE_1_0 =>  1, # Exclusive C14N 1.0 spec
    XML_C14N_1_1           =>  2, # C14N 1.1 spec
);

enum xmlElementType is export (
    XML_ELEMENT_NODE       =>  1,
    XML_ATTRIBUTE_NODE     =>  2,
    XML_TEXT_NODE          =>  3,
    XML_CDATA_SECTION_NODE =>  4,
    XML_ENTITY_REF_NODE    =>  5,
    XML_ENTITY_NODE        =>  6,
    XML_PI_NODE            =>  7,
    XML_COMMENT_NODE       =>  8,
    XML_DOCUMENT_NODE      =>  9,
    XML_DOCUMENT_TYPE_NODE =>  10,
    XML_DOCUMENT_FRAG_NODE =>  11,
    XML_NOTATION_NODE      =>  12,
    XML_HTML_DOCUMENT_NODE =>  13,
    XML_DTD_NODE           =>  14,
    XML_ELEMENT_DECL       =>  15,
    XML_ATTRIBUTE_DECL     =>  16,
    XML_ENTITY_DECL        =>  17,
    XML_NAMESPACE_DECL     =>  18,
    XML_XINCLUDE_START     =>  19,
    XML_XINCLUDE_END       =>  20,
    XML_DOCB_DOCUMENT_NODE =>  21,
);

enum xmlParserOption is export (
    XML_PARSE_RECOVER    =>  1,       # recover on errors
    XML_PARSE_NOENT      =>  2,       # substitute entities
    XML_PARSE_DTDLOAD    =>  4,       # load the external subset
    XML_PARSE_DTDATTR    =>  8,       # default DTD attributes
    XML_PARSE_DTDVALID   =>  16,      # validate with the DTD
    XML_PARSE_NOERROR    =>  32,      # suppress error reports
    XML_PARSE_NOWARNING  =>  64,      # suppress warning reports
    XML_PARSE_PEDANTIC   =>  128,     # pedantic error reporting
    XML_PARSE_NOBLANKS   =>  256,     # remove blank nodes
    XML_PARSE_SAX1       =>  512,     # use the SAX1 interface internally
    XML_PARSE_XINCLUDE   =>  1024,    # Implement XInclude substitition
    XML_PARSE_NONET      =>  2048,    # Forbid network access
    XML_PARSE_NODICT     =>  4096,    # Do not reuse the context dictionnary
    XML_PARSE_NSCLEAN    =>  8192,    # remove redundant namespaces declarations
    XML_PARSE_NOCDATA    =>  16384,   # merge CDATA as text nodes
    XML_PARSE_NOXINCNODE =>  32768,   # do not generate XINCLUDE START/END nodes
    XML_PARSE_COMPACT    =>  65536,   # compact small text nodes; no modification of the tree allowed afterwards (will possibly crash if you try to modify the tree)
    XML_PARSE_OLD10      =>  131072,  # parse using XML-1.0 before update 5
    XML_PARSE_NOBASEFIX  =>  262144,  # do not fixup XINCLUDE xml:base uris
    XML_PARSE_HUGE       =>  524288,  # relax any hardcoded limit from the parser
    XML_PARSE_OLDSAX     =>  1048576, # parse using SAX2 interface before 2.7.0
    XML_PARSE_IGNORE_ENC =>  2097152, # ignore internal document encoding hint
    XML_PARSE_BIG_LINES  =>  4194304, # Store big lines numbers in text PSVI field
);

enum htmlParserOption is export (
    HTML_PARSE_RECOVER    =>  1,       # Relaxed parsing
    HTML_PARSE_NODEFDTD   =>  4,       # do not default a doctype if not found
    HTML_PARSE_NOERROR    =>  32,      # suppress error reports
    HTML_PARSE_NOWARNING  =>  64,      # suppress warning reports
    HTML_PARSE_PEDANTIC   =>  128,     # pedantic error reporting
    HTML_PARSE_NOBLANKS   =>  256,     # remove blank nodes
    HTML_PARSE_NONET      =>  2048,    # Forbid network access
    HTML_PARSE_NOIMPLIED  =>  8192,    # Do not add implied html/body... elements
    HTML_PARSE_COMPACT    =>  65536,   # compact small text nodes
    HTML_PARSE_IGNORE_ENC =>  2097152, # ignore internal document encoding hint
);

enum htmlStatus is export (
    HTML_NA         =>  0,  # something we don't check at all
    HTML_INVALID    =>  1,
    HTML_DEPRECATED =>  2,
    HTML_VALID      =>  4,
    HTML_REQUIRED   =>  12, # VALID bit set so ( & HTML_VALID ) is TRUE
);

enum xmlXPathObjectType is export (
    XPATH_UNDEFINED   =>  0,
    XPATH_NODESET     =>  1,
    XPATH_BOOLEAN     =>  2,
    XPATH_NUMBER      =>  3,
    XPATH_STRING      =>  4,
    XPATH_POINT       =>  5,
    XPATH_RANGE       =>  6,
    XPATH_LOCATIONSET =>  7,
    XPATH_USERS       =>  8,
    XPATH_XSLT_TREE   =>  9, # An XSLT value tree, non modifiable
);

enum xmlCharEncoding is export (
    XML_CHAR_ENCODING_ERROR     =>  -1, # No char encoding detected 
    XML_CHAR_ENCODING_NONE      =>   0, # No char encoding detected 
    XML_CHAR_ENCODING_UTF8      =>   1, # UTF-8 
    XML_CHAR_ENCODING_UTF16LE   =>   2, # UTF-16 little endian 
    XML_CHAR_ENCODING_UTF16BE   =>   3, # UTF-16 big endian 
    XML_CHAR_ENCODING_UCS4LE    =>   4, # UCS-4 little endian 
    XML_CHAR_ENCODING_UCS4BE    =>   5, # UCS-4 big endian 
    XML_CHAR_ENCODING_EBCDIC    =>   6, # EBCDIC uh! 
    XML_CHAR_ENCODING_UCS4_2143 =>   7, # UCS-4 unusual ordering 
    XML_CHAR_ENCODING_UCS4_3412 =>   8, # UCS-4 unusual ordering 
    XML_CHAR_ENCODING_UCS2      =>   9, # UCS-2 
    XML_CHAR_ENCODING_8859_1    =>  10, # ISO-8859-1 ISO Latin 1 
    XML_CHAR_ENCODING_8859_2    =>  11, # ISO-8859-2 ISO Latin 2 
    XML_CHAR_ENCODING_8859_3    =>  12, # ISO-8859-3 
    XML_CHAR_ENCODING_8859_4    =>  13, # ISO-8859-4 
    XML_CHAR_ENCODING_8859_5    =>  14, # ISO-8859-5 
    XML_CHAR_ENCODING_8859_6    =>  15, # ISO-8859-6 
    XML_CHAR_ENCODING_8859_7    =>  16, # ISO-8859-7 
    XML_CHAR_ENCODING_8859_8    =>  17, # ISO-8859-8 
    XML_CHAR_ENCODING_8859_9    =>  18, # ISO-8859-9 
    XML_CHAR_ENCODING_2022_JP   =>  19, # ISO-2022-JP 
    XML_CHAR_ENCODING_SHIFT_JIS =>  20, # Shift_JIS 
    XML_CHAR_ENCODING_EUC_JP    =>  21, # EUC-JP 
    XML_CHAR_ENCODING_ASCII     =>  22  # pure ASCII 
);
