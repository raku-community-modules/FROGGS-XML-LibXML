use v6;

use NativeCall;
use XML::LibXML::CStructs :types;

multi trait_mod:<is>(Routine $r, :$aka!) is export { $r.package.^add_method($aka, $r) };

# String and encoding functions
sub xmlParseCharEncoding(Str)     returns int8   is native('libxml2') is export { * }
sub xmlGetCharEncodingName(int8)  returns Str    is native('libxml2') is export { * }
sub xmlStrlen(Str)                returns int32  is native('libxml2') is export { * }

sub xmlNodeGetBase(xmlDoc, xmlDoc)            returns Str                    is native('libxml2') is export { * }

# Error handling
sub xmlSetGenericErrorFunc(CStruct, &cb (OpaquePointer, OpaquePointer, CArray[OpaquePointer]))  is native('libxml2')  is export { * }
sub xmlSetStructuredErrorFunc(CStruct, &cb (OpaquePointer, OpaquePointer))                      is native('libxml2')  is export { * }

# Namespaces
sub xmlNewNs(xmlNode, Str, Str)              returns xmlNs  is native('libxml2') is export { * }
sub xmlSearchNsByHref(xmlDoc, xmlNode, Str)  returns xmlNs  is native('libxml2') is export { * }
sub xmlSetNs(xmlNode, xmlNs)                                is native('libxml2') is export { * }
sub xmlGetNsList(xmlDoc, xmlNode)            returns xmlNs  is native('libxml2') is export { * }

# XPath
sub xmlXPathCompile(Str)                                           returns xmlXPathCompExprPtr  is native('libxml2') is export { * }
sub xmlXPathNewContext(xmlDoc)                                     returns xmlXPathContext      is native('libxml2') is export { * }
sub xmlXPathCompiledEval(xmlXPathCompExprPtr, xmlXPathContextPtr)  returns xmlXPathObject       is native('libxml2') is export { * }

# Serialization
sub xmlDocDumpMemory(xmlDoc, CArray, CArray)                                                         is native('libxml2') is export { * }
sub xmlDocDumpFormatMemory(xmlDoc, CArray, CArray, int32)                                            is native('libxml2') is export { * }
sub xmlNodeDump(xmlBuffer, xmlDoc, xmlNode, int32, int32)                             returns int32  is native('libxml2') is export { * }
sub xmlC14NDocDumpMemory(xmlDoc, xmlNodeSet, int32, CArray[Str], int32, CArray[Str])  returns int32  is native('libxml2') is export { * }

sub xmlBufferCreate()                        returns xmlBuffer  is native('libxml2') is export { * }
sub xmlUnlinkNode(xmlNode)                                      is native('libxml2') is export { * }
sub xmlUnsetProp(xmlNode, Str)               returns int32      is native('libxml2') is export { * }
sub xmlChildElementCount(xmlNode)            returns int        is native('libxml2') is export { * }
sub xmlEncodeEntitiesReentrant(xmlDoc, Str)  returns Str        is native('libxml2') is export { * }
