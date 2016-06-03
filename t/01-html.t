use v6;
use Test;
use XML::LibXML;
use NativeCall;

plan 7;

#~ my $html-string = 'example/yahoo-finance-html-with-errors.html'.IO.slurp;
#~ my $html-string = 'example/test.html'.IO.slurp;
my $html-string = '<html><head><title>Test</title></head></html>';

my $parser = XML::LibXML.new();
my $doc    = $parser.parse-html($html-string);

ok $doc, 'Parsing successful.';

say $doc.elems;
#~ say $doc.find('//form').map: { .childNodes.grep(*.name eq 'input').map({ .name => .value, .attrs }) };
say $doc;

#~ my @nodes = $doc.find('//title')[0][0];
#~ say @nodes;
