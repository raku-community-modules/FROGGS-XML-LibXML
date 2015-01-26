class XML::LibXML is xmlParserCtxt is repr('CStruct') {
    method parser-version() {
        my $ver = cglobal('libxml2', 'xmlParserVersion', Str);
        Version.new($ver.match(/ (.)? (..)+ $/).list.join: '.')
    }

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
}

sub parse-xml(Str $xml) is export {
    XML::LibXML.new.parse($xml)
}
