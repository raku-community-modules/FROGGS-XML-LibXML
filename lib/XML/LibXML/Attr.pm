use v6;

use XML::LibXML::CStructs :types;

class XML::LibXML::Attr is xmlAttr is repr('CStruct');

use NativeCall;

method content() {
    self.children.content
}
