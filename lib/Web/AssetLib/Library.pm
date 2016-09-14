package Web::AssetLib::Library;

use Method::Signatures;
use Moose;
use Carp;

use Web::AssetLib::Asset;

with 'Web::AssetLib::Role::Logger';

has 'input_engines' => (
    is      => 'rw',
    isa     => 'ArrayRef[Web::AssetLib::InputEngine]',
    traits  => [qw/Array/],
    handles => { _findInputEngine => 'first', allInputEngines => 'elements' }
);

has 'minifier_engines' => (
    is     => 'rw',
    isa    => 'ArrayRef[Web::AssetLib::MinifierEngine]',
    traits => [qw/Array/],
    handles =>
        { _findMinifierEngine => 'first', allMinifierEngines => 'elements' }
);

has 'output_engines' => (
    is     => 'rw',
    isa    => 'ArrayRef[Web::AssetLib::OutputEngine]',
    traits => [qw/Array/],
    handles =>
        { _findOutputEngine => 'first', allOutputEngines => 'elements' }
);

method compile (:$bundle!, :$output_engine = 'LocalFile', :$minifier_engine?, :$type?) {
    $minifier_engine = $self->findMinifierEngine($minifier_engine)
        if $minifier_engine;

    my $types = $bundle->groupByType();
    my $assets = $type ? $$types{$type} : [ $bundle->allAssets ];

    $self->log->dump( 'attempting to compile assets=', $assets, 'trace' );

    foreach my $asset (@$assets) {
        my $input_engine = $self->findInputEngine( $asset->input_engine );

        # populate contents and digest attributes
        $input_engine->load($asset);

        # bundle should not contain assets with matching
        # fingerprints, but it's possible that two assets
        # can have different fingerprints, but the same digest
        # (same file, different parameters)

        if ( $bundle->getDigest( $asset->digest ) ) {
            my $idx
                = $bundle->findAssetIdx( sub { $_->digest eq $asset->digest }
                );
            $bundle->deleteAsset($idx);
            $self->log->dump( 'duplicate digest found for asset=',
                $bundle->getAsset($idx), 'trace' );
        }
        else {
            $bundle->addDigest( $asset->digest => 1 );
        }
    }

    # output
    $output_engine = $self->findOutputEngine($output_engine);
    return $output_engine->export(
        bundle   => $bundle,
        minifier => $minifier_engine,
        type     => $type
    );
}

method compileAsset ($asset!) {

}

method findInputEngine ($name!) {
    my $engine = $self->_findInputEngine( sub { ref($_) =~ /$name/ } );
    return $engine if $engine;

    croak
        sprintf( "could not find input engine $name - available engines: %s",
        join( ', ', map { ref($_) } $self->allInputEngines ) );
}

method findMinifierEngine ($name!) {
    my $engine = $self->_findMinifierEngine( sub { ref($_) =~ /$name/ } );
    return $engine if $engine;

    croak
        sprintf(
        "could not find minifier engine $name - available engines: %s",
        join( ', ', map { ref($_) } $self->allMinifierEngines ) );
}

method findOutputEngine ($name!) {
    my $engine = $self->_findOutputEngine( sub { ref($_) =~ /$name/ } );
    return $engine if $engine;

    croak
        sprintf( "could not find output engine $name - available engines: %s",
        join( ', ', map { ref($_) } $self->allOutputEngines ) );
}

no Moose;
1;
