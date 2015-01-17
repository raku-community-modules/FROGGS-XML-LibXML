use v6;

use XML::LibXML::CStructs :types;
use XML::LibXML::Enums;

class XML::LibXML::Node is xmlNode is repr('CStruct');

use NativeCall;

sub xmlNodeGetBase(xmlNode, xmlNode)  returns Str  is native('libxml2') { * }

method base-uri() {
    xmlNodeGetBase(self.doc, self)
}

method type() {
    xmlElementType(nqp::p6box_i(nqp::getattr_i(nqp::decont(self), xmlNode, '$!type')))
}