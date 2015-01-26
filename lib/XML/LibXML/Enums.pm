#~ module XML::LibXML::Enums {
    enum xmlC14NMode is export (
        XML_C14N_1_0           => 0, # Origianal C14N 1.0 spec
        XML_C14N_EXCLUSIVE_1_0 => 1, # Exclusive C14N 1.0 spec
        XML_C14N_1_1           => 2, # C14N 1.1 spec
    );

    enum xmlElementType is export (
        XML_ELEMENT_NODE       => 1,
        XML_ATTRIBUTE_NODE     => 2,
        XML_TEXT_NODE          => 3,
        XML_CDATA_SECTION_NODE => 4,
        XML_ENTITY_REF_NODE    => 5,
        XML_ENTITY_NODE        => 6,
        XML_PI_NODE            => 7,
        XML_COMMENT_NODE       => 8,
        XML_DOCUMENT_NODE      => 9,
        XML_DOCUMENT_TYPE_NODE => 10,
        XML_DOCUMENT_FRAG_NODE => 11,
        XML_NOTATION_NODE      => 12,
        XML_HTML_DOCUMENT_NODE => 13,
        XML_DTD_NODE           => 14,
        XML_ELEMENT_DECL       => 15,
        XML_ATTRIBUTE_DECL     => 16,
        XML_ENTITY_DECL        => 17,
        XML_NAMESPACE_DECL     => 18,
        XML_XINCLUDE_START     => 19,
        XML_XINCLUDE_END       => 20,
        XML_DOCB_DOCUMENT_NODE => 21,
    );

    enum xmlXPathObjectType is export (
        XPATH_UNDEFINED   => 0,
        XPATH_NODESET     => 1,
        XPATH_BOOLEAN     => 2,
        XPATH_NUMBER      => 3,
        XPATH_STRING      => 4,
        XPATH_POINT       => 5,
        XPATH_RANGE       => 6,
        XPATH_LOCATIONSET => 7,
        XPATH_USERS       => 8,
        XPATH_XSLT_TREE   => 9, # An XSLT value tree, non modifiable
    );
#~ }
