use v6.c;

use NativeCall;

use XML::LibXML::CStructs :types;
use XML::LibXML::Node;

class XML::LibXML::DTD is xmlDtd does XML::LibXML::Nodish {

	method publicId {
		return self.ExternalID;
	}

	method systemId {
		return self.SystemID;
	}
}