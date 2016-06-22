use lib 't';
use CompileTestLib;
use NativeCall;
use Test;
use XML::LibXML::CStructs :types;

plan 19;

compile_test_lib('00-structure-sizes');

for xmlAttr,
    xmlAttributeType,
    xmlBuffer,
    xmlBufferAllocationScheme,
    xmlChar,
    xmlDoc,
    xmlError,
    xmlElement,
    xmlNode,
    xmlNodeSet,
    xmlNs,
    xmlParserCtxt,
    xmlParserInputState,
    xmlParserMode,
    xmlParserNodeInfo,
    xmlParserNodeInfoSeq,
    xmlSAXHandler,
    xmlValidCtxt,
    xmlXPathContext,
    xmlXPathObject
{
    sub sizeof() returns int32 { ... }
    trait_mod:<is>(&sizeof, :native('./00-structure-sizes'));
    trait_mod:<is>(&sizeof, :symbol('sizeof_' ~ $_.^name));

    is nativesizeof($_), sizeof(), "sizeof($_.^name())";
}
