use v6.c;

use XML::LibXML::CStructs :types;

package XML::LibXML::Dom {

    use nqp;
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

        # cw: The use of can() here is a HACK. But we have so many
        #     things trying to imitate the xmlNode clas that ARE
        #     NOT, it's warranted. 
        #
        #     In the case of an xmlDtd masquerating as an xmlNode, 
        #     calling .ns, would reallt be a call to .notations!
        #     So wouldn't "$tree.ns.defined" be an orange to 
        #     "$tree_dtd.notations.defined"?
        if  $tree.can('ns') && $tree.ns.defined   
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

        # cw: Yet another place where type checking will cause rakudo to
        #     run endlessly.
        #my xmlNode $return_node = $n ~~ xmlNodePtr ?? 
        my $return_node = $n ~~ xmlNodePtr ?? 
            $n.getNode !! $n;

        if $move {
            domUnlinkNode($n);            
        } 
        else {
            if ($n.type == XML_DTD_NODE) {
                # cw: Pointer should be xmlDtd, but that hasn't been defined, yet.
                $return_node = _nc(
                    xmlNode, xmlCopyDtd($n.getNodePtr);
                );
            } 
            else {
                $return_node = xmlDocCopyNode($n, $d, 1);
            }
        }

        if  $n.defined && 
            $d.defined && 
            +$d.getNodePtr == +$n.getNode.doc.getNodePtr
        {
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
        $return_node;
    }

    #sub domGetAttrNode(xmlNode $n, Str $a) is export {
    sub domGetAttrNode($n, $a) is export {
        my $name = $a.defined ?? $a.trim !! Nil;
        return unless $name.chars && $n.defined;

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

        ($ret.defined && $ret.type == XML_ATTRIBUTE_NODE) ?? 
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
                #$i.next = _nc(xmlNodePtr, $ns.next);
                $i.next = $ns.next;
                $ns.next = xmlNs;
                return 1;
            }
            #$i = _nc(xmlNode, $i.next);
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
            xmlUnlinkNode(
                $node !~~ xmlNodePtr ?? $node.getNodePtr !! $node 
            );
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
                ':' | '_' | <[a..zA..Z]> | <[\x00C0 .. \x00D6]>  |
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

    #sub domAddNodeToList(xmlNode $cur, xmlNode $leader, xmlNode $followup) 
    sub domAddNodeToList($_cur, $_leader, $_followup) is export {
        # cw: In this situation, any one of the parameters might
        #     be either an object, or its associated pointer. 
        #     We need to normalize this so we have a sane initial
        #     condition.
        my $cur = $_cur.getNode;
        my $leader = $_leader.getNode;
        my $followup = $_followup.getNode;

        my ($c1, $c2, $p);

        if $cur.defined {
            $c1 = $c2 = $cur;
        
            if $leader.defined {
                $p = $leader.getNode.parent.getNode;
            }
            elsif $followup.defined {
                $p = $followup.parent.getNode;
            }
            else {
                return 0;
            }

            if $cur.type == XML_DOCUMENT_FRAG_NODE {
                $c1 = $cur.children.getNode;
                while ($c1.defined) {
                    setObjAttr($c1, '$!parent', $p);
                    $c1 = $c1.next.getNode;
                }
                $c1 = $cur.children.getNode;
                $c2 = $cur.last.getNode;
            }
            else {
                setObjAttr($cur, '$!parent', $p.getNodePtr);
            }

            if  $c1.defined     && 
                $leader.defined && 
                +$c1.getNodePtr != +$leader.getNodePtr
            {
                if $leader.defined {
                    setObjAttr($leader, '$!next', $c1.getNodePtr);
                    setObjAttr($c1, '$!prev', $leader.getNodePtr);
                } 
                elsif $p.defined {
                    setObjAttr($p, '$!children', $c1.getNodePtr);
                }

                if $followup.defined {
                    setObjAttr($followup, '$!prev', $c2.getNodePtr);
                    setObjAttr($c2, '$!next', $followup.getNodePtr);
                }
                elsif $p.defined {
                    setObjAttr($p, '$!last', $c2.getNodePtr);
                }
            }
            return 1;
        }
        return 0;
    }

    sub domInsertBefore($node, $new, $ref) is export {
        return $new
            if  $new.defined && $ref.defined &&
                +$new.getNodePtr == +$ref.getNodePtr;
        return unless $node.defined && $new.defined;

        if $ref.defined {
            if !(+$ref.parent == +($node.getNodePtr)) || 
               ($new.type == XML_DOCUMENT_FRAG_NODE &&
                !$new.children.defined)
            {
                #cw: xmlGenericError?
                return;
            }
        }

        domAppendChild($node, $new) if !$node.children.defined;
        if !(
            domTestHierarchy($node, $new) && 
            domTestDocument($node, $new)
        ) {
            warn "insertBefore/insertAfter: Hierarchy request error!";
            return;
        }

        my $mynew = $new;
        if +$node.doc.getNodePtr == +$new.doc.getNodePtr {
            domUnlinkNode($mynew);
        }
        else {
            $mynew = domImportNode($node.doc.getNode, $new, 1, 0);
        }

        my $frag;
        if $new.type == XML_DOCUMENT_FRAG_NODE {
            $frag = $new.children;
        }

        if !$ref.defined {
            domAddNodeToList($new, $node.last, xmlNode);
        }
        else {
            domAddNodeToList($new, $ref.prev, xmlNode);
        }

        if $frag.defined {
            $mynew = $frag;
            while   $frag.defined && 
                    +$frag.getNodePtr != +$ref.getNodePtr
            {
                domReconcileNs($frag);
                $frag = $frag.getNode.next;
            }
        }
        elsif $new.type != XML_ENTITY_REF_NODE {
            domReconcileNs($new);
        }

        $mynew;
    }

    sub domInsertAfter($node, $new, $ref) is export {
        domInsertBefore(
            $node, 
            $new, 
            $ref.defined && $ref.next.defined ??
                $ref.next.getNode !! xmlNode
        );
    }

    sub domTestDocument($cur, $ref) {
        if $cur.type == XML_DOCUMENT_NODE {
            return False if $ref.type == any(
                XML_ATTRIBUTE_NODE,
                XML_ELEMENT_NODE,
                XML_ENTITY_NODE,
                XML_ENTITY_REF_NODE,
                XML_TEXT_NODE,
                XML_CDATA_SECTION_NODE,
                XML_NAMESPACE_DECL
            );
        }
        True;
    }

    sub domTestHierarchy($cur, $ref) {
        return False unless $cur.defined && $ref.defined;

        if ($cur.type == XML_ATTRIBUTE_NODE) {
            return True if $ref.type == any(
                XML_TEXT_NODE,
                XML_ENTITY_REF_NODE
            );
            return False;
        }

        return False if $ref.type == any(
            XML_ATTRIBUTE_NODE;
            XML_DOCUMENT_NODE
        );

        return False if domIsParent($cur, $ref);
        True;
    }

    sub domIsParent($cur, $ref) is export {
        return False unless $cur.defined && $ref.defined;
        return True if +$cur.getNodePtr == +$ref.getNodePtr;

        # cw: When comparing known pointers, this is easier.
        return False if  
            +($cur.doc.getNodePtr) != +($ref.doc.getNodePtr)   ||
            +$cur.parent == +($cur.doc.getNodePtr)             ||
            !$ref.children.defined                             ||
            !$cur.parent.defined;

        return True if $ref.type == XML_DOCUMENT_NODE;

        my $helper = $cur;
        while ( 
            $helper.defined && 
            +$helper.getNodePtr != +$cur.doc.getNodePtr ) 
        {
            return True if +$helper.getNodePtr == +$ref.getNodePtr;
            $helper = $helper.parent.getNode;
        }
        False;
    }

    sub domAppendChild($node, $new) {
        return $new unless $node.defined;
        
        if !(  domTestHierarchy($node, $new) &&
               domTestDocument($node, $new) )
        {
            # cw: Unknown if this is fatal.
            warn "appendChild: HIERARCHY_REQUEST_ERR\n";
            return;
        }

        # cw: Direct comparison of pointers.
        my $mynew = $new;
        if +$new.doc == $node.doc {
            domUnlinkNode($new);
        }
        else {
            warn "WRONG_DOCUMENT_ERR - non conform implementation\n";
            # xmlGenericError(xmlGenericErrorContext,"WRONG_DOCUMENT_ERR\n"); 
            $mynew = domImportNode($node.doc.getNode, $new, 1, 0);
        }

        my $frag;
        if $node.children.defined {
            $frag = $mynew.children
                if $mynew.type == XML_DOCUMENT_FRAG_NODE;
            domAddNodeToList( $mynew, $node.last.getNode, xmlNode );
        }
        elsif $mynew.type == XML_DOCUMENT_FRAG_NODE {
            my $c1;
            setObjAttr($node, '$!children', $mynew.children);
            $c1 = $frag = $mynew.children;

            while ( $c1.defined ) {
                setObjAttr($c1.getNode, '$!parent', $node.getNodePtr);
                $c1 = $c1.getNode.next;
            }
            setObjAttr($node, '$!last', $mynew.last);
            setObjAttr($mynew, '$!last', xmlNodePtr);
            setObjAttr($mynew, '$!children', xmlNodePtr);
        }
        else {
            setObjAttr($node, '$!children', $mynew.getNodePtr);
            setObjAttr($node, '$!last', $mynew.getNodePtr);
            setObjAttr($mynew, '$!parent', $node.getNodePtr);
        }

        if $frag.defined {
            # reconcile nodes in fragment.
            $mynew = $frag;
            while ($frag.defined) {
                domReconcileNs($frag);
                $frag = $frag.next.getNode;
            }
        }
        elsif $mynew.type != XML_ENTITY_REF_NODE {
            domReconcileNs($mynew);
        }

        $mynew;
    }

    # cw: New DOM manipulation subs that really should be somewhere 
    #     else.
    sub DomSetIntSubset($doc, $ref) is export {
        if $ref.defined {
            # cw: Should ALWAYS be xmlDtdPtr;
            my $old_dtd = $doc.intSubset;
            # cw: -YYY- Should really get this straight, in the past, 
            #     op< =:= > did not reliably test equivalence of 
            #     repr('CPointer') objects which is why the strategy 
            #     used in isSameNode() was developed. Howevere that 
            #     stragegy is not working here, for some reason. 
            #
            #     "Invocant requires an instance of type xmlNodePtr, 
            #      but a type object was passed.  Did you forget a .new?
            #      in method Numeric..."
            #
            #     But how am I encoutering a type object when both 
            #     scalars say they are defined?!?
            say "R1 {+$ref.getP}";
            say "R2 {+$old_dtd.getP}" if $old_dtd.defined;
            return if   $ref.defined     && 
                        $old_dtd.defined &&
                        #$ref.getDtdPtr =:= $old_dtd;
                        +$ref.getP == +$old_dtd.getP;
            
            if $old_dtd.defined {
                xmlUnlinkNode($old_dtd.getNodePtr);

                # cw: -XXX- 
                #if (PmmPROXYNODE(old_dtd) == NULL) {
                #    xmlFreeDtd((xmlDtdPtr)old_dtd);
                #}
            }
        }

        say "R {$ref.defined} / {$ref.^name} / {$doc.^name}";
 
        setObjAttr(
            $doc, 
            '$!intSubset', 
            $ref.defined ?? $ref.getDtdPtr !! xmlDtdPtr
        );
        nqp::nativecallrefresh($doc);

        say "MD {$doc.intSubset.defined}";
        say "M {+$doc.intSubset.getP}" if $doc.intSubset.defined;
    }

    sub DomReparentRemovedNode($node) is export {

        say "D {$node.doc.intSubset.defined}";
        say "D {+$node.doc.intSubset.getP}" if $node.doc.intSubset.defined;
        say "N {$node.defined}";
        say "N {+$node.getP}" if $node.defined;

        given $node.type {
            when XML_ATTRIBUTE_NODE {
                # Do nothing
            }

            # cw: Well here is where those proxy nodes would come in handy.
            #     Right now there is no way to tell the owner of the removed
            #     node that one of their children is gone.
            #     
            #     This would force an entire tree search to properly correct
            #     this problem. Or a separate data structure like what was
            #     implemented in the P5 version. Will need to think on this.
            #_domFixOwner($node, $frag);

            # cw: Doesn't really solve the problem but might make it pass
            #     the test. Special case DTD nodes, so we remove the internal
            #     subset from the document.

            when XML_DTD_NODE {
                say "N1 {+$node.doc.intSubset.getP}" 
                    if $node.doc.intSubset.defined;
                say "N2 {+$node.getP}";
                say "N3 {$node.defined}";
                say "N4 {+$node.doc.intSubset.getP == +$node.getP}"
                    if $node.doc.intSubset.defined && $node.defined;

                if  $node.doc.intSubset.defined &&
                    $node.defined               &&
                    +$node.doc.intSubset.getP == +$node.getP 
                {
                    say "Blank!";
                    DomSetIntSubset($node.doc, xmlDtdPtr);
                }
            }

            default {
                my $frag = domNewDocFragment($node.doc);
                xmlAddChild($frag.getNodePtr, $node.getNodePtr);    
            }
        }
    }

    sub domReplaceChild($node, $_new, $old) is export {
        return unless $node.defined;
        return $_new if +$_new.getNodePtr == +$old.getNodePtr;

        my $new = $_new;
        unless $new.defined {
            return domRemoveChild($node, $old);
        }

        unless $old.defined {
            domAppendChild($node, $new);
            return;
        }

        if  !( domTestHierarchy($node, $new) &&
               domTestDocument($node, $new))
        {
            # cw: -YYY- Again, is this fatal?
            warn "replaceChild: HIERARCHY_REQUEST_ERR\n";
            return;
        }

        if +$new.doc.getNodePtr == +$node.doc.getNodePtr {
            domUnlinkNode( $new );
        }
        else {
            # WRONG_DOCUMENT_ERR - non conform implementation 
            $new = domImportNode( $node.doc, $new, 1, 1 );
        }

        my ($frag, $frag_next);
        if +$old.getNodePtr == +$node.children && 
           +$old.getNodePtr == +$node.last 
        {
            domRemoveChild( $node, $old );
            domAppendChild( $node, $new );
        }
        elsif $new.type == XML_DOCUMENT_FRAG_NODE &&
              !$new.children.defined  
        {
            # want to replace with an empty fragment, then remove ... 
            $frag = $new.children;
            $frag_next = $old.next;
            domRemoveChild( $node, $old );
        }
        else {
            domAddNodeToList( $new, $old.prev, $old.next );
    
            # cw: With the introduction of getBase, we should probably
            #     remove the :what named parameter.
            #
            # cw: -XXX- THIS NEEDS TO BE REVISITED!!!
            #     I don't know why the general case in the else clause
            #     doesn't work for xmlNode and ONLY xmlNode. 
            #     This kind of special casing makes my teeth hurt, but
            #     it solves a problem, so I'm leaving it until I can 
            #     circle back.
            if $old.^name eq 'xmlNode' {
                setObjAttr($old, '$!parent', xmlNodePtr);
                setObjAttr($old, '$!next', xmlNodePtr);
                setObjAttr($old, '$!prev', xmlNodePtr);
            }
            else {
                setObjAttr($old, '$!parent', xmlNodePtr, :what($old.getBase));
                setObjAttr($old, '$!next', xmlNodePtr, :what($old.getBase));
                setObjAttr($old, '$!prev', xmlNodePtr, :what($old.getBase));
            }
        }

        if ( $frag.defined ) {
            while ($frag && +$frag != +$frag_next ) {
                domReconcileNs($frag.getNode);
                $frag = $frag.getNode.next;
            }
        } elsif $new.type != XML_ENTITY_REF_NODE {
            domReconcileNs($new);
        }

        $old;
    }

    sub domRemoveChild($node, $old) is export {
        return unless $node.defined && $old.defined;        
        return if $old.type == any(XML_ATTRIBUTE_NODE, XML_NAMESPACE_DECL);
        return if +$node.getP != +$old.parent.getP;

        domUnlinkNode( $old );
        domReconcileNs( $old ) if $old.type == XML_ELEMENT_NODE;
        $old;
    }

}