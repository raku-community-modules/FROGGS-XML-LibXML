use v6;
use nqp;

use XML::LibXML::CStructs :types;

unit class XML::LibXML::Attr is xmlAttr is repr('CStruct');

use NativeCall;

method name() {
    self.ns && self.ns.name ?? self.ns.name ~ ':' ~ self.localname !! self.localname
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

multi method gist(XML::LibXML::Attr:D:) {
    self.name ~ '="' ~ self.value ~ '"'
}
