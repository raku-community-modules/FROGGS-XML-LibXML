use v6;

use XML::LibXML::Parser;
class XML::LibXML is XML::LibXML::Parser;

use NativeCall;

our sub LIBXML_VERSION returns Str is cglobal('libxml2') is symbol('xmlParserVersion') { * }
method parser-version() { LIBXML_VERSION }
