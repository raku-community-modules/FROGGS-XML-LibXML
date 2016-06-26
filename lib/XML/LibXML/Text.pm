use v6.c;

use nqp;
use NativeCall;

use XML::LibXML::CStructs :types;
use XML::LibXML::Dom;
use XML::LibXML::Enums;
use XML::LibXML::Node;
use XML::LibXML::Subs;

multi trait_mod:<is>(Routine $r, :$aka!) is export { $r.package.^add_method($aka, $r) };

class XML::LibXML::Text is XML::LibXML::Node is repr('CStruct') {
	
	method new($text) {
		sub xmlNewText(Str) returns XML::LibXML::Text is native('xml2') { * };

		xmlNewText($text.Str);
	}

	method data() is aka<getData> {
		self.nodeValue;
	}

}