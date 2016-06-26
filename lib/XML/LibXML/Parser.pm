use v6;

use nqp;

use NativeCall;
use XML::LibXML::CStructs :types;
use XML::LibXML::Enums;

unit class XML::LibXML::Parser is xmlParserCtxt is repr('CStruct');

my $ERRNO = cglobal(Str, 'errno', int32);

sub strerror(int32) is native { * }

use XML::LibXML::Document;
use XML::LibXML::Dom;
#use XML::LibXML::Element;
use XML::LibXML::Subs;
use XML::LibXML::Error;
use XML::LibXML::Enums;

sub xmlCtxtReadDoc(xmlParserCtxt, Str, Str, Str, int32)  returns XML::LibXML::Document is native('xml2') { * }
sub xmlCtxtReadFile(xmlParserCtxt, Str, Str, int32)      returns XML::LibXML::Document is native('xml2') { * }
sub xmlNewParserCtxt                                     returns XML::LibXML::Parser   is native('xml2') { * }
sub xmlReadDoc(Str, Str, Str, int32)                     returns XML::LibXML::Document is native('xml2') { * }
sub xmlReadMemory(Str, int32, Str, Str, int32)           returns XML::LibXML::Document is native('xml2') { * }
sub htmlNewParserCtxt                                    returns XML::LibXML::Parser   is native('xml2') { * }
sub htmlParseFile(Str, Str)                              returns XML::LibXML::Document is native('xml2') { * }
sub htmlCtxtReadDoc(xmlParserCtxt, Str, Str, Str, int32) returns XML::LibXML::Document is native('xml2') { * }
sub htmlCtxtReadFile(xmlParserCtxt, Str, Str, int32)     returns XML::LibXML::Document is native('xml2') { * }

method new(:$html = False) {
    xmlKeepBlanksDefault($html ?? 0 !! 1);
    my $self = $html
            ?? htmlNewParserCtxt()
            !! xmlNewParserCtxt();

    # This stops xml2 printing errors to stderr
    xmlSetStructuredErrorFunc($self, -> OpaquePointer, OpaquePointer { });
    $self
}

method parse(Str:D $str, Str :$uri, :$flags = self.html == 1 ?? HTML_PARSE_RECOVER + HTML_PARSE_NOBLANKS !! 0) {
    my $doc = self.html == 1
            ?? htmlCtxtReadDoc(self, $str, $uri, Str, +$flags)
            !! xmlCtxtReadDoc(self, $str, $uri, Str, +$flags);
    fail XML::LibXML::Error.get-last(self, :orig($str)) unless $doc;
    $doc
}

method parse-string($str) {
    return unless $str.defined;
    self.parse($str, :uri(Str));
}

multi method parse-file(Str $s) {
    unless $s.chars && $s.IO.e {
        warn "Attempted to parse using" ~ (!$s.defined || !$s.chars) ??
            "null filename" !! "bad filename '{$s}'";
        return;
    }

    # cw: Should we assume unicode, here or just use default?
    # cw: What about defined options? -- For now we set blank, but that might 
    #     come a-haunting in the future.
    self.html ?? 
        #htmlCtxtReadFile(self, $s, "UTF8", self.options)
        htmlCtxtReadFile(self, $s, Str, 0)
        !!
        #xmlCtxtReadFile(self, $s, "UTF8", self.options)
        xmlCtxtReadFile(self, $s, Str, 0)
}

method parse-xml-chunk($_xml) {
    die "parse-xml-chunk is not a class method" unless self.defined;

    my $xml = $_xml.defined ?? $_xml.trim !! Nil;
    return unless $xml.defined && $xml.chars;

    # cw: The naked 0 below may not be correct.
    my $ret = domReadWellBalancedString(xmlDoc, $xml, 0);
    my $frag;
    if $ret.defined {
        my $end;

        # cw: Could we make class methods for these?
        $frag = XML::LibXML::Document.new-doc-fragment;
        # cw: Also might want to make a helper function for this.
        nqp::bindattr(
            nqp::decont($frag),
            xmlNode,
            '$!children',
            nqp::decont(nativecast(xmlNodePtr, $ret))
        );
        $end = $ret;
        while $end.next.defined {
            $end.parent = nativecast(xmlNodePtr, $frag);
            $end = nativecast(xmlNode, $end.next);
        }
        nqp::bindattr(
            nqp::decont($end),
            xmlNode,
            '$!parent',
            nqp::decont(nativecast(xmlNodePtr, $frag))
        );
        nqp::bindattr(
            nqp::decont(nativecast(xmlNode, $frag)),
            xmlNode,
            '$!last',
            nqp::decont(nativecast(xmlNodePtr, $end))
        );
    }
    $frag;
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
