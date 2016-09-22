package Web::AssetLib::Util;

use Method::Signatures;
use Moose;
use Carp;
use HTML::Element;

use v5.14;
no if $] >= 5.018, warnings => "experimental";

my %FILE_TYPES = (
    js         => 'js',
    javascript => 'js',
    css        => 'css',
    stylesheet => 'css',
    jpeg       => 'jpg',
    jpg        => 'jpg'
);

my %MIME_TYPES = (
    js         => 'text/javascript',
    javascript => 'text/javascript',
    css        => 'text/css',
    stylesheet => 'text/css',
    jpg        => 'image/jpeg',
    jpeg       => 'image/jpeg'
);

func normalizeFileType ($type!) {
    if ( my $normalized = $FILE_TYPES{$type} ) {
        return $normalized;
    }
    else {
        croak "could not map type '$type'";
    }
}

func normalizeMimeType ($type!) {
    if ( my $normalized = $MIME_TYPES{$type} ) {
        return $normalized;
    }
    else {
        croak "could not map type '$type'";
    }
}

func generateHtmlTag (:$src!, :$type!) {
    my $mime = normalizeMimeType($type);
    my $el;
    for ($mime) {
        when ('text/css') {
            $el = HTML::Element->new(
                'link',
                href => $src,
                rel  => 'stylesheet',
                type => $mime
            );
        }
        when ('text/javascript') {
            $el = HTML::Element->new(
                'script',
                src  => $src,
                type => $mime
            );
        }
        when ('image/jpeg') {
            $el = HTML::Element->new( 'img', src => $src );
        }
    }

    return $el->as_HTML;
}

no Moose;
1;

=pod
 
=encoding UTF-8
 
=head1 NAME

Web::AssetLib::Util - core utilties for Web::AssetLib

=head1 FUNCTIONS

=head2 normalizeFileType( $type! )

Converts file type string to a normalized version of that string.
e.g. "javascript" maps to "js"

=head2 normalizeMimeType( $type! )

Converts file type string to a mime type.
e.g. "javascript" maps to "text/javascript"

=head1 AUTHOR
 
Ryan Lang <rlang@cpan.org>

=cut
