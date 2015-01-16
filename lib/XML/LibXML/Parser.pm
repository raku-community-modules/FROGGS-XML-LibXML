use v6;

use XML::LibXML::CStructs :types;

class XML::LibXML::Parser is xmlParserCtxt is repr('CStruct');

use NativeCall;
use XML::LibXML::Document;
use XML::LibXML::Node;
use XML::LibXML::Error;
use XML::LibXML::XPathExpression;

sub xmlInitParser()                                                                        is native('libxml2') { * }
sub xmlCtxtReadDoc(XML::LibXML::Parser, Str, Str, Str, Int)  returns XML::LibXML::Document is native('libxml2') { * }
sub xmlNewParserCtxt                                         returns XML::LibXML::Parser   is native('libxml2') { * }
sub xmlReadDoc(Str, Str, Str, Int)                           returns XML::LibXML::Document is native('libxml2') { * }
sub xmlReadMemory(Str, Int, Str, Str, Int)                   returns XML::LibXML::Document is native('libxml2') { * }
sub htmlParseFile(Str, Str)                                  returns XML::LibXML::Document is native('libxml2') { * }
sub htmlCtxtReadDoc(XML::LibXML::Parser, Str, Str, Str, Int) returns XML::LibXML::Document is native('libxml2') { * }


method new {
    my $self = xmlNewParserCtxt();

    # This stops libxml2 printing errors to stderr
    xmlSetStructuredErrorFunc($self, -> OpaquePointer, OpaquePointer { });
    $self
}

method parse-str(Str:D $str, Str :$url) {
    my $doc = xmlCtxtReadDoc(self, $str, $url, Str, 0);
    fail XML::LibXML::Error.get-last(self, :orig($str)) unless $doc;
    $doc
}

method parse-html(Str:D $str, Str :$url) {
    my $doc = htmlCtxtReadDoc(self, $str, $url, Str, 0);
    fail XML::LibXML::Error.get-last(self, :orig($str)) unless $doc;
    $doc
}
