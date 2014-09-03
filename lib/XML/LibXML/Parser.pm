use v6;

class XML::LibXML::Parser;

use NativeCall;
use XML::LibXML::Document;

sub xmlInitParser()                                                      is native('libxml2') { * }
sub xmlReadDoc(Str, Str, Str, Int)         returns XML::LibXML::Document is native('libxml2') { * }
sub xmlReadMemory(Str, Int, Str, Str, Int) returns XML::LibXML::Document is native('libxml2') { * }

method parse-str(Str:D $str) {
    xmlReadDoc($str, Str, Str, 0)
}
