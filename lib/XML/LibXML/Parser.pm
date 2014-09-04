use v6;

class XML::LibXML::Parser;

use NativeCall;
use XML::LibXML::Document;
use XML::LibXML::Error;

has $.ctx;

sub xmlInitParser()                                                                is native('libxml2') { * }
sub xmlCtxtReadDoc(OpaquePointer,Str, Str, Str, Int) returns XML::LibXML::Document is native('libxml2') { * }
sub xmlNewParserCtxt                                 returns OpaquePointer         is native('libxml2') { * }
sub xmlReadDoc(Str, Str, Str, Int)                   returns XML::LibXML::Document is native('libxml2') { * }
sub xmlReadMemory(Str, Int, Str, Str, Int)           returns XML::LibXML::Document is native('libxml2') { * }

submethod BUILD {
    $!ctx = xmlNewParserCtxt();

    # This stops libxml2 printing errors to stderr
    xmlSetStructuredErrorFunc($!ctx, -> OpaquePointer, OpaquePointer { });
}

method parse-str(Str:D $str) {
    my $doc = xmlCtxtReadDoc($!ctx, $str, Str, Str, 0);
    return XML::LibXML::Error.get-last($!ctx) unless $doc;
    $doc
}
