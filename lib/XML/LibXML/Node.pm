use v6;

use XML::LibXML::CStructs :types;
use XML::LibXML::Enums;

class XML::LibXML::Node is xmlNode is repr('CStruct');

use NativeCall;

sub xmlNodeGetBase(xmlNode, xmlNode)                                                  returns Str                  is native('libxml2') { * }
sub xmlBufferCreate()                                                                 returns xmlBuffer            is native('libxml2') { * }
sub xmlNodeDump(xmlBuffer, xmlDoc, xmlNode, int32, int32)                             returns int32                is native('libxml2') { * }
sub xmlAddChild(xmlNode, xmlNode)                                                     returns XML::LibXML::Node    is native('libxml2') { * }
sub xmlUnlinkNode(xmlNode)                                                                                         is native('libxml2') { * }
#~ sub xmlUnsetNsProp(xmlNode, xmlNsPtr, Str)                                            returns int32                is native('libxml2') { * }
sub xmlUnsetProp(xmlNode, Str)                                                        returns int32                is native('libxml2') { * }

sub xmlXPathCompile(Str)                                                              returns xmlXPathCompExprPtr  is native('libxml2') { * }
sub xmlXPathNewContext(xmlDoc)                                                        returns xmlXPathContext      is native('libxml2') { * }
sub xmlXPathCompiledEval(xmlXPathCompExprPtr, xmlXPathContextPtr)                     returns xmlXPathObject       is native('libxml2') { * }
sub xmlC14NDocDumpMemory(xmlDoc, xmlNodeSet, int32, CArray[Str], int32, CArray[Str])  returns int32                is native('libxml2') { * }
sub xmlGetNsList(xmlDoc, xmlNode)                                                     returns xmlNs                is native('libxml2') { * }
sub xmlChildElementCount(xmlNode)                                                     returns int                  is native('libxml2') { * }

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

method c14n(Bool :$comments = False, Str :$xpath is copy, xmlC14NMode :$exclusive = XML_C14N_1_1, :@inc-prefixes) {
    fail "Node passed to c14n must be part of a document" unless self.doc;

    if !$xpath && self.type != any XML_DOCUMENT_NODE, XML_HTML_DOCUMENT_NODE, XML_DOCB_DOCUMENT_NODE {
        $xpath = $comments
            ?? '(. | .//node() | .//@* | .//namespace::*)'
            !! '(. | .//node() | .//@* | .//namespace::*)[not(self::comment())]'
    }

    my $nodes = xmlNodeSet;

    if $xpath {
        my $comp      = xmlXPathCompile($xpath);
        my $ctxt      = xmlXPathNewContext(self.doc);
        nqp::bindattr(nqp::decont($ctxt), xmlXPathContext, '$!node', nqp::decont(self));
        my $xpath_res = xmlXPathCompiledEval($comp, $ctxt);
        $nodes        = $xpath_res.nodesetval;
    }

    my CArray[Str] $prefixes.=new;
    my $i = 0;
    $prefixes[$i++] = $_ for @inc-prefixes;
    $prefixes[$i]   = Str;

    my CArray[Str] $result.=new;
    $result[0] = '';

    my $bytes = xmlC14NDocDumpMemory(self.doc, $nodes, +$exclusive, $prefixes, +$comments, $result);
    # XXX fail with a nice message if $bytes < 0
    $result[0]
}

method ec14n(Bool :$comments = False, Str :$xpath, :@inc-prefixes) {
    self.c14n(:$comments, :$xpath, :exclusive(XML_C14N_EXCLUSIVE_1_0), :@inc-prefixes)
}
