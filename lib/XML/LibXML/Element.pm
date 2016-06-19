use v6.c;

use XML::LibXML::CStructs :types;

unit class XML::LibXML::Element is xmlElement is repr('CStruct');

use nqp;
use NativeCall;

use XML::LibXML::Enums;
use XML::LibXML::Node;
use XML::LibXML::Subs;

also does XML::LibXML::Nodish;
also does XML::LibXML::Common;

method new($name) {
	sub xmlNewNode(xmlNs, Str) is native('xml2') returns XML::LibXML::Element { * };

	xmlNewNode(xmlNs, $name);
}

method type() {
    xmlElementType(
    	nqp::p6box_i(nqp::getattr_i(nqp::decont(self), xmlElement, '$!type'))
	);
}

method getChildrenByTagNameNS($_nsUri, $_name) {
	my ($ns_wildcard, $name_wildcard);

	$ns_wildcard = True if $_nsUri eq '*';
	$name_wildcard = True if $_name eq '*';

	my @cldList;
	if self.type != XML_ATTRIBUTE_NODE {
		my xmlNodePtr $cld = self.children;

		while ($cld.defined) {
			my $cld_o = nativecast(xmlNode, $cld);

			if 	($name_wildcard || $_name eq $cld_o.name) &&
				($ns_wildcard || 
					($cld_o.ns.defined && $_nsUri eq $cld_o.ns.uri) ||
					(!$cld.ns.defined && !$_nsUri.defined)
				) 
			{
				@cldList.push: nativecast(XML::LibXML::Element, $cld);
			}
			$cld = $cld_o.next;
		}
	}

	@cldList;
}

method getChildrenByTagName($_name) {
	self.getChildrenByTagNameNS(Nil, $_name);
}

method tagName() {
	self.name;
}





