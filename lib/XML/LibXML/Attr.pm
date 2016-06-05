use v6;
use nqp;

use XML::LibXML::CStructs :types;
use XML::LibXML::Enums;

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

method type() {
    xmlElementType(nqp::p6box_i(nqp::getattr_i(nqp::decont(self), xmlAttr, '$!type')))
}

method firstChild() {
    # We cannot use XML::LibXML::Node here directly because Node.pm 'use's Attr.pm.
    nativecast(::('XML::LibXML::Node'), self.children)
}

multi method gist(XML::LibXML::Attr:D:) {
    self.name ~ '="' ~ self.value ~ '"'
}
