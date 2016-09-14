package Web::AssetLib::OutputEngine;

use Method::Signatures;
use Moose;
use HTML::Element;
use Digest;
use Encode qw(encode);
use Carp;

use v5.14;
no if $] >= 5.018, warnings => "experimental";

with 'Web::AssetLib::Role::Logger';

method export (:$bundle?, :$asset?, :$minifier?, :$type?) {
    if ( $asset && !$bundle ) {
        return $self->_exportAsset(
            asset    => $asset,
            minifier => $minifier
        );
    }
    elsif ( $bundle && !$asset ) {
        return $self->_exportBundle(
            bundle   => $bundle,
            minifier => $minifier,
            type     => $type
        );
    }
    elsif ( $bundle && $asset ) {
        croak "cannot provide both bundle and asset - dont know what to do";
    }
    else {
        croak "either asset or bundle must be provided";
    }
}

method _exportBundle (:$bundle!,:$minifier?,:$type?) {
    my $types = $bundle->groupByType();

    my @tags;
    if ($type) {

        # if type is provided, export only that
        my $tag = $self->_exportByType(
            assets   => $$types{$type},
            type     => $type,
            minifier => $minifier
        );
        push @tags, $tag;
    }
    else {
        # if type is NOT provided, export all
        foreach $type ( keys %$types ) {
            my $tag = $self->_exportByType(
                assets   => $$types{$type},
                type     => $type,
                minifier => $minifier
            );
            next unless $tag;
            push @tags, $tag;
        }
    }

    $bundle->html_links( \@tags );
    return $bundle;
}

method _exportAsset (:$asset!,:$minifier?) {
    my $tag = $self->_exportByType(
        assets   => [$asset],
        type     => Web::AssetLib::Util::normalizeFileType( $asset->type ),
        minifier => $minifier
    );
    $asset->html_link($tag);
    return $asset;
}

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
        when ('image/jpeg') {
            $el = HTML::Element->new( 'img', src => $src );
        }
    }

    return $el->as_HTML;
}

method _concatAssets ($assets!) {
    my $output_contents;
    my $digest = Digest->new("MD5");

    if ( @$assets > 1 ) {
        foreach my $asset ( sort { $a->rank <=> $b->rank } @$assets ) {
            $output_contents .= $asset->contents . "\n\r\n\r";
        }
    }
    else {
        $output_contents = $assets->[0]->contents;
    }

    $digest->add( $output_contents);

    return ( $output_contents, $digest->hexdigest );
}

no Moose;
1;
