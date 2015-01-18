use v6;

use XML::LibXML::CStructs :types;

class XML::LibXML::Document is xmlDoc is repr('CStruct');

use NativeCall;
use XML::LibXML::Node;
use XML::LibXML::Attr;
use XML::LibXML::Enums;

sub xmlNewDoc(Str)                            returns XML::LibXML::Document  is native('libxml2') { * }
sub xmlNodeGetBase(xmlDoc, xmlDoc)            returns Str                    is native('libxml2') { * }
sub xmlDocGetRootElement(xmlDoc)              returns XML::LibXML::Node      is native('libxml2') { * }
sub xmlDocSetRootElement(xmlDoc, xmlNode)     returns XML::LibXML::Node      is native('libxml2') { * }
sub xmlParseCharEncoding(Str)                 returns int8                   is native('libxml2') { * }
sub xmlGetCharEncodingName(int8)              returns Str                    is native('libxml2') { * }
sub xmlNewNode(xmlDoc, Str)                   returns XML::LibXML::Node      is native('libxml2') { * }
sub xmlNewText(Str)                           returns XML::LibXML::Node      is native('libxml2') { * }
sub xmlNewDocComment(xmlDoc, Str)             returns XML::LibXML::Node      is native('libxml2') { * }
sub xmlNewCDataBlock(xmlDoc, Str, int32)      returns XML::LibXML::Node      is native('libxml2') { * }
sub xmlStrlen(Str)                            returns int32                  is native('libxml2') { * }
sub xmlDocDumpMemory(xmlDoc, CArray, CArray)                                 is native('libxml2') { * }
sub xmlReplaceNode(xmlNode, xmlNode)          returns XML::LibXML::Node      is native('libxml2') { * }
sub xmlNewDocFragment(xmlDoc)                 returns XML::LibXML::Node      is native('libxml2') { * }
sub xmlNewDocProp(xmlDoc, Str, Str)           returns XML::LibXML::Attr      is native('libxml2') { * }
sub xmlNewDocNode(xmlDoc, xmlNs, Str, Str)    returns XML::LibXML::Node      is native('libxml2') { * }
sub xmlEncodeEntitiesReentrant(xmlDoc, Str)   returns Str                    is native('libxml2') { * }
sub xmlNewNs(xmlNode, Str, Str)               returns xmlNs                  is native('libxml2') { * }
sub xmlSearchNsByHref(xmlDoc, xmlNode, Str)   returns xmlNs                  is native('libxml2') { * }
sub xmlSetNs(xmlNode, xmlNs)                                                 is native('libxml2') { * }
sub xmlXPathCompile(Str)                      returns xmlXPathCompExprPtr    is native('libxml2') { * }
sub xmlXPathNewContext(xmlDoc)                returns xmlXPathContextPtr     is native('libxml2') { * }
sub xmlXPathCompiledEval(xmlXPathCompExprPtr, xmlXPathContextPtr)  returns xmlXPathObject  is native('libxml2') { * }

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
    Proxy.new(
        FETCH => -> $ {
            xmlDocGetRootElement(self)
        },
        STORE => -> $, $new {
            my $root = xmlDocGetRootElement(self);
            $root ?? xmlReplaceNode($root, $new)
                  !! xmlDocSetRootElement(self, $new);
            $new
        }
    )
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

multi method new-elem-ns(Pair $kv, $uri) {
    my ($prefix, $name) = $kv.key.split(':', 2);

    unless $name {
        $name   = $prefix;
        $prefix = Str;
    }

    my $ns = xmlNewNs(xmlDoc, $uri, $prefix);

    my $buffer = $kv.value && xmlEncodeEntitiesReentrant(self, $kv.value);
    my $node   = xmlNewDocNode(self, $ns, $name, $buffer);
    nqp::bindattr(nqp::decont($node), xmlNode, '$!nsDef', nqp::decont($ns));
    nqp::bindattr(nqp::decont($node), xmlNode, '$!doc',   nqp::decont(self));
    $node
}
multi method new-elem-ns(%kv where *.elems == 1, $uri) {
    self.new-elem-ns(%kv.list[0], $uri)
}
multi method new-elem-ns($name, $uri) {
    self.new-elem-ns($name => Str, $uri)
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

multi method new-attr-ns(Pair $kv, $uri) {
    my $root = self.root;
    fail "Can't create a new namespace on an attribute!" unless $root;

    my ($prefix, $name) = $kv.key.split(':', 2);

    unless $name {
        $name   = $prefix;
        $prefix = Str;
    }

    my $ns = xmlSearchNsByHref(self, $root, $uri)
          || xmlNewNs($root, $uri, $prefix); # create a new NS if the NS does not already exists

    my $buffer = xmlEncodeEntitiesReentrant(self, $kv.value);
    my $attr   = xmlNewDocProp(self, $name, $buffer);
    xmlSetNs($attr, $ns);
    nqp::bindattr(nqp::decont($attr), xmlAttr, '$!doc', nqp::decont(self));
    $attr
}
multi method new-attr-ns(%kv where *.elems == 1, $uri) {
    self.new-attr-ns(%kv.list[0], $uri)
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

method find($xpath) {
    my $comp = xmlXPathCompile($xpath);
    my $ctxt = xmlXPathNewContext(self.doc);
    my $res  = xmlXPathCompiledEval($comp, $ctxt);
    do given xmlXPathObjectType($res.type) {
        when XPATH_UNDEFINED {
            Nil
        }
        when XPATH_NODESET {
            my $set = $res.nodesetval;
            (^$set.nodeNr).map: {
                nativecast(XML::LibXML::Node, $set.nodeTab[$_])
            }
        }
        when XPATH_BOOLEAN {
            so $res.boolval
        }
        when XPATH_NUMBER {
            $res.floatval
        }
        when XPATH_STRING {
            $res.stringval
        }
        default {
            fail "NodeSet type $_ NYI"
        }
    }
}
