package Web::AssetLib::OutputEngine::LocalFile;

use Method::Signatures;
use Moose;
use Digest;
use Carp;

use Web::AssetLib::Util;

use Path::Tiny;

extends 'Web::AssetLib::OutputEngine';

has 'output_path' => (
    is       => 'rw',
    isa      => 'Str',
    required => 1
);

# should correspond with the root of output_path
has 'html_path' => (
    is       => 'rw',
    isa      => 'Str',
    required => 1
);

method export (:$bundle!, :$minifier?) {

    # group by type
    my $types;
    foreach my $asset ( $bundle->allAssets ) {
        push @{ $$types{ Web::AssetLib::Util::normalizeType( $asset->type ) }
        }, $asset;
    }
    $self->log->dump( 'types=', $types, 'trace' );

    my @tags;
    foreach my $type ( keys %$types ) {
        my $output_contents;

        my $digest = Digest->new("MD5");

        foreach my $asset ( @{ $$types{$type} } ) {
            $digest->add( $asset->contents );
            $output_contents .= $asset->contents;
        }

        my $output_path
            = path( $self->output_path )
            ->child( $digest->hexdigest . ".$type" );

        push @tags, '<html string>';
        if ( $output_path->exists ) {
            next;
        }
        else {
            $output_path->touchpath;

            if ($minifier) {
                $output_contents = $minifier->minify(
                    contents => $output_contents,
                    type     => $type
                );
            }

            $output_path->spew_utf8($output_contents);
        }

    }

    return \@tags;
}

no Moose;
1;
