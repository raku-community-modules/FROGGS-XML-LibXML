use v6;

use XML::LibXML::Parser;
class XML::LibXML is XML::LibXML::Parser;

use NativeCall;

method parser-version() {
    my $ver = cglobal('libxml2', 'xmlParserVersion', Str);
    Version.new($ver.match(/ (.)? (..)+ $/).list.join: '.')
}
