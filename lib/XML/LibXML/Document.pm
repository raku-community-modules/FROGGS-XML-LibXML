#| Objects that implement the Document interface have all properties and functions
#| of the Node interface as well as the properties and functions defined below.
class XML::LibXML::Document is repr('CStruct') is XML::LibXML::Node does XML::LibXML::C14N {
    has OpaquePointer $._private; # application data
    has int8              $.type; # (xmlElementType) XML_DOCUMENT_NODE, must be second !
    has Str          $.localname; # name/filename/URI of the document
    has xmlNodePtr    $.children; # the document tree
    has xmlNodePtr        $.last; # last child link
    has xmlNodePtr      $.parent; # child->parent link
    has xmlNodePtr        $.next; # next sibling link
    has xmlNodePtr        $.prev; # previous sibling link
    has XML::LibXML::Document $.doc; # autoreference to itself End of common p
    has int32      $.compression; # level of zlib compression
    has int32       $.standalone; # standalone document (no external refs)
    has xmlDtdPtr    $.intSubset; # the document internal subset
    has xmlDtdPtr    $.extSubset; # the document external subset
    has xmlNsPtr         $.oldNs; # Global namespace, the old way
    has Str            $.version; # the XML version string
    has Str           $.encoding; # external initial encoding, if any
    has OpaquePointer      $.ids; # Hash table for ID attributes if any
    has OpaquePointer     $.refs; # Hash table for IDREFs attributes if any
    has Str                $.uri; # The URI for that document
    has int32          $.charset; # encoding of the in-memory content actua
    #~ struct _xmlDict *	dict	: dict used to allocate names or NULL
    #~ void *	psvi	: for type/PSVI informations
    #~ int	parseFlags	: set of xmlParserOption used to parse th
    #~ int	properties	: set of xmlDocProperties for this docume

    ## Properties of objects that implement the Document interface:

    #| This read-only property is an object that implements the DocumentType interface.
    method doctype is aka<type> {
        xmlElementType(nqp::p6box_i(nqp::getattr_i(nqp::decont(self), XML::LibXML::Document, '$!type')))
    }

    #~ implementation
        #~ This read-only property is an object that implements the DOMImplementation interface.

    #| This read-only property is an object that implements the Element interface.
    method documentElement is aka<root> {
        Proxy.new(
            FETCH => -> $ {
                xmlDocGetRootElement(self)
            },
            STORE => -> $, $new {
                my $root = xmlDocGetRootElement(self);
                $root ?? xmlReplaceNode($root, $new)
                      !! xmlDocSetRootElement(self, $new);
                $new
            }
        )
    }

    #~ inputEncoding
        #~ This read-only property is a String.

    #| This read-only property is a String.
    method xmlEncoding is aka<encoding> {
        Proxy.new(
            FETCH => -> $ {
                xmlGetCharEncodingName(self.charset).lc
            },
            STORE => -> $, Str $new {
                my $enc = xmlParseCharEncoding($new);
                die if $enc < 0;
                nqp::bindattr_i(nqp::decont(self), XML::LibXML::Document, '$!charset', $enc);
                $new
            }
        )
    }

    #| This property is a String and can raise an object that implements the DOMException interface on setting.
    method xmlVersion() is aka<version> {
        Proxy.new(
            FETCH => -> $ {
                Version.new(nqp::getattr(nqp::decont(self), XML::LibXML::Document, '$!version'))
            },
            STORE => -> $, $new {
                nqp::bindattr(nqp::decont(self), XML::LibXML::Document, '$!version', nqp::unbox_s(~$new));
                $new
            }
        )
    }

    #| This property is a Boolean and can raise an object that implements the DOMException interface on setting.
    method xmlStandalone is aka<standalone> {
        Proxy.new(
            FETCH => -> $ {
                nqp::p6box_i(nqp::getattr_i(nqp::decont(self), XML::LibXML::Document, '$!standalone'))
            },
            STORE => -> $, int32 $new {
                nqp::bindattr_i(nqp::decont(self), XML::LibXML::Document, '$!standalone', $new);
                $new
            }
        )
    }

    #~ strictErrorChecking
        #~ This property is a Boolean.

