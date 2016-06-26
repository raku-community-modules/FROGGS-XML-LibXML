use v6.c;

use XML::LibXML::CStructs :types;

unit class XML::LibXML::Element is xmlElement is repr('CStruct');

use nqp;
use NativeCall;

use XML::LibXML::CStructs :types;
use XML::LibXML::Enums;
use XML::LibXML::Node;
use XML::LibXML::Parser;
use XML::LibXML::Subs;

also does XML::LibXML::Nodish;

multi trait_mod:<is>(Routine $r, :$aka!) is export { $r.package.^add_method($aka, $r) };

method new($name) {
	sub xmlNewNode(xmlNs, Str) is native('xml2') returns XML::LibXML::Element { * };

	xmlNewNode(xmlNs, $name);
}

method type() {
	xmlElementType(
    	nqp::p6box_i(nqp::getattr_i(nqp::decont(self), xmlElement, '$!type'))
	);
}

method getChildrenByTagNameNS($_nsUri, $_name) is aka<getElementsByTagNameNS> {
	my ($ns_wildcard, $name_wildcard);

	$ns_wildcard = True if $_nsUri.defined && $_nsUri eq '*';
	$name_wildcard = True if $_name eq '*';

	my @ret;
	if self.type != XML_ATTRIBUTE_NODE {
		my $c = self.children;

		while ($c.defined) {
			next if $c ~~ xmlAttr;

			my $c_o = nativecast(xmlNode, $c);
			if 	($name_wildcard || $_name eq $c_o.localname) &&
				($ns_wildcard || 
					($c_o.ns.defined && 
						$c_o.ns.uri.defined && 
						$_nsUri eq $c_o.ns.uri
					) ||
					(!$c_o.ns.defined && !$_nsUri.defined)
				)
			{
				@ret.push: nativecast(XML::LibXML::Element, $c);
			}
			$c = $c_o.next;
		}
	}

	@ret;
}

method getChildrenByTagName($_name)
	is aka<getElementsByTagName>
	is aka<getElementsByLocalName> 
{
	self.getChildrenByTagNameNS(Nil, $_name);
}

method tagName() {
	self.name;
}

method string_value {
	# cw: Must use libxml2 to properly decode entities!

	sub xmlXPathCastNodeToString(xmlNode)   returns Str   is native('xml2') { * }
	sub xmlSubstituteEntitiesDefault(int32) returns int32 is native('xml2') { * }

	my $old = xmlSubstituteEntitiesDefault(0);

	# cw: I've been doing this a lot... however I do worry that not using
	#     xmlFree will have consequences.
	xmlXPathCastNodeToString(self.getNode);
}

method appendText($text) {
	sub xmlNodeAddContent(xmlNode, Str) is native('xml2') { * }
	xmlNodeAddContent(self.getNode(), $text);
}

multi method appendTextChild(Pair $kv) {
	sub xmlNewChild(xmlNode, xmlNs, Str, Str) returns xmlNode is native('xml2') { * };

	my $name = $kv.key.trim;
	return unless $name.chars;

	my $content = $kv.value;
	if $content.defined && $content.chars {
		$content = $content.trim;
		$content = xmlEncodeEntitiesReentrant(self.doc, $content)
			if $content.chars;
	}

	xmlNewChild(self.getNode, xmlNs, $name, $content);
}
multi method appendTextChild(Str $name) {
	self.appendTextChild($name => Str);
}

method appendWellBalancedChunk($chunk) {
	my $parser = XML::LibXML::Parser.new;
	my $frag = $parser.parse-xml-chunk($chunk);
	self.appendChild($frag);
}
