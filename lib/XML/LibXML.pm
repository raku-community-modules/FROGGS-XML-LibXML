use v6;

use NativeCall;
use XML::LibXML::Parser;

unit class XML::LibXML is XML::LibXML::Parser;

method parser-version() {
    my $ver = cglobal('xml2', 'xmlParserVersion', Str);
    Version.new($ver.match(/ (.)? (..)+ $/).list.join: '.')
}

sub parse-xml(Str $xml) is export {
    XML::LibXML::Parser.new.parse($xml)
}

sub parse-html(Str $html) is export {
    XML::LibXML::Parser.new(:html).parse($html)
}

sub parse-string(Str $s) is export {
	XML::LibXML::Parser.new.parse-string($s);
}

sub parse-file(Str $s) is export {
	XML::LibXML::Parser.new.parse-file($) 
}
