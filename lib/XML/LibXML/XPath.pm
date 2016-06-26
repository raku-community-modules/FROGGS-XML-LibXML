use v6.c;

use nqp;
use NativeCall;

use XML::LibXML::CStructs :types;

unit class XML::LibXML::XPath is xmlXPathContext is repr('CStruct');

use XML::LibXML::Subs;

multi trait_mod:<is>(Routine $r, :$aka!) is export { $r.package.^add_method($aka, $r) };

method new(xmlDoc $doc) {
	sub xmlXPathNewContext(xmlDoc) returns XML::LibXML::XPath is native('xml2') { * }
	xmlXPathNewContext($doc);
}

method setNode($node) {
	nqp::bindattr(nqp::decont(self), xmlXPathContext, '$!node', nqp::decont($node));
}

method register-namespace(Str $ns, Str $uri) is aka<registerNs> {
	sub xmlXPathRegisterNs(xmlXPathContext, Str, Str) 
		returns xmlXPathContext is native('xml2') { * };    
	xmlXPathRegisterNs(self, $ns, $uri);
}

method unregister-namespace(Str $ns) is aka<unregisterNs> {
    self.register-namespace($ns, Str)
}