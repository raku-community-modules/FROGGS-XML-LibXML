use v6;

use XML::LibXML::CStructs :types;

class XML::LibXML::Document is xmlDoc is repr('CStruct');

use NativeCall;
use XML::LibXML::Node;

sub xmlNodeGetBase(xmlDoc, xmlDoc)  returns Str                is native('libxml2') { * }
sub xmlDocGetRootElement(xmlDoc)    returns XML::LibXML::Node  is native('libxml2') { * }

method base-uri() {
    xmlNodeGetBase(self.doc, self)
}

method root {
    xmlDocGetRootElement(self)
}
