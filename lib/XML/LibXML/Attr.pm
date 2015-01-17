use v6;

use XML::LibXML::CStructs :types;

class XML::LibXML::Attr is xmlAttr is repr('CStruct');

use NativeCall;

method content() {
    Proxy.new(
        FETCH => -> $ {
            self.children.content
        },
        STORE => -> $, Str $new {
            nqp::bindattr(nqp::decont(self.children), xmlNode, '$!content', $new);
            $new
        }
    )
}
