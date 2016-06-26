use v6;

use NativeCall;
use XML::LibXML::Document;
use XML::LibXML::Parser;

unit class XML::LibXML is XML::LibXML::Parser;

method parser-version() {
    my $ver = cglobal('xml2', 'xmlParserVersion', Str);
    Version.new($ver.match(/ (.)? (..)+ $/).list.join: '.')
}

sub parse-xml(Str $xml) is export {
    nativecast(
    	XML::LibXML::Document, 
    	XML::LibXML::Parser.new.parse($xml)
	);
}

sub parse-html(Str $html) is export {
	nativecast(
		XML::LibXML::Document,
    	XML::LibXML::Parser.new(:html).parse($html)
	);
}

sub parse-string(Str $s) is export {
	nativecast(
		XML::LibXML::Document,
		XML::LibXML::Parser.new.parse-string($s)
	);
}

sub parse-file(Str $filename) is export {
	nativecast(
		XML::LibXML::Document,
		XML::LibXML::Parser.new.parse-file($filename) 
	);
}
