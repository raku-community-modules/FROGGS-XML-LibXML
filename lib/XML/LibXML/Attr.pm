class XML::LibXML::Attr is xmlAttr is repr('CStruct') {
    method name() {
        self.ns.name ?? self.ns.name ~ ':' ~ self.localname !! self.localname
    }

    method value() {
        Proxy.new(
            FETCH => -> $ {
                self.children.value
            },
            STORE => -> $, Str $new {
                nqp::bindattr(nqp::decont(self.children), XML::LibXML::Node, '$!value', $new);
                $new
            }
        )
    }
}
