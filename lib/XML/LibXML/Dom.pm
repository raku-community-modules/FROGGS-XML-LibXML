use v6;
use v6;

use XML::LibXML::CStructs :types;

class XML::LibXML::xmlNs is xmlNs {

	method setNext(xmlNsPtr $n) {
		$.next = $n;
	}

	method setNsDef(xmlNsPtr $ns) {
		$.nsDef = $ns;
	}

}

package XML::LibXML::Dom {

	use NativeCall;

	use XML::LibXML::Enums;
	use XML::LibXML::Subs;

	sub _domAddNsChain(xmlNsPtr $c, xmlNsPtr $ns) {
		return $ns unless $c =:= xmlNsPtr;

		my $i = $c;
		while ($i !=:= xmlNsPtr && $i !=:= $ns) {
			$i = nativecast(xmlNs, $i).next;
			if ($i =:= xmlNsPtr) {
				nativecast(XML::LibXML::xmlNs, $ns).setNext($c);
				return $ns;
			}
		}

		return $c;
	}

	sub _domReconcileNsAttr(xmlAttrPtr $a, xmlNsPtr $unused) {
		my $attr = nativecast(XML::LibXML::xmlAttr, $a);
		my xmlNodePtr $tree = $attr.parent;
		my xmlNode $tree_o = nativecast(XML::LibXML::xmlNode, $tree);

		return if $tree =:= xmlNodePtr;

		if ($attr.ns !=:= xmlNsPtr) {
			my xmlNsPtr $ns;

			if ($attr.ns.name.defined && $attr.ns.name eq "xml") {
				$ns = xmlSearchNsByHref($tree.doc, $tree, XML_XML_NAMESPACE);
				$attr.setNs($ns);
				return
			} else {
				$ns = xmlSearchNs($tree_o.doc, $tree_o.parent, $attr.ns.name);
			}

			my $nso = nativecast(XML::LibXML::xmlNs, $ns);
			if [&&](
				$ns !=:= xmlNsPtr,
				$nso.uri.defined,
				$attr.ns.uri.defined,
				$nso.uri eq $attr.ns.uri
			) {
				if domRemoveNsDef($tree, $attr.ns) {
					$unused = _domAddNsChain($unused, $attr.ns);
					$attr.setNs($ns);
				}
			} else {
				if domRemoveNsDef($tree, $attr.ns) {
					domAddNsDef($tree, $attr.ns);
				} else {
					$attr.setNs(xmlCopyNamespace($attr.ns));
					domAddNsDef($tree, $attr.ns) if $attr.ns.defined;
				}
			}
		}
	}

	sub _domReconcileNs(xmlNode $tree, xmlNs $unused) {
		sub xmlCopyNamespace(xmlNs) returns xmlNs is native('xml2') { * }

	    if  $tree.ns !~~ Nil     &&
	        ($tree.type == XML_ELEMENT_NODE || $tree.type == XML_ATTRIBUTE_NODE)
	    {
	        my $ns = xmlSearchNs($tree.doc, $tree.parent, $tree.ns.prefix);
	        if  $ns.defined           && 
	            $ns.href.defined      && 
	            $tree.ns.href.defined &&
	            $ns.href eq $tree.ns.href
	        {
	            $unused = _domAddNsChain($unused, $tree.ns)
	                if domRemoveNsDef($tree, $tree.ns);
	            $tree.ns = $ns;
	        } else {
	            if domRemoveNsDef($tree, $tree.ns) {
	                domAddNsDef($tree, $tree.ns);
	            } else {
	                $tree.ns = xmlCopyNamespace($tree.ns);
	                domAddNsDef($tree, $tree.ns);
	            }
	        }
	    }

	    if ($tree.type == XML_ELEMENT_NODE) {
	        my xmlElement $ele = nativecast(xmlElement, $tree);

	        my xmlAttr $attr= nativecast(xmlAttr, $ele.attributes);
	        while ($attr !=:= xmlAttr) {
	            _domReconcileNsAttr(
	            	nativecast(xmlAttrPtr, $attr), $unused
            	);
	            $attr = $attr.next;
	        }
	    }

	    my xmlNode $child = $tree.children;
	    while ($child !=:= xmlNode) {
	        _domReconcileNs($child, $unused);
	        $child = $child.next;
	    }
	}

	sub domReconcileNs(xmlNode $tree) is export {
		sub xmlFreeNsList(xmlNs) is native('xml2') { * };

	    my $unused;
	    _domReconcileNs($tree, $unused);
	    xmlFreeNsList($unused) if $unused.defined;
	}

	sub domAddNsDef(xmlNodePtr $t, xmlNsPtr $ns) {
		my $i = nativecast(xmlNode, $t).nsDef;

		$i = nativecast(xmlNode, $i).next
			while $i !=:= xmlNodePtr && $i !=:= $ns;
		if ($i =:= xmlNodePtr) {
			nativecast(
				XML::LibXML::xmlNs, $ns
			).setNext(
				nativecast(xmlNode, $t).nsDef
			);
			nativecast(xmlNs, $t).setnsDef($ns);
		}
	}

	sub domImportNode(xmlDoc $d, xmlNode $n, $move, $reconcileNS) is export {
		sub xmlCopyDtd(Pointer) returns Pointer is native('xml2') { * }
		sub xmlDocCopyNode(xmlNode, xmlDoc, int32) returns xmlNode is native('xml2') { * }

	    my xmlNode $return_node = $n;

	    if $move {
	        $return_node = $n;
	        domUnlinkNode(nativecast(xmlNodePtr, $n));
	    } else {
	        if ($n.type == XML_DTD_NODE) {
	        	# cw: Pointer should be xmlDtd, but that hasn't been defined, yet.
	            $return_node = nativecast(
	            	xmlNode, xmlCopyDtd(nativecast(Pointer, $n));
	    		);
	        } else {
	            $return_node = xmlDocCopyNode($n, $d, 1);
	        }
	    }

	    if ($n.doc =:= $d) {
	        # cw: There is XS memory management code at this point that 
	        #     I'm hoping we can ignore:
	        #if (PmmIsPSVITainted(node->doc))
	        #    PmmInvalidatePSVI(doc);
	        xmlSetTreeDoc($return_node, $d);
	    }

	    if  (
	    	$reconcileNS.defined    && 
	        $d.defined              && 
	        $return_node.defined    &&
	        $return_node.type != XML_ENTITY_REF_NODE
	    ) {
	        domReconcileNs($return_node);
	    }
	}

	sub domGetAttrNode(xmlNode $n, Str $a) is export {
	    my $name = $a.subst(/\s/, '');
	    return unless $name;

	    my $ret;
	    unless $ret := nativecast(
	        xmlAttr, xmlHasNsProp($n, $a, Str)
	    ) {
	        my ($prefix, $localname) = $a.split(':');

	        if !$localname {
	            $localname = $prefix;
	            $prefix = Nil;
	        }
	        if $localname {
	            my $ns = xmlSearchNs($n.doc, $n, $prefix);
	            if $ns {
	                $ret := nativecast(
	                    xmlAttr, xmlHasNsProp($n, $localname, $ns.uri)
	                );
	            }
	        }
	    }

	    return if $ret && $ret.type != XML_ATTRIBUTE_NODE;
	    return $ret;
	}

	sub domRemoveNsDef(xmlNodePtr $tree, xmlNsPtr $ns) {
		my $tree_o = nativecast(XML::LibXML::Node, $tree);
		my $ns_o = nativecast(XML::LibXML::xmlNs, $ns);
		my xmlNsPtr $i = $tree_o.nsDef;

		if ($ns =:= $tree_o.nsDef) {
			$tree_o.setNsDef($tree_o.nsDef.next);
			$ns.setNext(xmlNsPtr);
			return 1;
		}

		while $i !=:= xmlNsPtr {
			my $i_o = nativecast(XML::LibXML::xmlNs, $i);
			if $i_o.next =:= $ns {
				$i_o.setNext($ns_o.next);
				$ns_o.setNext(xmlNsPtr);
				return 1;
			}
			$i = $i_o.next;
		}

		return 0;
	}

	sub domUnlinkNode(xmlNodePtr $n) {
		my $node = nativecast(XML::LibXML::xmlNode, $n);

		return if 
			$n =:= xmlNodePtr || [&&](
				$node.prev   =:= xmlNodePtr &&
				$node.parent =:= xmlNodePtr
			);
		
		if ($node.type = XML_DTD_NODE) {
			xmlUnlinkNode($node);
			return;
		}

		$node.prev.setNext($node.next) if $node.prev !=:= xmlNodePtr;
		$node.next.setPrev($node.prev) if $node.next !=:= xmlNodePtr;

		if ($node.parent !=:= xmlNodePtr) {
			$node.parent.setLast($node.prev) 
				if $node.parent.last =:= $node.prev;

			$node.parent.setChildren($node.next)
				if $node.parent.children =:= $node.next;
		}

		$node.setPrev(xmlNodePtr);
		$node.setNext(xmlNodePtr);
		$node.setParent(xmlNodePtr);
	}

}