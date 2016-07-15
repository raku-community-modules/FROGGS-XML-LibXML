use v6.c;

use nqp;
use NativeCall;

use XML::LibXML::CStructs :types;
use XML::LibXML::Enums;
use XML::LibXML::Node;

multi trait_mod:<is>(Routine $r, :$aka!) { $r.package.^add_method($aka, $r) };

class XML::LibXML::DTD is xmlDtd is repr('CStruct') {
	also does XML::LibXML::Nodish;
	also does xmlNodeCasting;

	# cw: Due to differences, we override from Nodish.
	method type() {
        xmlElementType(
    		nqp::p6box_i(
    			nqp::getattr_i(nqp::decont(self), xmlDtd, '$!type')
			)
		);
    }

    # cw: Due to differences, we override from Nodish.
    method getName is aka<nodeName> {
    	self.name;
    }

	method publicId is aka<getPublicId> {
		self.ExternalID;
	}

	method systemId is aka<getSystemId> {
		self.SystemID;
	}

}