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

	multi method new($ext, $sys) {
		sub xmlParseDTD(Str, Str) returns xmlDtd is native('xml2') { * }

		my $dtd = xmlParseDTD($ext, $sys);
		die "Can't parse DTD" unless $dtd.defined;

		xmlSetTreeDoc($dtd, xmlDoc);
		$dtd;
	}

	multi method new($dummy = 0) {
		xmlDtd.new;
	}

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
    method cloneNode(XML::LibXML::DTD:D: $deep = 0) {
    	# cw: Even creating a new object makes things immutable!
    	#my $x = XML::LibXML::DTD.new(
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
		#);
		my $x = XML::LibXML::DTD.new;
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

	method parse-string($str, $enc?) is aka<parse_string> {
		sub xmlIOParseDTD(Pointer, xmlParserInputBufferPtr, int32)        returns xmlDtd                  is native('xml2') { * }
		sub xmlAllocParserInputBuffer(int32)                              returns xmlParserInputBufferPtr is native('xml2') { * }
		sub xmlParserInputBufferPush(xmlParserInputBufferPtr, int32, Str) returns int32                   is native('xml2') { * }

		my $myenc = $enc.defined ?? $enc !! Nil;
		my $xml_enc = Str;
		if $myenc.defined {
			$xml_enc = xmlParseCharEncoding($enc);

			die "Could not parse using encoding '{$enc}'";
		}

		my $buffer = xmlAllocParserInputBuffer($xml_enc);
		die "Could not allocate buffer" unless $buffer.defined;

		xmlParserInputBufferPush($buffer, $str.chars, $str);
		my $ret = xmlIOParseDTD(Pointer, $buffer, $xml_enc);
		say "R: {$ret}";
		die "no DTD parsed!" unless $ret.defined && $ret ~~ xmlDtd;

		_nc(XML::LibXML::DTD, $ret);
	}

}