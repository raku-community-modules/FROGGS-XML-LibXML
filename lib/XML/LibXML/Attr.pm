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

# cw: This might be better off in XML::LibXML::Nodish if Attrs are actually 
#     xmlNodes
method value() {
    nqp::nativecallrefresh(self);
    Proxy.new(
        FETCH => -> $ {
            nativecast(xmlNode, self.children).value;
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
    my $n1 = nativecast(Pointer, self);
    my $n2 = nativecast(Pointer, $n);
    return +$n1 == +$n2;
}

method ownerDocument {
    nqp::nativecallrefresh(self);
    return nativecast(::('XML::LibXML::Document'), self.doc);
}

method ownerElement {
    nqp::nativecallrefresh(self);
    return nativecast(::('XML::LibXML::Node'), self.parent);
}

method getContent() {
    #return xmlNodeGetContent( nativecast(::('XML::LibXML::Node'), self) );
    sub xmlXPathCastNodeToString(xmlNode)   returns Str   is native('xml2') { * }
    xmlXPathCastNodeToString( nativecast(::('XML::LibXML::Node'), self) );
}

method getAttrPtr() {
    nativecast(xmlAttrPtr, self);
}