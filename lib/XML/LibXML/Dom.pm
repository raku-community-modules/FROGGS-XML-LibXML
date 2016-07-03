use v6.c;

use XML::LibXML::CStructs :types;

package XML::LibXML::Dom {

    use NativeCall;

    use XML::LibXML::Enums;
    use XML::LibXML::Subs;

    # cw: Save some typing.
    my &_nc = &nativecast;

    #sub _domAddNsChain(xmlNsPtr $c, xmlNsPtr $ns) {
    sub _domAddNsChain($c, $ns) {
        return $ns unless !$c.defined;

        my $i = $c;
        while $i.defined && $i !=:= $ns {
            $i = _nc(xmlNs, $i).next;
            unless $i.defined {
                _nc(xmlNs, $ns).next = $c;
                return $ns;
            }
        }

        return $c;
    }

    #sub _domReconcileNsAttr(xmlAttrPtr $a, xmlNsPtr $unused) {
    sub _domReconcileNsAttr($a, $unused) {
        return unless $a.defined;

        my $attr = _nc(xmlAttr, $a);

        my xmlNodePtr $tree = $attr.parent;
        my xmlNode $tree_o = _nc(xmlNode, $tree);

        return unless $tree.defined;

        if $attr.ns.defined {
            my xmlNsPtr $ns;

            if $attr.ns.name.defined && $attr.ns.name eq 'xml' {
                $ns = xmlSearchNsByHref($tree.doc, $tree, XML_XML_NAMESPACE);
                $attr.setNs($ns);
                return
            } 
            else {
                $ns = xmlSearchNs($tree_o.doc, $tree_o.parent, $attr.ns.name);
            }

            my $nso = _nc(xmlNs, $ns);
            if [&&](
                $ns.defined,
                $nso.uri.defined,
                $attr.ns.uri.defined,
                $nso.uri eq $attr.ns.uri
            ) {
                if domRemoveNsDef($tree, $attr.ns) {
                    $unused = _domAddNsChain($unused, $attr.ns);
                    $attr.setNs($ns);
                }
            } 
            else {
                if domRemoveNsDef($tree, $attr.ns) {
                    domAddNsDef($tree, $attr.ns);
                } 
                else {
                    $attr.setNs(xmlCopyNamespace($attr.ns));
                    domAddNsDef($tree, $attr.ns) if $attr.ns.defined;
                }
            }
        }
    }

    #sub _domReconcileNs(xmlNode $tree, xmlNs $unused) {
    sub _domReconcileNs($tree, $unused is rw) {
        sub xmlCopyNamespace(xmlNs) returns xmlNs is native('xml2') { * }

        if  $tree.ns.defined   
            && ($tree.type == XML_ELEMENT_NODE || 
                $tree.type == XML_ATTRIBUTE_NODE) {
            my $ns = xmlSearchNs($tree.doc, $tree.parent, $tree.ns.uri);
            if [&&](
                $ns.defined,
                $ns.href.defined,
                $tree.ns.href.defined,
                $ns.href eq $tree.ns.href
            ) {
                $unused = _domAddNsChain($unused, $tree.ns)
                    if domRemoveNsDef($tree, $tree.ns);
                $tree.ns = $ns;
            } 
            else {
                # cw: -YYY- There WAS an endless loop here...          
                if domRemoveNsDef($tree, $tree.ns) {
                    domAddNsDef($tree, $tree.ns);
               } else {
                    setObjAttr($tree, '$!ns', xmlCopyNamespace($tree.ns));
                    domAddNsDef($tree, $tree.ns);
                }
            }
        }

        if $tree.type == XML_ELEMENT_NODE {
            my xmlElement $ele = _nc(xmlElement, $tree);

            my xmlAttrPtr $a_p = $ele.attributes;
            while $a_p.defined {
                _domReconcileNsAttr($a_p, $unused);
                $a_p = _nc(xmlAttr, $a_p).next;
            }
        }

        my $c_p = $tree.children;
        while $c_p.defined {
            my $cp_o = _nc(xmlNode, $c_p);
            _domReconcileNs($cp_o, $unused);
            $c_p = $cp_o.next;
        }
    }

    #sub domReconcileNs(xmlNode $tree) is export {
    sub domReconcileNs($tree) is export {
        sub xmlFreeNsList(xmlNsPtr) is native('xml2') { * };

        my xmlNsPtr $unused;
        _domReconcileNs($tree, $unused);
        xmlFreeNsList($unused) if $unused.defined;
    }

    # cw: This implementation is shit. For one thing we really need to move
    #     away from "pointer..think"
    sub domAddNsDef($t, $ns) {
        my xmlNs $i = $t.nsDef;

        $i = $i.next while $i.defined && $i !=:= $ns;

        unless $i.defined {
            setObjAttr($ns, '$!next', $t.nsDef);
            setObjAttr($t, '$!nsDef', $ns);
        }
    }

    #sub domImportNode(xmlDoc $d, xmlNode $n, $move, $reconcileNS) is export {
    sub domImportNode($d, $n, $move, $reconcileNS) is export {
        sub xmlCopyDtd(Pointer) returns Pointer is native('xml2') { * }
        sub xmlDocCopyNode(xmlNode, xmlDoc, int32) returns xmlNode is native('xml2') { * }

        my xmlNode $return_node = $n;

        if $move {
            $return_node = $n;
            domUnlinkNode(_nc(xmlNodePtr, $n));
        } 
        else {
            if ($n.type == XML_DTD_NODE) {
                # cw: Pointer should be xmlDtd, but that hasn't been defined, yet.
                $return_node = _nc(
                    xmlNode, xmlCopyDtd(_nc(Pointer, $n));
                );
            } 
            else {
                $return_node = xmlDocCopyNode($n, $d, 1);
            }
        }

        if $n.defined && $n.doc !=:= $d {
            # cw: There is XS memory management code at this point that 
            #     I'm hoping we can ignore:
            # cw: The call below references the $!private attribute which
            #     the P5 XS code used to keep track of its XS proxy node
            #     status. Due to NativeCall, much of what the proxy code
            #     did is now handled internally by Rakudo. 
            #     Specifically, this means reference counting.
            # cw: TODO - Add code to handle proper object resource release
            #     at GC time.
            #if (PmmIsPSVITainted(node->doc))
            #    PmmInvalidatePSVI(doc);
            xmlSetTreeDoc($return_node, $d);
        }

        if 
            $reconcileNS.defined      && 
            $d.defined                && 
            $return_node.defined      &&
            $return_node.type != XML_ENTITY_REF_NODE
        {
            # cw: -YYY- There WAS an endless loop issue here.
            domReconcileNs($return_node);
        }
    }

    #sub domGetAttrNode(xmlNode $n, Str $a) is export {
    sub domGetAttrNode($n, $a) is export {
        my $name = $a.defined ?? $a.trim !! Nil;
        return unless $name;

        my $ret = nativecast(
            xmlAttr, xmlHasNsProp($n, $a, Str)
        );
        unless $ret.defined {
            my ($prefix, $localname) = $a.split(':');
            unless $localname.defined {
                $localname = $prefix;
                $prefix = Str;
            }

            if $localname.defined {
                my $ns = xmlSearchNs($n.doc, $n, $prefix);
                if $ns.defined {
                    $ret = nativecast(
                        xmlAttr, xmlHasNsProp($n, $localname, $ns.uri)
                    );
                }
            }
        }

        return ($ret.defined && $ret.type == XML_ATTRIBUTE_NODE) ?? 
                $ret !! Nil;
    }

    # cw: Type check sends rakudo into an endless loop!
    #
    #sub domRemoveNsDef(xmlNodePtr $tree, xmlNsPtr $ns) {
    sub domRemoveNsDef($_tree, $_ns) {
        my $tree = $_tree ~~ xmlNodePtr ??
            _nc(xmlNode, $_tree) !! $_tree;
        my $ns = $_ns ~~ xmlNsPtr ??
            _nc(xmlNs, $_ns) !! $_ns;

        my xmlNs $i = $tree.nsDef;

        if ($ns =:= $tree.nsDef) {
            $tree.setNsDef($tree.nsDef.next);
            $ns.next = xmlNs;
            return 1;
        }

        while $i.defined {
            if $i.next =:= $ns {
                $i.next = _nc(xmlNodePtr, $ns.next);
                $ns.next = xmlNsPtr;
                return 1;
            }
            $i = $i.next;
        }

        return 0;
    }

    #sub domUnlinkNode(xmlNodePtr $n) is export {
    sub domUnlinkNode($n) is export {
        my $node = _nc(xmlNode, $n);

        return if 
            !$n.defined || !($node.prev.defined || $node.parent.defined);
        
        if $node.type == XML_DTD_NODE {
            xmlUnlinkNode($node);
            return;
        }

        setObjAttr(_nc(xmlNode, $node.prev), '$!next', $node.next)
            if $node.prev.defined;

        setObjAttr(_nc(xmlNode, $node.next), '$!prev', $node.prev) 
            if $node.next.defined;

        if ($node.parent.defined) {
            setObjAttr(_nc(xmlNode, $node.parent), '$!last', $node.prev)
                if $node =:= _nc(xmlNode, $node.parent).last;

            setObjAttr(_nc(xmlNode, $node.parent), '$!children', $node.next)
                if $node =:= _nc(xmlNode, $node.parent).children;
        }

        setObjAttr($node,   '$!prev', xmlNodePtr);
        setObjAttr($node,   '$!next', xmlNodePtr);
        setObjAttr($node, '$!parent', xmlNodePtr);
    }

    sub testNodeName(Str $n) is export {
        # cw: Lifted from 
        #     http://stackoverflow.com/questions/3158274/what-would-be-a-regex-for-valid-xml-names
        grammar validator {
            token TOP {
                <namestartchar> <namechar>*
            }

            token namestartchar {
                ':' | '_' | <[a..zA..Z]> | <[\x00C0 .. \x00D6]> |
                <[\x00D8..\x00F6]> | <[\x00F8..\x02FF]> | <[\x0370..\x037D]> |
                <[\x037F..\x1FFF]> | <[\x200C..\x200D]> | <[\x2070..\x218F]> |
                <[\x2C00..\x2FEF]> | <[\x3001..\xD7FF]> | <[\xF900..\xFDCF]> |
                <[\xFDF0..\xFFFD]> | <[\x10000..\xEFFFF]>
            }

            token namechar {
                <namestartchar>    | '-' | '.' | <:digit> | \x00B7 |
                <[\x0300..\x036F]> | <[\x203F..\x2040]>
            }
        }

        validator.parse($n).defined;
    }

    sub domSetNodeValue(xmlNode $n, $_val) is export {
        sub xmlNodeSetContent(xmlNode, Str) is native('xml2') { * }
        sub xmlNewText(Str) returns xmlNode is native('xml2') { * }

        return unless $n.defined;

        my $val = $_val.Str || '';
        given $n.type {
            when XML_ATTRIBUTE_NODE {
                if $n.children.defined {
                    $n.last = xmlNodePtr;
                    xmlFreeNodeList($n.children);
                }
            
                $n.children = xmlNewText($val);
                $n.last = $n.children;

                my $child = _nc(xmlNode, $n.children);
                $child.parent = _nc(xmlNodePtr, $n);
                $child.doc = $n.doc;
            }

            default {
                xmlNodeSetContent($n, $val);
            }
        }
    }

    sub domGetNodeValue($n) is export {
        sub xmlBufferFree(xmlBuffer)                      is native('xml2') { * }
        sub xmlXPathCastNodeToString(xmlNode) returns Str is native('xml2') { * }

        return unless $n.defined;

        my $retVal;
        return unless $n.type == any(
            XML_ATTRIBUTE_NODE,
            XML_ENTITY_DECL,
            XML_TEXT_NODE,      
            XML_COMMENT_NODE,
            XML_CDATA_SECTION_NODE,
            XML_PI_NODE,
            XML_ENTITY_REF_NODE,
        );

        if $n.type != XML_ENTITY_DECL {
            $retVal = xmlXPathCastNodeToString($n);
        }
        else {
            if $n.value.defined {
                $retVal = $n.value;
            }
            else {
                if $n.children.defined {
                    my $cnode = $n.children;
                    my $c_o = _nc(xmlNode, $cnode);

                    while $cnode.defined {
                        my $buffer = xmlBufferCreate();

                        xmlNodeDump($buffer, $n.doc, $c_o, 0, 0);
                        if $buffer.value.defined {
                            $retVal = $retVal.defined ??
                                $retVal ~ $buffer.value !! $buffer.value;
                        }
                        xmlBufferFree($buffer);
                        $cnode = $c_o.next;
                    }
                }
            }
        }

        $retVal;
    }

    sub domReadWellBalancedString(xmlDoc $doc, $xml, $repair) is export {
        sub xmlParseBalancedChunkMemory(
            xmlDoc, Pointer, Pointer, int32, Str, xmlNode
        ) returns int32 is native('xml2') { * };
        sub xmlSetListDoc(xmlNode, xmlDoc) is native('xml2') { * };

        return unless $xml.defined && $xml.trim.chars;

        my $nodes = xmlNode.new;
        my $ret = xmlParseBalancedChunkMemory(
            $doc, Pointer, Pointer, 0, $xml, $nodes
        );
        if ($ret != 0 && !$repair) {
            xmlFreeNodeList($nodes);
            $nodes = Nil;
        }
        else {
            xmlSetListDoc($nodes, $doc);
        }
        $nodes;
    }

    sub domNewDocFragment($_parent?) is export {
        sub xmlNewDocFragment(xmlDoc) returns xmlNode is native('xml2') { * };

        my $parent = $_parent.defined ?? $_parent !! xmlDoc;
        my $node = xmlNewDocFragment($parent);
        setObjAttr($node, '$!doc', $parent) if $parent.defined;
        $node;
    }

    sub domReparentRemovedNode($node) is export {
        xmlAddChild(
            _nc(xmlNodePtr, domNewDocFragment($node.doc)), 
            _nc(xmlNodePtr, $node)
        ) if $node.type != any(XML_ATTRIBUTE_NODE, XML_DTD_NODE);
    }

}