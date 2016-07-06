use v6;

use nqp;
use NativeCall;

use XML::LibXML::CStructs :types;
use XML::LibXML::Enums;
use XML::LibXML::Subs;

multi trait_mod:<is>(Routine $r, :$aka!) { $r.package.^add_method($aka, $r) };

unit class XML::LibXML::Attr is xmlAttr is repr('CStruct');

sub xmlXPathCastNodeToString(xmlNode)   returns Str   is native('xml2') { * }

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
            #nativecast(xmlNode, self.children).value;
            xmlXPathCastNodeToString(self.getNode);
        },
        STORE => -> $, Str $new {
            setObjAttr(self.children, '$!value', $new);
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

multi method gist(XML::LibXML::Attr:D: :$entities) {
    qq< {self.name}="{self.serializeContent(:$entities)}">;
}

multi method Str(XML::LibXML::Attr:D: :$entities) {
    self.gist(:$entities);
}

method toString(XML::LibXML::Attr:D: :$entities) {
    self.gist(:$entities);
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

method serializeContent(:$entities) {
    sub xmlAttrSerializeTxtContent(xmlBuffer, xmlDoc, xmlAttr, Str) is native('xml2') { * };
    sub xmlGetDocEntity(xmlDoc, Str) returns OpaquePointer          is native('xml2') { * };
    sub xmlGetDtdEntity(xmlDoc, Str) returns OpaquePointer          is native('xml2') { * };

    # cw: Is the speed increase of using libxml2 for basic string ops
    #     worth the hassle?
    #my $parser = $entities.defined ?? XML::LibXML::Parser.new;
    my $buffer = xmlBufferCreate();
    my $child = self.children;
    while $child.defined {
        my $child_o = nativecast(::('XML::LibXML::Node'), $child);

        given $child_o.type {
            when XML_TEXT_NODE {
                xmlAttrSerializeTxtContent(
                    $buffer, self.doc, self, $child_o.value
                );
            }

            when XML_ENTITY_REF_NODE {
                my $str; 

                if $entities.defined && $entities {
                    if  xmlGetDocEntity(self.doc, $child_o.localname) ||
                        xmlGetDtdEntity(self.doc, $child_o.localname)
                    {
                        $str = xmlXPathCastNodeToString($child_o.getNode);
                    }
                } else {
                    $str = "\&{$child_o.localname};";
                }
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