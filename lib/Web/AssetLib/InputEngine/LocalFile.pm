package Web::AssetLib::InputEngine::LocalFile;

use Method::Signatures;
use Moose;
use Carp;

use Path::Tiny;

extends 'Web::AssetLib::InputEngine';

has 'search_paths' => (
    is      => 'rw',
    isa     => 'ArrayRef',
    default => sub { [] },
    traits  => [qw/Array/],
    handles => { 'allSearchPaths' => 'elements' }
);

method load ($asset!) {
    croak sprintf( "%s requires 'path' asset input_arg", ref($self) )
        unless $asset->input_args->{path};

    my $path = $self->_findAssetPath($asset);

    my $contents = $path->slurp_utf8;
    my $digest   = $path->digest;

    $asset->_contents( $contents );
    $asset->_digest($digest);
}

# search all the included search paths for the asset
method _findAssetPath ($asset!) {
    foreach my $path ( $self->allSearchPaths ) {
        $path = path($path);

        # does the root path exist?
        unless ( $path->exists ) {
            $self->log->warn("skipping path '$path' - does not exist");
            next;
        }

        my $target_path = $path->child( $asset->input_args->{path} );
        if ( $target_path->exists ) {
            return $target_path;
        }
    }

    croak sprintf(
        "could not find asset %s in search paths (%s)",
        $asset->input_args->{path},
        join( ', ', $self->allSearchPaths )
    );
}

no Moose;
1;
