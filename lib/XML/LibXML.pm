use v6;

use NativeCall;
use XML::LibXML::Document;
use XML::LibXML::Parser;

unit class XML::LibXML is XML::LibXML::Parser;

method new(:$flags) {
	nextwith(:$flags);
}

method parser-version() {
    my $ver = cglobal('xml2', 'xmlParserVersion', Str);
    Version.new($ver.match(/ (.)? (..)+ $/).list.join: '.')
}

sub parse-xml(Str $xml, :$flags) is export {
    nativecast(
    	XML::LibXML::Document, 
    	XML::LibXML::Parser.new.parse($xml, :$flags)
	);
}

sub parse-html(Str $html, :$flags) is export {
	nativecast(
		XML::LibXML::Document,
    	XML::LibXML::Parser.new(:html).parse($html, :$flags)
	);
}

sub parse-string(Str $s, :$url, :$flags) is export {
	nativecast(
		XML::LibXML::Document,
		XML::LibXML::Parser.new.parse-string($s, :$url, :$flags)
	);
}

sub parse-file(Str $filename, :$flags) is export {
	nativecast(
		XML::LibXML::Document,
		XML::LibXML::Parser.new.parse-file($filename, :$flags) 
	);
}
