use v6;

use NativeCall;
use XML::LibXML::Document;
use XML::LibXML::Parser;

# cw: This is causing confusion with the wrappers and may need to be 
#     rewritten to remove ambiguation.
#unit class XML::LibXML is XML::LibXML::Parser;
unit class XML::LibXML;

method new(:$flags) {
#	nextwith(:$flags);
}

method parser-version() {
    my $ver = cglobal('xml2', 'xmlParserVersion', Str);
    Version.new($ver.match(/ (.)? (..)+ $/).list.join: '.')
}

sub parse-xml(Str $xml, :$flags) is export {
	my $ret = XML::LibXML::Parser.new.parse($xml, :$flags);
	return unless $ret.defined;
    nativecast(XML::LibXML::Document, $ret);
}

sub parse-html(Str $html, :$flags) is export {
	my $ret = XML::LibXML::Parser.new(:html).parse($html, :$flags);
	return unless $ret.defined;
	nativecast(XML::LibXML::Document, $ret);
}

sub parse-string(Str $s, :$url, :$flags) is export {
	my $ret = XML::LibXML::Parser.new.parse-string($s, :$url, :$flags);
	return unless $ret.defined;
	nativecast(XML::LibXML::Document, $ret);
}

sub parse-file(Str $filename, :$flags) is export {
	my $ret = XML::LibXML::Parser.new.parse-file($filename);
	return unless $ret.defined;
	nativecast(XML::LibXML::Document, $ret);
}
