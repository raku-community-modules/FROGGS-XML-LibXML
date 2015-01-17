use v6;

use XML::LibXML::CStructs :types;

class XML::LibXML::Document is xmlDoc is repr('CStruct');

use NativeCall;
use XML::LibXML::Node;

sub xmlNewDoc(Str)                  returns XML::LibXML::Document  is native('libxml2') { * }
sub xmlNodeGetBase(xmlDoc, xmlDoc)  returns Str                    is native('libxml2') { * }
sub xmlDocGetRootElement(xmlDoc)    returns XML::LibXML::Node      is native('libxml2') { * }
sub xmlParseCharEncoding(Str)       returns int8                   is native('libxml2') { * }
sub xmlGetCharEncodingName(int8)    returns Str                    is native('libxml2') { * }

method new(:$version = '1.0', :$encoding) {
    my $doc       = xmlNewDoc($version);
    $doc.encoding = $encoding if $encoding;
    $doc
}

method base-uri() {
    xmlNodeGetBase(self.doc, self)
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
            nqp::bindattr(nqp::decont(self), xmlDoc, '$!version', ~$new);
            $new
        }
    )
}
