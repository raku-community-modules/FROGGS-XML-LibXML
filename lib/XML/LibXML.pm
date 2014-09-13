use v6;

use XML::LibXML::Parser;
class XML::LibXML is XML::LibXML::Parser;

use NativeCall;

method parser-version() { cglobal('libxml2', 'xmlParserVersion', Str) }
