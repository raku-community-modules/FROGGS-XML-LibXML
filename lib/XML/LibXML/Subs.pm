use v6;

use NativeCall;
use XML::LibXML::CStructs :types;

multi trait_mod:<is>(Routine $r, :$aka!) is export { $r.package.^add_method($aka, $r) };

# String and encoding functions
sub xmlParseCharEncoding(Str)     returns int8   is native('xml2') is export { * }
sub xmlGetCharEncodingName(int8)  returns Str    is native('xml2') is export { * }
sub xmlStrlen(Str)                returns int32  is native('xml2') is export { * }

sub xmlNodeGetBase(xmlDoc, xmlDoc)         returns Str                    is native('xml2') is export { * }
sub xmlNodeSetBase(xmlDoc, Str)                                           is native('xml2') is export { * }

# Error handling
sub xmlSetGenericErrorFunc(CStruct, &cb (OpaquePointer, OpaquePointer, CArray[OpaquePointer]))  is native('xml2')  is export { * }
sub xmlSetStructuredErrorFunc(CStruct, &cb (OpaquePointer, OpaquePointer))                      is native('xml2')  is export { * }

# Namespaces
sub xmlNewNs(xmlNode, Str, Str)              returns xmlNs  is native('xml2') is export { * }
sub xmlSearchNsByHref(xmlDoc, xmlNode, Str)  returns xmlNs  is native('xml2') is export { * }
sub xmlSetNs(xmlNode, xmlNs)                                is native('xml2') is export { * }
sub xmlGetNsList(xmlDoc, xmlNode)            returns xmlNs  is native('xml2') is export { * }

# XPath
sub xmlXPathCompile(Str)                                        returns xmlXPathCompExprPtr  is native('xml2') is export { * }
sub xmlXPathNewContext(xmlDoc)                                  returns xmlXPathContext      is native('xml2') is export { * }
sub xmlXPathCompiledEval(xmlXPathCompExprPtr, xmlXPathContext)  returns xmlXPathObject       is native('xml2') is export { * }

# Serialization
sub xmlDocDumpMemory(xmlDoc, CArray, CArray)                                                         is native('xml2') is export { * }
sub xmlDocDumpFormatMemory(xmlDoc, CArray, CArray, int32)                                            is native('xml2') is export { * }
sub xmlNodeDump(xmlBuffer, xmlDoc, xmlNode, int32, int32)                             returns int32  is native('xml2') is export { * }
sub xmlC14NDocDumpMemory(xmlDoc, xmlNodeSet, int32, CArray[Str], int32, CArray[Str])  returns int32  is native('xml2') is export { * }

sub xmlBufferCreate()                        returns xmlBuffer  is native('xml2') is export { * }
sub xmlKeepBlanksDefault(int32)              returns int32      is native('xml2') is export { * }
sub xmlIsBlankNode(xmlNode)                  returns int32      is native('xml2') is export { * }
sub xmlUnlinkNode(xmlNodePtr)                                   is native('xml2') is export { * }
sub xmlUnsetProp(xmlNode, Str)               returns int32      is native('xml2') is export { * }
#~ multi xmlChildElementCount(xmlNode)          returns ulong      is native('xml2') is export { * }
#~ multi xmlChildElementCount(xmlDoc)           returns ulong      is native('xml2') is export { * }
sub xmlEncodeEntitiesReentrant(xmlDoc, Str)  returns Str        is native('xml2') is export { * }

sub xmlHasNsProp(xmlNode, Str, Str)          
	returns xmlAttr
    is native('xml2') is export { * }

sub xmlGetNsProp(xmlNode, Str, Str)          returns Str        is native('xml2') is export { * }
sub xmlSearchNs(xmlDoc, xmlNode, Str)        returns xmlNs      is native('xml2') is export { * }
sub xmlReplaceNode(xmlNode, xmlNode)         returns xmlNode    is native('xml2') is export { * }
sub xmlSetTreeDoc(xmlNode, xmlDoc) 								is native('xml2') is export { * }
sub xmlCopyNamespace(xmlNsPtr)               returns xmlNsPtr   is native('xml2') is export { * }
sub xmlAddChild(xmlNodePtr, xmlNodePtr)      returns xmlNodePtr is native('xml2') is export { * }
sub xmlSetNsProp(xmlNode, xmlNs, Str, Str)   returns xmlAttrPtr is native('xml2') is export { * }
sub xmlNodeGetContent(xmlNode)               returns Str        is native('xml2') is export { * }