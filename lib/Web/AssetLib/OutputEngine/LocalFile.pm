package Web::AssetLib::OutputEngine::LocalFile;

use Method::Signatures;
use Moose;
use Digest;
use Carp;
use Encode qw(encode_utf8);

use Web::AssetLib::Util;

use Path::Tiny;

extends 'Web::AssetLib::OutputEngine';

has 'output_path' => (
    is       => 'rw',
    isa      => 'Str',
    required => 1
);

# should correspond with the root of output_path
has 'link_path' => (
    is       => 'rw',
    isa      => 'Str',
    required => 1
);

method export (:$bundle!, :$minifier?, :$type?) {
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

method _exportByType (:$assets!, :$type!, :$minifier?) {
    my $output_contents;

    my $digest = Digest->new("MD5");

    foreach my $asset ( sort { $a->rank <=> $b->rank } @$assets ) {
        $digest->add( encode_utf8( $asset->contents ) );
        $output_contents .= $asset->contents;
    }

    my $filename    = $digest->hexdigest . ".$type";
    my $output_path = path( $self->output_path )->child($filename);
    my $link_path   = path( $self->link_path )->child($filename);

    unless ( $output_path->exists ) {
        $output_path->touchpath;

        if ($minifier) {
            $output_contents = $minifier->minify(
                contents => $output_contents,
                type     => $type
            );
        }

        $output_path->spew_utf8($output_contents);
    }

    return $self->generateHtmlTag( src => $link_path, type => $type );
}

no Moose;
1;
