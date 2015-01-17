use v6;

use XML::LibXML::CStructs :types;

class XML::LibXML::Document is xmlDoc is repr('CStruct');

use NativeCall;
use XML::LibXML::Node;

sub xmlNewDoc(Str)                            returns XML::LibXML::Document  is native('libxml2') { * }
sub xmlNodeGetBase(xmlDoc, xmlDoc)            returns Str                    is native('libxml2') { * }
sub xmlDocGetRootElement(xmlDoc)              returns XML::LibXML::Node      is native('libxml2') { * }
sub xmlParseCharEncoding(Str)                 returns int8                   is native('libxml2') { * }
sub xmlGetCharEncodingName(int8)              returns Str                    is native('libxml2') { * }
sub xmlNewNode(xmlDoc, Str)                   returns XML::LibXML::Node      is native('libxml2') { * }
sub xmlNewText(Str)                           returns XML::LibXML::Node      is native('libxml2') { * }
sub xmlNewDocComment(xmlDoc, Str)             returns XML::LibXML::Node      is native('libxml2') { * }
sub xmlNewCDataBlock(xmlDoc, Str, int32)      returns XML::LibXML::Node      is native('libxml2') { * }
sub xmlStrlen(Str)                            returns int32                  is native('libxml2') { * }
sub xmlDocDumpMemory(xmlDoc, CArray, CArray)                                 is native('libxml2') { * }
sub xmlNewDocFragment(xmlDoc)                 returns XML::LibXML::Node      is native('libxml2') { * }
sub xmlNewDocProp(xmlDoc, Str, Str)           returns xmlAttr                is native('libxml2') { * }
sub xmlEncodeEntitiesReentrant(xmlDoc, Str)   returns Str                    is native('libxml2') { * }

method new(:$version = '1.0', :$encoding) {
    my $doc       = xmlNewDoc(~$version);
    $doc.encoding = $encoding if $encoding;
    $doc
}

method Str() {
    my $result = CArray[Str].new();
    my $len    = CArray[int32].new();
    $result[0] = "";
    $len[0]    = 0;
    xmlDocDumpMemory(self, $result, $len);
    $result[0]
}

method root {
    xmlDocGetRootElement(self)
}

method encoding() {
    Proxy.new(
        FETCH => -> $ {
            xmlGetCharEncodingName(self.charset).lc
        },
        STORE => -> $, Str $new {
            my $enc = xmlParseCharEncoding($new);
            die if $enc < 0;
            nqp::bindattr_i(nqp::decont(self), xmlDoc, '$!charset', $enc);
            $new
        }
    )
}

method version() {
    Proxy.new(
        FETCH => -> $ {
            Version.new(nqp::getattr(nqp::decont(self), xmlDoc, '$!version'))
        },
        STORE => -> $, $new {
            nqp::bindattr(nqp::decont(self), xmlDoc, '$!version', nqp::unbox_s(~$new));
            $new
        }
    )
}

method standalone() {
    Proxy.new(
        FETCH => -> $ {
            nqp::p6box_i(nqp::getattr_i(nqp::decont(self), xmlDoc, '$!standalone'))
        },
        STORE => -> $, int32 $new {
            nqp::bindattr_i(nqp::decont(self), xmlDoc, '$!standalone', $new);
            $new
        }
    )
}

method uri() {
    Proxy.new(
        FETCH => -> $ {
            nqp::getattr(nqp::decont(self), xmlDoc, '$!uri')
        },
        STORE => -> $, $new {
            nqp::bindattr(nqp::decont(self), xmlDoc, '$!uri', nqp::unbox_s(~$new));
            $new
        }
    )
}

method base-uri() {
    Proxy.new(
        FETCH => -> $ {
            xmlNodeGetBase(self.doc, self)
        },
        STORE => -> $, $new {
            nqp::bindattr(nqp::decont(self), xmlDoc, '$!uri', nqp::unbox_s(~$new));
            $new
        }
    )
}

method new-doc-fragment() {
    my $node = xmlNewDocFragment( self );
    nqp::bindattr(nqp::decont($node), xmlNode, '$!doc', nqp::decont(self));
    $node
}

method new-elem(Str $elem) {
    my $node = xmlNewNode( self, $elem );
    nqp::bindattr(nqp::decont($node), xmlNode, '$!doc', nqp::decont(self));
    $node
}

multi method new-attr(Pair $kv) {
    my $buffer = xmlEncodeEntitiesReentrant(self, $kv.value);
    my $attr   = xmlNewDocProp(self, $kv.key, $buffer);
    nqp::bindattr(nqp::decont($attr), xmlAttr, '$!doc', nqp::decont(self));
    $attr
}
multi method new-attr(*%kv where *.elems == 1) {
    self.new-attr(%kv.list[0])
}

method new-text(Str $text) {
    my $node = xmlNewText( $text );
    nqp::bindattr(nqp::decont($node), xmlNode, '$!doc', nqp::decont(self));
    $node
}

method new-comment(Str $comment) {
    my $node = xmlNewDocComment( self, $comment );
    nqp::bindattr(nqp::decont($node), xmlNode, '$!doc', nqp::decont(self));
    $node
}

method new-cdata-block(Str $cdata) {
    my $node = xmlNewCDataBlock( self, $cdata, xmlStrlen($cdata) );
    nqp::bindattr(nqp::decont($node), xmlNode, '$!doc', nqp::decont(self));
    $node
}
