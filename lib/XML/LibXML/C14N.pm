use v6;
use nqp;

unit role XML::LibXML::C14N;

use NativeCall;
use XML::LibXML::CStructs :types;
use XML::LibXML::Subs;
use XML::LibXML::Enums;

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
