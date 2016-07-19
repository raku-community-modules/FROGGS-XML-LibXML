use v6.c;

use nqp;
use NativeCall;

use XML::LibXML::CStructs :types;
use XML::LibXML::Enums;
use XML::LibXML::Node;
use XML::LibXML::Subs;

multi trait_mod:<is>(Routine $r, :$aka!) { $r.package.^add_method($aka, $r) };

my &_nc = &nativecast;

class XML::LibXML::DTD is xmlDtd is repr('CStruct') {
	also does XML::LibXML::Nodish;
	also does xmlNodeCasting;

	method getDtdPtr {
		_nc(xmlDtdPtr, self);
	}

	method getDtd {
		_nc(xmlDtd, self);
	}

	# cw: Due to differences, we override from Nodish.
	method type() {
        xmlElementType(
    		nqp::p6box_i(
    			nqp::getattr_i(nqp::decont(self), xmlDtd, '$!type')
			)
		);
    }

    # cw: The parameter signature is in the test, although it doesn't look 
    #     to do anything.
    method cloneNode($deep = 0) {
    	# cw: Even creating a new object makes things immutable!
    	my $x = XML::LibXML::DTD.new(
    		#:private($.private),
            #:type($.type),
            #:name($.name),
            #:children($.children),
            #:last($.last),
            #:parent($.parent),
            #:next($.next),
            #:prev($.prev),
            #:doc($.doc),
            #:notations($.notations),
            #:elements($.elements),
            #:attributes($.attributes),
            #:entities($.entities),
        	#:ExternalID($.ExternalID),
        	#:SystemID($.SystemID)
        	#:pentities($.pentities)
		);
		setObjAttr($x, '$!private', $.children, :what(xmlDtd));
		#setObjAttr($x, '$!type', $.type, :what(xmlDtd));
		self.getDtd.setType($.type);
		setObjAttr($x, '$!name', $.name, :what(xmlDtd));
		setObjAttr($x, '$!doc', $.doc, :what(xmlDtd));
		setObjAttr($x, '$!children', $.children, :what(xmlDtd));
		setObjAttr($x, '$!last', $.last, :what(xmlDtd));
		setObjAttr($x, '$!parent', $.parent, :what(xmlDtd));
		setObjAttr($x, '$!next', $.next, :what(xmlDtd));
		setObjAttr($x, '$!prev', $.prev, :what(xmlDtd));
		setObjAttr($x, '$!notations', $.notations, :what(xmlDtd));
		setObjAttr($x, '$!elements', $.elements, :what(xmlDtd));
		setObjAttr($x, '$!attributes', $.attributes, :what(xmlDtd));
		setObjAttr($x, '$!entities', $.entities, :what(xmlDtd));
		setObjAttr($x, '$!ExternalID', $.ExternalID, :what(xmlDtd));
		setObjAttr($x, '$!SystemID', $.SystemID, :what(xmlDtd));
		setObjAttr($x, '$!pentities', $.pentities, :what(xmlDtd));

		self.cloneCommon($x);
		$x;
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