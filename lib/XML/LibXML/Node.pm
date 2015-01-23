use v6;

use NativeCall;
use XML::LibXML::CStructs :types;
use XML::LibXML::Enums;
use XML::LibXML::Subs;
use XML::LibXML::C14N;

class XML::LibXML::Node is xmlNode is repr('CStruct') does XML::LibXML::C14N;

sub xmlAddChild(xmlNode, xmlNode)  returns XML::LibXML::Node  is native('libxml2') { * }

method at_pos(Int $idx) {
    my $elem = nativecast(XML::LibXML::Node, self.children);
    my $i    = 0;
    while $i++ < $idx {
        $elem = nativecast(XML::LibXML::Node, self.next);
    }
    $elem
}

method elems {
    xmlChildElementCount(self)
}

method base-uri() {
    xmlNodeGetBase(self.doc, self)
}

method type() {
    xmlElementType(nqp::p6box_i(nqp::getattr_i(nqp::decont(self), xmlNode, '$!type')))
}

method name() {
    do given self.type {
        when XML_COMMENT_NODE {
            "#comment";
        }
        when XML_CDATA_SECTION_NODE {
            "#cdata-section";
        }
        when XML_TEXT_NODE {
            "#text";
        }
        when XML_DOCUMENT_NODE|XML_HTML_DOCUMENT_NODE|XML_DOCB_DOCUMENT_NODE {
            "#document";
        }
        when XML_DOCUMENT_FRAG_NODE {
            "#document-fragment";
        }
        default {
            self.ns && self.ns.name
                ?? self.ns.name ~ ':' ~ self.localname
                !! self.localname
        }
    }
}

method Str() {
    my $buffer = xmlBufferCreate(); # XXX free
    my $size   = xmlNodeDump($buffer, self.doc, self, 0, 1);
    $buffer.value;
}

method push($child) {
    xmlAddChild(self, $child)
}

method remove-attr($name, :$ns) {
    #~ $ns ?? xmlUnsetNsProp(self, $ns, $name) !!
    xmlUnsetProp(self, $name)
}

method find($xpath) {
    my $comp = xmlXPathCompile($xpath);
    my $ctxt = xmlXPathNewContext(self.doc);
    my $res  = xmlXPathCompiledEval($comp, $ctxt);
    do given xmlXPathObjectType($res.type) {
        when XPATH_UNDEFINED {
            Nil
        }
        when XPATH_NODESET {
            my $set = $res.nodesetval;
            (^$set.nodeNr).map: {
                nativecast(XML::LibXML::Node, $set.nodeTab[$_])
            }
        }
        when XPATH_BOOLEAN {
            so $res.boolval
        }
        when XPATH_NUMBER {
            $res.floatval
        }
        when XPATH_STRING {
            $res.stringval
        }
        default {
            fail "NodeSet type $_ NYI"
        }
    }
}
