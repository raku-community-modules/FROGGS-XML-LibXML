use v6;

use XML::LibXML::CStructs :types;

class XML::LibXML::Node is xmlNode is repr('CStruct');

use NativeCall;

sub xmlNodeGetBase(xmlNode, xmlNode)  returns Str  is native('libxml2') { * }

method base-uri() {
    xmlNodeGetBase(self.doc, self)
}
