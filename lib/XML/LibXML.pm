use v6;

class XML::LibXML;

use NativeCall;

our sub LIBXML_VERSION returns Str is cglobal('libxml2') is symbol('xmlParserVersion') { * }
method parser-version() { LIBXML_VERSION }
