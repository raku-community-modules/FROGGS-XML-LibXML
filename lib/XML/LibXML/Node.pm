use v6;

use XML::LibXML::CStructs :types;
use XML::LibXML::Enums;

class XML::LibXML::Node is xmlNode is repr('CStruct');

use NativeCall;

sub xmlNodeGetBase(xmlNode, xmlNode)                       returns Str                is native('libxml2') { * }
sub xmlBufferCreate()                                      returns xmlBuffer          is native('libxml2') { * }
sub xmlNodeDump(xmlBuffer, xmlDoc, xmlNode, int32, int32)  returns int32              is native('libxml2') { * }

method base-uri() {
    xmlNodeGetBase(self.doc, self)
}

method type() {
    xmlElementType(nqp::p6box_i(nqp::getattr_i(nqp::decont(self), xmlNode, '$!type')))
}

method Str() {
    my $buffer = xmlBufferCreate(); # XXX free
    my $size   = xmlNodeDump($buffer, self.doc, self, 0, 1);
    $buffer.content;
}
