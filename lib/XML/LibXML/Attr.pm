use v6;
use nqp;

use XML::LibXML::CStructs :types;
use XML::LibXML::Enums;
use XML::LibXML::Subs;

multi trait_mod:<is>(Routine $r, :$aka!) { $r.package.^add_method($aka, $r) };

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
    sub xmlXPathCastNodeToString(xmlNode)   returns Str   is native('xml2') { * }
    
    nqp::nativecallrefresh(self);
    Proxy.new(
        FETCH => -> $ {
            #nativecast(xmlNode, self.children).value;
            xmlXPathCastNodeToString( nativecast(xmlNode, self) );
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
    " {self.name}=\"{self.serializeContent}\"";
}

multi method Str(XML::LibXML::Attr:D:) {
    self.gist;
}

method toString(XML::LibXML::Attr:D:) {
    self.gist;
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
}

method getAttrPtr() {
    nativecast(xmlAttrPtr, self);
}

method getNodePtr() {
    nativecast(xmlNodePtr, self);
}

method serializeContent {
    sub xmlAttrSerializeTxtContent(xmlBuffer, xmlDoc, xmlAttr, Str) is native('xml2') { * };

    my $buffer = xmlBufferCreate();
    my $child = self.children;
    while $child.defined {
        my $child_o = nativecast(xmlNode, $child);

        given $child_o.type {
            when XML_TEXT_NODE {
                xmlAttrSerializeTxtContent(
                    $buffer, self.doc, self, $child_o.value
                );
            }

            when XML_ENTITY_REF_NODE {
                my $str = "\&{$child_o.localname};";
                xmlBufferAdd($buffer, $str, $str.chars);
            }
        }
        $child = $child_o.next;
    }

    my $ret;
    if xmlBufferLength($buffer) > 0 { 
        $ret = xmlBufferContent($buffer);
        xmlBufferFree($buffer);
    }
    $ret;
}