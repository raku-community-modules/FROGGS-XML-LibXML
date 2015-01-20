use v6;
use Test;
use XML::LibXML;

plan 3;

# TEST
ok 1, 'Loaded fine';

my $p = XML::LibXML.new();

# TEST
ok $p, 'Can initialize a new XML::LibXML instance';

my $version = XML::LibXML.parser-version;

# TEST
ok $version, 'XML::LibXML.parser-version is trueish';

diag "Running libxml2 version: " ~ $version;
