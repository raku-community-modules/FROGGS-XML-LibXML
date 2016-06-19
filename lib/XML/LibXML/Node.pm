use v6;
use nqp;
use NativeCall;
use XML::LibXML::CStructs :types;
use XML::LibXML::Enums;
use XML::LibXML::Subs;
use XML::LibXML::C14N;
use XML::LibXML::Attr;
use XML::LibXML::Dom;
#use XML::LibXML::Pmm;

multi trait_mod:<is>(Routine $r, :$aka!) { $r.package.^add_method($aka, $r) };

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

    method _name() {
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
            #when XML_ELEMENT_NODE {
            #    $!name;
            #}
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

    method isSameNode($n) {
        # cw: Maybe.
        return self =:= $n;
    }
}

role XML::LibXML::Common {
    method !testNodeName(Str $n) {
        return False if ($n ~~ /^<-[ a..z A..Z \_ : ]>/) !~~ Nil;

        # cw: Missing IS_EXTENDER(c)
        return ($n ~~ /<-[ \d a..z A..Z : \- \. ]>/) ~~ Nil;
    }

    method setNodeName(Str $n) {
        sub xmlNodeSetName(xmlNode, Str)       is native('xml2') { * }

        #die "Bad name" if self!testNodeName($n);
        #xmlNodeSetName(self, $n);

        if self!testNodeName($n) {
            xmlNodeSetName(nativecast(xmlNode, self), $n);        
        } else {
            die "Bad name";
        }
    }

    method setAttribute(Str $a, Str $v) {
        sub xmlSetProp(xmlNode, Str, Str)       is native('xml2') { * }

        if self!testNodeName($a) {
            # cw: Note, this method locks us into libxml2 versions of 2.6.21 and 
            #     later. libxml2 does -not- provide us a mechanism to test and 
            #     implement backwards compatibility.
            xmlSetProp(nativecast(xmlNode, self), $a, $v);
        } else {
            die "Bad name '$a'";
        }
    }

    method setAttributeNS(Str $namespace, Str $name, Str  $val) {
        if ! self!testNodeName($name) {
            die "Bad name '$name'";
            # cw: Yes, I know this looks weird, but is done incase we 
            #     .return from a CATCH{}
            return;
        }

        my ($prefix, $localname) = $name.split(':');

        if !$localname {
            $localname = $prefix;
            $prefix := Str;
        }

        # cw: Sublime currently has crappy syntax highlighting so 
        #     $namespace ~~ s:g/// will break it. 
        my xmlNs $ns;

        my $attr_ns;
        if $namespace.defined {
            $attr_ns = $namespace.subst(/\s/, '');
            if $attr_ns.chars {
                $ns = xmlSearchNsByHref(self.doc, self, $attr_ns);

                if $ns.defined && !$ns.uri {
                    my @all_ns := nativecast(
                        CArray[xmlNsPtr],
                        xmlGetNsList(self.doc, self)
                    );

                    if (@all_ns.defined) {
                        my $i = 0;
                        repeat {
                            my $nsp := @all_ns[$i++];
                            $ns = nativecast(xmlNs, $nsp);
                            last if $ns.uri && ($ns.uri eq $namespace);
                        } while ($ns);
                        #xmlFree($all_ns);
                    }
                }
            }

            if (!$ns.defined) {
                # create new ns
                if $prefix.defined {
                    my $attr_p = $prefix.subst(/s/, '');
                    if $attr_p.chars {
                        $ns := xmlNewNs(
                            nativecast(xmlNode, self), $attr_ns, $attr_p
                        );
                    } else {
                        $ns := xmlNs;
                    }
                }
            }
        }

        if $attr_ns.defined && $attr_ns.chars && ! $ns.defined {
            die "bad ns attribute!";
            return            
        }

        xmlSetNsProp(nativecast(xmlNode, self), $ns, $localname, $val);
    }

    method getAttribute(Str $a) {
        sub xmlGetNoNsProp(xmlNode, Str)  returns Str      is native('xml2') { * }

        my $name = $a.subst(/\s/, '');
        return unless $name;

        my $ret;
        unless (
            $ret = xmlGetNoNsProp(nativecast(xmlNode, self), $name)
        ) {
            my ($prefix, $localname) = $a.split(':');

            if !$localname {
                $localname = $prefix;
                $prefix := Str;
            }
            if $localname {
                my $ns = xmlSearchNs(self.doc, self, $prefix);
                if $ns {
                    $ret = xmlGetNsProp(
                        nativecast(xmlNode, self), $localname, $ns.href
                    );
                }
            }
        }

        #my $retval = $ret.clone;
        #xmlFree($ret);

        return $ret;
    }

    method hasAttribute($a) {
        my $ret = domGetAttrNode(
            nativecast(xmlNode, self), $a
        );

        my $retVal = $ret ?? True !! False;
        #xmlFree($ret)

        return $retVal;
    }

    method hasAttributeNS($_ns!, Str $_name!) {
        my ($attr_ns, $name;);
        $attr_ns = $_ns.subst(/\s/, '') if $_ns.defined;
        $name = $_name.subst(/\s/, '') if $_name.defined;

        $attr_ns := Str if !$_ns.defined || !$attr_ns.chars;

        my xmlAttr $attr = nativecast(
            xmlAttr,
            xmlHasNsProp(nativecast(xmlNode, self), $name, $attr_ns)
        );

        return ($attr.defined && $attr.type == XML_ATTRIBUTE_NODE) ??
            True !! False;
    }

    method getAttributeNode($a) {
        my $ret := domGetAttrNode(
            nativecast(xmlNode, self), $a
        );
        #my $retVal = $ret.clone;
        #xmlFree($ret);

        # cw: Returns CStruct allocated from libxml2!
        return nativecast(XML::LibXML::Attr, $ret);
    }

    method getAttributeNodeNS(Str $ns!, Str $name!) {
        my $attr_ns = $ns.subst(/\s/, '');
        my $attr_name = $name.subst(/\s/, '');

        return unless $attr_name.chars;

        $attr_ns := Str unless $attr_ns.chars;
        my $ret_p = xmlHasNsProp(
            nativecast(xmlNode, self), $attr_name, $attr_ns
        );
        my $ret = nativecast(XML::LibXML::Attr, $ret_p);

        # cw: Deep XS code that has yet to be grokked.
        #my $retVal = PmmNodeToSv(
        #    $ret_p,
        #    PmmOWNERPO(PmmPROXYNODE(self))
        #);

        return $ret.type == XML_ATTRIBUTE_NODE ??
            $ret !! Nil;
    }

    method setAttributeNode(xmlAttr $an) {
        unless $an {
            die "Lost attribute";
            # cw: If caught and .resume'd, execution may return here.
            return;
        }

        return unless $an.type == XML_ATTRIBUTE_NODE;

        if $an.doc =:= self.doc {
            domImportNode(self.doc, $an, 1, 1);
        }

        my $ret;
        $ret = domGetAttrNode(
            nativecast(xmlNode, self), $an.name
        );
        if $ret {
            return unless $ret !=:= $an;
            
            xmlReplaceNode(
                nativecast(xmlNode, $ret), 
                nativecast(xmlNode, $an)
            );
        } else {
            xmlAddChild(
                nativecast(xmlNodePtr, self), 
                nativecast(xmlNodePtr, $an)
            );
        }

        # cw: ????
        #if ( attr->_private != NULL ) {
        #    PmmFixOwner( SvPROXYNODE(attr_node), PmmPROXYNODE(self) );
        #}

        return unless $ret;
        my $retVal = nativecast(XML::LibXML::Node, $ret);

        # cw: ?????
        #PmmFixOwner( SvPROXYNODE(RETVAL), NULL );
        return $retVal;
    }

    method setAttributeNodeNS(xmlAttr $an!) {
        sub xmlReconciliateNs(xmlDoc, xmlNode) returns int32 is native('xml2') { * }

        if !$an.defined {
            die "lost attribute node";
            # cw: For .resume in CATCH{}
            return;
        }

        return unless $an.type != XML_ATTRIBUTE_NODE;

        domImportNode(self.doc, $an, 1, 1) if $an.doc !=:= self.doc;
        my xmlNs $ns = $an.ns;
        my $ret = xmlHasNsProp(
            self, 
            $ns.defined ?? $ns.uri !! Str,
            $an.localname
        );

        if $ret.defined && $ret.type == XML_ATTRIBUTE_NODE {
            return if $ret =:= $an;
            xmlReplaceNode($ret, $an);
        } else {
            xmlAddChild(
                nativecast(xmlNodePtr, self), 
                nativecast(xmlNodePtr, $an)
            );
            xmlReconciliateNs(self.doc, self);
        }

        # cw: ??? XS
        #if ( attr->_private != NULL ) {
        #    PmmFixOwner( SvPROXYNODE(attr_node), PmmPROXYNODE(self) );
        #}

        return $ret;
    }

    method removeAttributeNode(xmlAttr $an!) {
        if !$an.defined {
            die "lost attribute node";
            # cw: For .resume in CATCH{}
            return;
        }

        return unless 
            $an.type == XML_ATTRIBUTE_NODE
            &&
            $an.parent !=:= self;

        my $an_p = nativecast(xmlNodePtr, $an);
        xmlUnlinkNode($an_p);

        # cw: ????
        # $ret = PmmNodeToSv($ret_p, NUL)
        # PmmFixOwner( SvPROXYNODE($ret), NULL)

        return $an;
    }

    method removeAttributeNS($_nsUri, $_name) {
        sub xmlFreeProp(xmlAttrPtr) is native('xml2') { * }

        my $nsUri = $_nsUri.defined ?? $_nsUri.subst(/\s/, '') !! Str;
        my $name = $_name.defined ?? $_name.subst(/\s/, '') !! Str;

        my xmlAttr $xattr = xmlHasNsProp(
            nativecast(xmlNode, self), $name, $nsUri
        );
        xmlUnlinkNode(nativecast(xmlNodePtr, $xattr)) 
            if $xattr.defined && $xattr.type == XML_ATTRIBUTE_NODE;

        if ($xattr.defined && $xattr._private.defined) {
            # cw: ???? XS code
            # PmmFixOwner((ProxyNodePtr)xattr->_private, NULL);
        } else {
            xmlFreeProp(nativecast(xmlAttrPtr, $xattr));
        }
    }    
}

class XML::LibXML::Node does XML::LibXML::Nodish {

    also does XML::LibXML::Common;

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

    method name() {
        self._name();
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