    #| This property is a String.
    method documentURI is aka<uri> {
        Proxy.new(
            FETCH => -> $ {
                nqp::getattr(nqp::decont(self), XML::LibXML::Document, '$!uri')
            },
            STORE => -> $, $new {
                nqp::bindattr(nqp::decont(self), XML::LibXML::Document, '$!uri', nqp::unbox_s(~$new));
                $new
            }
        )
    }

    method base-uri() {
        Proxy.new(
            FETCH => -> $ {
                xmlNodeGetBase(self.doc, self)
            },
            STORE => -> $, $new {
                nqp::bindattr(nqp::decont(self), XML::LibXML::Document, '$!uri', nqp::unbox_s(~$new));
                $new
            }
        )
    }

    #~ domConfig
        #~ This read-only property is an object that implements the DOMConfiguration interface.

    ## Functions of objects that implement the Document interface:

    #~ createElement(tagName)
        #~ This function returns an object that implements the Element interface.
        #~ The tagName parameter is a String.
        #~ This function can raise an object that implements the DOMException interface.
    #~ createDocumentFragment()
        #~ This function returns an object that implements the DocumentFragment interface.
    #~ createTextNode(data)
        #~ This function returns an object that implements the Text interface.
        #~ The data parameter is a String.
    #~ createComment(data)
        #~ This function returns an object that implements the Comment interface.
        #~ The data parameter is a String.
    #~ createCDATASection(data)
        #~ This function returns an object that implements the CDATASection interface.
        #~ The data parameter is a String.
        #~ This function can raise an object that implements the DOMException interface.
    #~ createProcessingInstruction(target, data)
        #~ This function returns an object that implements the ProcessingInstruction interface.
        #~ The target parameter is a String.
        #~ The data parameter is a String.
        #~ This function can raise an object that implements the DOMException interface.
    #~ createAttribute(name)
        #~ This function returns an object that implements the Attr interface.
        #~ The name parameter is a String.
        #~ This function can raise an object that implements the DOMException interface.
    #~ createEntityReference(name)
        #~ This function returns an object that implements the EntityReference interface.
        #~ The name parameter is a String.
        #~ This function can raise an object that implements the DOMException interface.
    #~ getElementsByTagName(tagname)
        #~ This function returns an object that implements the NodeList interface.
        #~ The tagname parameter is a String.
    #~ importNode(importedNode, deep)
        #~ This function returns an object that implements the Node interface.
        #~ The importedNode parameter is an object that implements the Node interface.
        #~ The deep parameter is a Boolean.
        #~ This function can raise an object that implements the DOMException interface.
    #~ createElementNS(namespaceURI, qualifiedName)
        #~ This function returns an object that implements the Element interface.
        #~ The namespaceURI parameter is a String.
        #~ The qualifiedName parameter is a String.
        #~ This function can raise an object that implements the DOMException interface.
    #~ createAttributeNS(namespaceURI, qualifiedName)
        #~ This function returns an object that implements the Attr interface.
        #~ The namespaceURI parameter is a String.
        #~ The qualifiedName parameter is a String.
        #~ This function can raise an object that implements the DOMException interface.
    #~ getElementsByTagNameNS(namespaceURI, localName)
        #~ This function returns an object that implements the NodeList interface.
        #~ The namespaceURI parameter is a String.
        #~ The localName parameter is a String.
    #~ getElementById(elementId)
        #~ This function returns an object that implements the Element interface.
        #~ The elementId parameter is a String.
    #~ adoptNode(source)
        #~ This function returns an object that implements the Node interface.
        #~ The source parameter is an object that implements the Node interface.
        #~ This function can raise an object that implements the DOMException interface.
    #~ normalizeDocument()
        #~ This function has no return value.
    #~ renameNode(n, namespaceURI, qualifiedName)
        #~ This function returns an object that implements the Node interface.
        #~ The n parameter is an object that implements the Node interface.
        #~ The namespaceURI parameter is a String.
        #~ The qualifiedName parameter is a String.
        #~ This function can raise an object that implements the DOMException interface.

    method new(:$version = '1.0', :$encoding) {
        my $doc       = xmlNewDoc(~$version);
        $doc.encoding = $encoding if $encoding;
        $doc
    }

