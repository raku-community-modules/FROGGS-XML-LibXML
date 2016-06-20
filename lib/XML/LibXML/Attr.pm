use v6;
use nqp;

use XML::LibXML::CStructs :types;
use XML::LibXML::Enums;
use XML::LibXML::Subs;

unit class XML::LibXML::Attr is xmlAttr is repr('CStruct');

use NativeCall;

# cw: Constantly calling refresh may kill performance... so is there a way to check
#     if the underlying object really needs it?

method name() {
    nqp::nativecallrefresh(self);
    self.ns && self.ns.name ?? self.ns.name ~ ':' ~ self.localname !! self.localname
}

method value() {
    nqp::nativecallrefresh(self);
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
    nqp::nativecallrefresh(self);
    xmlElementType(nqp::p6box_i(nqp::getattr_i(nqp::decont(self), xmlAttr, '$!type')))
}

method firstChild() {
    nqp::nativecallrefresh(self);
    # We cannot use XML::LibXML::Node here directly because Node.pm 'use's Attr.pm.
    nativecast(::('XML::LibXML::Node'), self.children)
}

multi method gist(XML::LibXML::Attr:D:) {
    self.name ~ '="' ~ self.value ~ '"'
}

method toString(XML::LibXML::Attr:D:) {
    self.gist();
}

# cw: See the need to break out similar operations for all XML nodes into a specific role 
#     (ala XML::LibXML::Nodish) otherwise we will end up duplicating functionality across
#     several classes.

method isSameNode($n) {
    # cw: Maybe.

    # cw: Not. The issue here is that P6 is creating these objects from 
    #     the backing C-pointer which is lost in the shuffle. So two objects
    #     can be created from the -same- pointer but have no sense of 
    #     equivalence (unless... possibly... the repr is 'CPointer')
    return self =:= $n;
}

method ownerDocument {
    return nativecast(::('XML::LibXML::Document'), self.doc);
}

method ownerElement {
    return nativecast(::('XML::LibXML::Node'), self.parent);
}

method getContent() {
    return xmlNodeGetContent( nativecast(::('XML::LibXML::Node'), self) );
}
