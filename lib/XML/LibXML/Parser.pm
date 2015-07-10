use v6;

use NativeCall;
use XML::LibXML::CStructs :types;

unit class XML::LibXML::Parser is xmlParserCtxt is repr('CStruct');

use XML::LibXML::Document;
use XML::LibXML::Subs;
use XML::LibXML::Error;

sub xmlCtxtReadDoc(xmlParserCtxt, Str, Str, Str, Int)  returns XML::LibXML::Document is native('libxml2') { * }
sub xmlNewParserCtxt                                   returns XML::LibXML::Parser   is native('libxml2') { * }
sub xmlReadDoc(Str, Str, Str, Int)                     returns XML::LibXML::Document is native('libxml2') { * }
sub xmlReadMemory(Str, Int, Str, Str, Int)             returns XML::LibXML::Document is native('libxml2') { * }
sub htmlParseFile(Str, Str)                            returns XML::LibXML::Document is native('libxml2') { * }
sub htmlCtxtReadDoc(xmlParserCtxt, Str, Str, Str, Int) returns XML::LibXML::Document is native('libxml2') { * }


method new {
    my $self = xmlNewParserCtxt();

    # This stops libxml2 printing errors to stderr
    xmlSetStructuredErrorFunc($self, -> OpaquePointer, OpaquePointer { });
    $self
}

method parse(Str:D $str, Str :$uri) {
    my $doc = xmlCtxtReadDoc(self, $str, $uri, Str, 0);
    fail XML::LibXML::Error.get-last(self, :orig($str)) unless $doc;
    $doc
}

method parse-html(Str:D $str, Str :$uri) {
    my $doc = htmlCtxtReadDoc(self, $str, $uri, Str, 0);
    fail XML::LibXML::Error.get-last(self, :orig($str)) unless $doc;
    $doc
}
