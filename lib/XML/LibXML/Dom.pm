use v6.c

unit package XML::LibXML::Dom;

class XML::LibXML::Node is xmlNode is repr('CStruct') { ... }

sub !_domReconsileNs(xmlNode $tree, xmlNs $unused) {
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

    if $tree.type == XML_ELEMENT_NODE {
        xmlElement $ele = nativecast(xmlElement, $tree);

        xmlAttr $attr= nativecast(xmlAttr, $ele.attributes);
        while ($attr !=:= xmlAttr) {
            _domReconcileNsAttr($attr, $unused);
            $attr = $attr.next;
        }
    }

    xmlNode $child = $tree.children;
    while ($child !=:= xmlNode) {
        _domReconsileNs($child, $unused);
        $child = $child.next;
    }
}

sub domReconcileNs(xmlNode $tree) is export {
    my $unused;
    _domReconsileNs($tree, $unused);
    xmlFreeNsList($unused) if $unused.defined;
}

sub domImportNode(xmlDoc $d, xmlNode $n, $move, $reconcileNS) is export {
    my xmlNode $return_node = $n;

    if $move {
        $return_node = $n;
        domUnlinkNode($n);
    } else {
        if node.type == XML_DTD_NODE {
            return_node = xmlCopyDtd(nativecast(xmlDtd, $n));
        } else {
            return_node = xmlDocCopyNode($n, $d, 1);
        }
    }

    if ($n.doc =:= $d) {
        # cw: There is XS memory management code at this point that 
        #     I'm hoping we can ignore:
        #if (PmmIsPSVITainted(node->doc))
        #    PmmInvalidatePSVI(doc);
        xmlSetTreeDoc($return_node, $d);
    }

    if  $reconsileNS.defined    && 
        $d.defined              && 
        $return_node.defined    &&
        $return_node.type != XML_ENTITTY_REF_NODE
    {
        domReconcileNs($return_node);
    }
}

sub domGetAttrNode(XML::LibXML::Node $n, Str $a) is export {
    my $name = $a.subst(/\s/, '');
    return unless $name;

    my $ret;
    unless $ret := nativecast(
        XML::LibXML::Attr, xmlHasNsProp($n, $a, Str)
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
                    XML::LibXML::Attr, xmlHasNsProp($n, $localname, $ns.href)
                );
            }
        }
    }

    return if $ret && $ret.type != XML_ATTRIBUTE_NODE;

    return $ret;
}