    method Str() {
        my $result = CArray[Str].new();
        my $len    = CArray[int32].new();
        $result[0] = "";
        $len[0]    = 0;
        xmlDocDumpMemory(self, $result, $len);
        $result[0]
    }

    method gist() {
        my $result = CArray[Str].new();
        my $len    = CArray[int32].new();
        $result[0] = "";
        $len[0]    = 0;
        xmlDocDumpFormatMemory(self, $result, $len, 1);
        $result[0]
    }

    method name() {
        "#document"
    }

    method new-doc-fragment() {
        my $node = xmlNewDocFragment( self );
        nqp::bindattr(nqp::decont($node), XML::LibXML::Node, '$!doc', nqp::decont(self));
        $node
    }

    method new-elem(Str $elem) {
        if $elem.match(/[ ^<[\W\d]> | <-[\w_.-]> ]/) -> $bad {
            fail X::XML::InvalidName.new( :name($elem), :pos($bad.from), :routine(&?ROUTINE) )
        }

        my $node = xmlNewNode( self, $elem );
        nqp::bindattr(nqp::decont($node), XML::LibXML::Node, '$!doc', nqp::decont(self));
        $node
    }

    multi method new-elem-ns(Pair $kv, $uri) {
        my ($prefix, $name) = $kv.key.split(':', 2);

        unless $name {
            $name   = $prefix;
            $prefix = Str;
        }

        my $ns = xmlNewNs(XML::LibXML::Document, $uri, $prefix);

        my $buffer = $kv.value && xmlEncodeEntitiesReentrant(self, $kv.value);
        my $node   = xmlNewDocNode(self, $ns, $name, $buffer);
        nqp::bindattr(nqp::decont($node), XML::LibXML::Node, '$!nsDef', nqp::decont($ns));
        nqp::bindattr(nqp::decont($node), XML::LibXML::Node, '$!doc',   nqp::decont(self));
        $node
    }
    multi method new-elem-ns(%kv where *.elems == 1, $uri) {
        self.new-elem-ns(%kv.list[0], $uri)
    }
    multi method new-elem-ns($name, $uri) {
        self.new-elem-ns($name => Str, $uri)
    }

    multi method new-attr(Pair $kv) {
        my $buffer = xmlEncodeEntitiesReentrant(self, $kv.value);
        my $attr   = xmlNewDocProp(self, $kv.key, $buffer);
        nqp::bindattr(nqp::decont($attr), xmlAttr, '$!doc', nqp::decont(self));
        $attr
    }
    multi method new-attr(*%kv where *.elems == 1) {
        self.new-attr(%kv.list[0])
    }

    multi method new-attr-ns(Pair $kv, $uri) {
        my $root = self.root;
        fail "Can't create a new namespace on an attribute!" unless $root;

        my ($prefix, $name) = $kv.key.split(':', 2);

        unless $name {
            $name   = $prefix;
            $prefix = Str;
        }

        my $ns = xmlSearchNsByHref(self, $root, $uri)
              || xmlNewNs($root, $uri, $prefix); # create a new NS if the NS does not already exists

        my $buffer = xmlEncodeEntitiesReentrant(self, $kv.value);
        my $attr   = xmlNewDocProp(self, $name, $buffer);
        xmlSetNs($attr, $ns);
        nqp::bindattr(nqp::decont($attr), xmlAttr, '$!doc', nqp::decont(self));
        $attr
    }
    multi method new-attr-ns(%kv where *.elems == 1, $uri) {
        self.new-attr-ns(%kv.list[0], $uri)
    }

    method new-text(Str $text) {
        my $node = xmlNewText( $text );
        nqp::bindattr(nqp::decont($node), XML::LibXML::Node, '$!doc', nqp::decont(self));
        $node
    }

    method new-comment(Str $comment) {
        my $node = xmlNewDocComment( self, $comment );
        nqp::bindattr(nqp::decont($node), XML::LibXML::Node, '$!doc', nqp::decont(self));
        $node
    }

    method new-cdata-block(Str $cdata) {
        my $node = xmlNewCDataBlock( self, $cdata, xmlStrlen($cdata) );
        nqp::bindattr(nqp::decont($node), XML::LibXML::Node, '$!doc', nqp::decont(self));
        $node
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
