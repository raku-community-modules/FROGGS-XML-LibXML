use v6;
use nqp;
use NativeCall;
use XML::LibXML::CStructs :types;
use XML::LibXML::Enums;
use XML::LibXML::Subs;
use XML::LibXML::C14N;
use XML::LibXML::Attr;

class XML::LibXML::Node is xmlNode is repr('CStruct') { ... }

role XML::LibXML::Nodish does XML::LibXML::C14N {

    method childNodes() is aka<list> {
        my $elem = nativecast(XML::LibXML::Node, self.children);
        my @ret;
        while $elem {
            push @ret, $elem; # unless $elem.type == XML_ATTRIBUTE_NODE;
            $elem = nativecast(XML::LibXML::Node, $elem.next);
        }
        @ret
    }

    method AT-POS(Int $idx) {
        my $elem = nativecast(XML::LibXML::Node, self.children);
        my $i    = 0;
        while $elem && $i++ < $idx {
            $elem = nativecast(XML::LibXML::Node, $elem.next);
        }
        $elem
    }

    #~ method base-uri() {
        #~ xmlNodeGetBase(self.doc, self)
    #~ }

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

    method attrs() {
        my $elem = nativecast(XML::LibXML::Attr, self.properties);
        my @ret;
        while $elem {
            push @ret, $elem;
            $elem = nativecast(XML::LibXML::Attr, $elem.next);
        }
        @ret
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
                (^$set.nodeNr).map({
                    nativecast(XML::LibXML::Node, $set.nodeTab[$_])
                }).cache
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
}

class XML::LibXML::Node does XML::LibXML::Nodish {

    multi method elems() {
        sub xmlChildElementCount(xmlNode)          returns ulong      is native('xml2') { * }
        xmlChildElementCount(self)
    }

    method push($child) is aka<appendChild> {
        sub xmlAddChild(xmlNode, xmlNode)  returns XML::LibXML::Node  is native('xml2') { * }
        xmlAddChild(self, $child)
    }

    multi method Str(:$level = 0, :$format = 1) {
        my $buffer = xmlBufferCreate(); # XXX free
        my $size   = xmlNodeDump($buffer, self.doc, self, $level, $format);
        $buffer.value;
    }
    
    #~ multi method Str() {
        #~ my $result = CArray[Str].new();
        #~ my $len    = CArray[int32].new();
        #~ $result[0] = "";
        #~ $len[0]    = 0;
        #~ xmlDocDumpMemory(self, $result, $len);
        #~ $result[0]
    #~ }

    #~ multi method Str(:$skip-xml-declaration!) {
        #self.list.grep({ !xmlIsBlankNode($_) })».Str.join
        #~ self.elems
            #~ ?? self.list.grep({ $_.type != XML_DTD_NODE && !xmlIsBlankNode($_) })».Str(:$skip-xml-declaration).join: ''
            #~ !! self.Str(:!format)
    #~ }

}
