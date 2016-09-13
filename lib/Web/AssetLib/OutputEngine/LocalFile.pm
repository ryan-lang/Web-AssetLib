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

method export ($bundle!) {

    # group by type
    my $types;
    foreach my $asset ( $bundle->allAssets ) {
        push @{ $$types{ Web::AssetLib::Util::normalizeType( $asset->type ) }
        }, $asset;
    }
    $self->log->dump( 'types=', $types, 'trace' );

    my @tags;
    foreach my $type ( keys %$types ) {
        my @output_contents;

        my $digest = Digest->new("MD5");

        foreach my $asset ( @{ $$types{$type} } ) {
            $digest->add( $asset->_contents );
            push @output_contents, $asset->_contents;
        }

        my $output_path
            = path( $self->output_path )
            ->child( $digest->hexdigest . ".$type" );
        $output_path->touchpath;

        $output_path->append(@output_contents);
        push @tags, '<html string>';
    }

    return \@tags;
}

no Moose;
1;
