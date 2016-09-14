package Web::AssetLib::OutputEngine;

use Method::Signatures;
use Moose;
use HTML::Element;

use v5.14;
no if $] >= 5.018, warnings => "experimental";

with 'Web::AssetLib::Role::Logger';

method generateHtmlTag (:$src!,:$type!) {
    my $mime = Web::AssetLib::Util::normalizeMimeType($type);
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
    }

    return $el->as_HTML;
}

no Moose;
1;
