class XML::LibXML::Node is repr('CStruct') does XML::LibXML::C14N {
    has OpaquePointer $._private; # application data
    has int8              $.type; # (xmlElementType) type number, must be second !
    has Str          $.localname; # name/filename/URI of the document
    has xmlNodePtr    $.children; # parent->childs link
    has xmlNodePtr        $.last; # last child link
    has xmlNodePtr      $.parent; # child->parent link
    has xmlNodePtr        $.next; # next sibling link
    has xmlNodePtr        $.prev; # previous sibling link
    has XML::LibXML::Document             $.doc; # autoreference to itself End of common p
    has xmlNs               $.ns; # pointer to the associated namespace
    has Str              $.value; # the content
    has xmlAttr     $.properties; # properties list
    has xmlNs            $.nsDef; # namespace definitions on this node
    #~ has OpaquePointer $.psvi	: for type/PSVI informations
    #~ unsigned short	line	: line number
    #~ unsigned short	extra	: extra data for XPath/XSLT

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
        xmlElementType(nqp::p6box_i(nqp::getattr_i(nqp::decont(self), XML::LibXML::Node, '$!type')))
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
}
