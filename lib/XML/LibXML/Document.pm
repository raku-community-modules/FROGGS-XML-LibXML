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
sub xmlNewDocComment(xmlDoc, Str)             returns XML::LibXML::Node      is native('libxml2') { * }
sub xmlNewCDataBlock(xmlDoc, Str, int32)      returns XML::LibXML::Node      is native('libxml2') { * }
sub xmlAddChild(xmlDoc, xmlDoc)               returns XML::LibXML::Node      is native('libxml2') { * }
sub xmlStrlen(Str)                            returns int32                  is native('libxml2') { * }
sub xmlDocDumpMemory(xmlDoc, CArray, CArray)                                 is native('libxml2') { * }
sub xmlNewDocFragment(xmlDoc)                 returns xmlNode                is native('libxml2') { * }

method new(:$version = '1.0', :$encoding) {
    my $doc       = xmlNewDoc(~$version);
    $doc.encoding = $encoding if $encoding;
    $doc
}

method Str() {
    my $result = CArray[Str].new();
    my $len = CArray[int32].new();
    $result[0] = "";
    $result[1] = "";
    $len[0] = 0;
    $len[1] = 0;
    xmlDocDumpMemory(self, $result, $len);
    say $len[0];
    say $len[1];
    $result[0] ~
    $result[1]
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
