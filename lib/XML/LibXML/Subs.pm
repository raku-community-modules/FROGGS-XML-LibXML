multi trait_mod:<is>(Routine $r, :$aka!) is export { $r.package.^add_method($aka, $r) };

# String and encoding functions
sub xmlParseCharEncoding(Str)     returns int8   is native('libxml2') { * }
sub xmlGetCharEncodingName(int8)  returns Str    is native('libxml2') { * }
sub xmlStrlen(Str)                returns int32  is native('libxml2') { * }

sub xmlNodeGetBase(XML::LibXML::Document, XML::LibXML::Document)            returns Str                    is native('libxml2') { * }

# Error handling
sub xmlSetGenericErrorFunc(CStruct, &cb (OpaquePointer, OpaquePointer, CArray[OpaquePointer]))  is native('libxml2') { * }
sub xmlSetStructuredErrorFunc(CStruct, &cb (OpaquePointer, OpaquePointer))                      is native('libxml2') { * }
sub xmlCtxtGetLastError(CStruct)                                    returns XML::LibXML::Error  is native('libxml2') { * }
sub xmlGetLastError()                                               returns XML::LibXML::Error  is native('libxml2') { * }

# Namespaces
sub xmlNewNs(XML::LibXML::Node, Str, Str)              returns xmlNs  is native('libxml2') is export { * }
sub xmlSearchNsByHref(XML::LibXML::Document, XML::LibXML::Node, Str)  returns xmlNs  is native('libxml2') is export { * }
sub xmlSetNs(XML::LibXML::Node, xmlNs)                                is native('libxml2') is export { * }
sub xmlGetNsList(XML::LibXML::Document, XML::LibXML::Node)            returns xmlNs  is native('libxml2') is export { * }

# XPath
sub xmlXPathCompile(Str)                                           returns xmlXPathCompExprPtr  is native('libxml2') { * }
sub xmlXPathNewContext(XML::LibXML::Document)                                     returns xmlXPathContext      is native('libxml2') { * }
sub xmlXPathCompiledEval(xmlXPathCompExprPtr, xmlXPathContextPtr)  returns xmlXPathObject       is native('libxml2') { * }

# Serialization
sub xmlDocDumpMemory(XML::LibXML::Document, CArray, CArray)                                                         is native('libxml2') is export { * }
sub xmlDocDumpFormatMemory(XML::LibXML::Document, CArray, CArray, int32)                                            is native('libxml2') is export { * }
sub xmlNodeDump(xmlBuffer, XML::LibXML::Document, XML::LibXML::Node, int32, int32)                             returns int32  is native('libxml2') is export { * }
sub xmlC14NDocDumpMemory(XML::LibXML::Document, xmlNodeSet, int32, CArray[Str], int32, CArray[Str])  returns int32  is native('libxml2') is export { * }

sub xmlBufferCreate()                        returns xmlBuffer  is native('libxml2') is export { * }
sub xmlUnlinkNode(XML::LibXML::Node)                                      is native('libxml2') is export { * }
sub xmlUnsetProp(XML::LibXML::Node, Str)               returns int32      is native('libxml2') is export { * }
sub xmlChildElementCount(XML::LibXML::Node)            returns int        is native('libxml2') is export { * }
sub xmlEncodeEntitiesReentrant(XML::LibXML::Document, Str)  returns Str        is native('libxml2') is export { * }

sub xmlCtxtReadDoc(xmlParserCtxt, Str, Str, Str, Int)  returns XML::LibXML::Document is native('libxml2') { * }
sub xmlNewParserCtxt                                   returns XML::LibXML           is native('libxml2') { * }
sub xmlReadDoc(Str, Str, Str, Int)                     returns XML::LibXML::Document is native('libxml2') { * }
sub xmlReadMemory(Str, Int, Str, Str, Int)             returns XML::LibXML::Document is native('libxml2') { * }
sub htmlParseFile(Str, Str)                            returns XML::LibXML::Document is native('libxml2') { * }
sub htmlCtxtReadDoc(xmlParserCtxt, Str, Str, Str, Int) returns XML::LibXML::Document is native('libxml2') { * }

sub xmlNewDoc(Str)                          returns XML::LibXML::Document  is native('libxml2') { * }
sub xmlDocGetRootElement(XML::LibXML::Document)            returns XML::LibXML::Node      is native('libxml2') { * }
sub xmlDocSetRootElement(XML::LibXML::Document, XML::LibXML::Node)   returns XML::LibXML::Node      is native('libxml2') { * }
sub xmlNewNode(XML::LibXML::Document, Str)                 returns XML::LibXML::Node      is native('libxml2') { * }
sub xmlNewText(Str)                         returns XML::LibXML::Node      is native('libxml2') { * }
sub xmlNewDocComment(XML::LibXML::Document, Str)           returns XML::LibXML::Node      is native('libxml2') { * }
sub xmlNewCDataBlock(XML::LibXML::Document, Str, int32)    returns XML::LibXML::Node      is native('libxml2') { * }
sub xmlReplaceNode(XML::LibXML::Node, XML::LibXML::Node)        returns XML::LibXML::Node      is native('libxml2') { * }
sub xmlNewDocFragment(XML::LibXML::Document)               returns XML::LibXML::Node      is native('libxml2') { * }
sub xmlNewDocProp(XML::LibXML::Document, Str, Str)         returns XML::LibXML::Attr      is native('libxml2') { * }
sub xmlNewDocNode(XML::LibXML::Document, xmlNs, Str, Str)  returns XML::LibXML::Node      is native('libxml2') { * }

sub xmlAddChild(XML::LibXML::Node, XML::LibXML::Node)  returns XML::LibXML::Node  is native('libxml2') { * }

