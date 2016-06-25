use v6.c;
use nqp;
use XML::LibXML::CStructs :types;

unit class XML::LibXML::XPathContext is xmlXPathContext is repr('CStruct');
	
method setNode($node) {
	nqp::bindattr(nqp::decont(self), xmlXPathContext, '$!node', nqp::decont($node));
}