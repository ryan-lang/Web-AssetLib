package Web::AssetLib::MinifierEngine::Pretty;

use Method::Signatures;
use Moose;
use Carp;
use JavaScript::Beautifier qw/js_beautify/;

use Web::AssetLib::Util;

use v5.14;
no if $] >= 5.018, warnings => "experimental";

extends 'Web::AssetLib::MinifierEngine';

has 'minifiers' => (
    is      => 'rw',
    isa     => 'HashRef',
    default => sub {
        my $self = shift;
        {   js => sub {
                return js_beautify( $_[0] );
            },
            css => sub {
                $_[0];
            },
            _else => sub {
                return $_[0];
            }
        };
    }
);

method minify ( :$contents!, :$type ) {
    if ( $self->minifiers->{$type} ) {
        return $self->minifiers->{$type}->($contents);
    }
    else {
        $self->minifiers->{'_else'}->($contents);
    }
}

no Moose;
1;

=pod
 
=encoding UTF-8
 
=head1 NAME

Web::AssetLib::MinifierEngine::Standard - basic CSS/Javascript minification engine

=head1 SYNOPSIS

    my $library = My::AssetLib::Library->new(
        minifier_engine => [
            Web::AssetLib::MinifierEngine::Standard->new()
        ]
    );

=head1 DESCRIPTION

Supports types: js, css, stylesheet, javascript.  All other types will pass through
unchanged.  Utilizes either L<CSS::Minifier> and L<JavaScript::Minifier> or 
L<CSS::Minifier::XS> and L<JavaScript::Minifier::XS> depending on availability.

=head1 USAGE

No configuration required. Simply instantiate, and include in your library's
list of input engines.

=head1 SEE ALSO

L<Web::AssetLib::MinifierEngine>

=head1 AUTHOR
 
Ryan Lang <rlang@cpan.org>

=cut
