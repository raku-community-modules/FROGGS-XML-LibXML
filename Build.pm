use v6;
use Panda::Common;
use Panda::Builder;
use Panda::Tester;

my class X::Perl5::CannotBuildModule is Exception {
    has $.cmd;
    has $.module;
    method message {
        "ERROR: Cannot build $!module<name>, failing command was:\n\t$!cmd"
    }
}

my $perl6 = "$*EXECUTABLE -I$*CWD/lib";

my @source-files = <
    lib/XML/LibXML/preamble.pm
    lib/XML/LibXML/CStructs.pm
    lib/XML/LibXML/Subs.pm
    lib/XML/LibXML/Enums.pm
    lib/XML/LibXML/Error.pm
    lib/XML/LibXML/C14N.pm
    lib/XML/LibXML/Node.pm
    lib/XML/LibXML/Document.pm
    lib/XML/LibXML/Attr.pm
    lib/XML/LibXML/Parser.pm
>;

class Build is Panda::Builder {
    method build(|) {
        my $source = '';
        for @source-files -> $file {
            $source ~= "\n###### $file ######\n" ~ $file.IO.slurp
        }
        'lib/XML/LibXML.pm'.IO.spurt: $source
    }

    method test($where, :$prove-command = 'prove') {
        withp6lib {
            my $c = "$prove-command -e $*EXECUTABLE -r t/00-sanity.t";
            shell $c or fail "Tests failed";
        }
    }
}

multi MAIN('build') {
    Build.build
}

multi MAIN('test') {
    
}

multi MAIN('clean') {
    my sub recurse-and-clean($path) {
        if $path.d {
            recurse-and-clean($_) for $path.dir
        }
        elsif $path ~~ / '.' <{$*VM.precomp-ext}> $/ {
            unlink $path
        }
    }
    recurse-and-clean('blib'.IO);
    recurse-and-clean('lib'.IO)
}

multi MAIN('install') {
    
}

sub mkdir-p($path) {
    $*DISTRO.is-win ?? shell("mkdir $path") !! shell("mkdir -p $path")
}
