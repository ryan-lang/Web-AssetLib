package Web::AssetLib::Library;

use Method::Signatures;
use Moose;
use Carp;

use Web::AssetLib::Asset;

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

method compile (:$bundle!, :$output_engine = 'LocalFile', :$minifier_engine?) {
    $minifier_engine = $self->findMinifierEngine($minifier_engine)
        if $minifier_engine;

    # TODO: sort by rank
    foreach my $asset ( $bundle->allAssets ) {
        my $input_engine = $self->findInputEngine( $asset->input_engine );

        # populate _content and _digest attributes
        $input_engine->load($asset);

        # minify, if requested
        if ($minifier_engine) {
            $minifier_engine->minify($asset);
        }
    }

    # output
    $output_engine = $self->findOutputEngine($output_engine);
    return $output_engine->export($bundle);
}

method compileByType () {

    # compile but filter original assets list by type
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
