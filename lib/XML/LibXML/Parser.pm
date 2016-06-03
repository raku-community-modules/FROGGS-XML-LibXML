use v6;

use NativeCall;
use XML::LibXML::CStructs :types;
use XML::LibXML::Enums;

unit class XML::LibXML::Parser is xmlParserCtxt is repr('CStruct');

use XML::LibXML::Document;
use XML::LibXML::Subs;
use XML::LibXML::Error;
use XML::LibXML::Enums;

sub xmlCtxtReadDoc(xmlParserCtxt, Str, Str, Str, int32)  returns XML::LibXML::Document is native('xml2') { * }
sub xmlNewParserCtxt                                     returns XML::LibXML::Parser   is native('xml2') { * }
sub xmlReadDoc(Str, Str, Str, int32)                     returns XML::LibXML::Document is native('xml2') { * }
sub xmlReadMemory(Str, int32, Str, Str, int32)           returns XML::LibXML::Document is native('xml2') { * }
sub htmlNewParserCtxt                                    returns XML::LibXML::Parser   is native('xml2') { * }
sub htmlParseFile(Str, Str)                              returns XML::LibXML::Document is native('xml2') { * }
sub htmlCtxtReadDoc(xmlParserCtxt, Str, Str, Str, int32) returns XML::LibXML::Document is native('xml2') { * }


method new {
    xmlKeepBlanksDefault(0); # 1 for XML
    #~ my $self = xmlNewParserCtxt();
    my $self = htmlNewParserCtxt();

    # This stops xml2 printing errors to stderr
    xmlSetStructuredErrorFunc($self, -> OpaquePointer, OpaquePointer { });
    $self
}

method parse(Str:D $str, Str :$uri) {
    my $doc = xmlCtxtReadDoc(self, $str, $uri, Str, 0);
    fail XML::LibXML::Error.get-last(self, :orig($str)) unless $doc;
    $doc
}

method parse-html(Str:D $str, Str :$uri, :$flags = HTML_PARSE_RECOVER + HTML_PARSE_NOBLANKS) {
    my $doc = htmlCtxtReadDoc(self, $str, $uri, Str, +$flags);
    fail XML::LibXML::Error.get-last(self, :orig($str)) unless $doc;
    $doc
}

#~ multi method expand-entities() {
    #~ sub xmlCtxtUseOptions(xmlParserCtxt, int32)                     returns int32 is native('xml2') { * }
    #~ say self.replaceEntities;
    #~ say xmlCtxtUseOptions(self, XML_PARSE_NOENT);
    #~ say self.replaceEntities;
    
    #~ if (scalar(@_) and $_[0]) {
      #~ return $self->__parser_option(XML_PARSE_NOENT | XML_PARSE_DTDLOAD,1);
    #~ }
    #~ return $self->__parser_option(XML_PARSE_NOENT,@_);
#~ }
#~ multi method expand-entities() {
    #~ my $self = shift;
    #~ if (scalar(@_) and $_[0]) {
      #~ return $self->__parser_option(XML_PARSE_NOENT | XML_PARSE_DTDLOAD,1);
    #~ }
    #~ return $self->__parser_option(XML_PARSE_NOENT,@_);
#~ }
