use v6;

use XML::LibXML::CStructs :types;

class XML::LibXML::Attr is xmlAttr is repr('CStruct');

use NativeCall;

method name() {
    self.ns.name ?? self.ns.name ~ ':' ~ self.localname !! self.localname
}

method value() {
    Proxy.new(
        FETCH => -> $ {
            self.children.value
        },
        STORE => -> $, Str $new {
            nqp::bindattr(nqp::decont(self.children), xmlNode, '$!value', $new);
            $new
        }
    )
}
