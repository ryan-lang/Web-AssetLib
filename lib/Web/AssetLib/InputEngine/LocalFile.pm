package Web::AssetLib::InputEngine::LocalFile;

use Method::Signatures;
use Moose;
use Carp;
use Web::AssetLib::Asset;
use Path::Tiny;

use v5.14;
no if $] >= 5.018, warnings => "experimental";

extends 'Web::AssetLib::InputEngine';

has 'search_paths' => (
    is      => 'rw',
    isa     => 'ArrayRef',
    default => sub { [] },
    traits  => [qw/Array/],
    handles => { 'allSearchPaths' => 'elements' }
);

method load ($asset!, $bundle?) {
    croak sprintf( "%s requires 'path' asset input_arg", ref($self) )
        unless $asset->input_args->{path};

    my $path = $self->_findAssetPath($asset);

    $asset->original_filename( $path->basename );

    if ( $asset->isPassthru ) {
        $asset->link_path("$path");
        return;
    }
    else {
        my $digest = $path->digest;

        # will return undef if asset not in cache,
        # otherwise will return contents from previous read
        my $contents = $self->getAssetFromCache($digest);

        unless ($contents) {

            $contents = $path->slurp_raw;
            $contents =~ s/\xef\xbb\xbf//;    # remove BOM if exists

            $self->addAssetToCache( $digest => $contents );
        }

        $self->storeAssetContents(
            asset    => $asset,
            digest   => $digest,
            contents => $contents
        );
    }
}

# search all the included search paths for the asset
method _findAssetPath ($asset!) {
    foreach my $path ( $self->allSearchPaths ) {
        next unless $path;
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

# utility method to "expand" a path into several assets
method collectInPath (:$path!, :$match?, :$options = {}) {
    foreach my $sPath ( $self->allSearchPaths ) {
        next unless $sPath;
        $sPath = path($sPath);

        # does the search path exist?
        unless ( $sPath->exists ) {
            $self->log->warn("skipping path '$sPath' - does not exist");
            next;
        }

        $path = $sPath->child($path);

        unless ( $path->is_dir ) {
            croak "target path ($path) must be a directory";
        }

        my @children;
        if ($match) {
            @children = $path->children($match);
        }
        else {
            @children = $path->children;
        }

        my @assets;
        foreach my $child (@children) {

            # get a path to the found assets, must
            # be relative for search in _findAssetPath later
            my $relpath = $child->relative($sPath);

            my $input_args = $$options{input_args} // {};
            delete $$options{input_args};

            push @assets,
                Web::AssetLib::Asset->new(
                name       => $child->basename,
                input_args => { path => "$relpath", %$input_args },
                %$options
                );
        }

        return @assets;
    }
}

no Moose;
1;

=pod
 
=encoding UTF-8
 
=head1 NAME

Web::AssetLib::InputEngine::LocalFile - allows importing an asset from your local filesystem

=head1 SYNOPSIS

    my $library = My::AssetLib::Library->new(
        input_engines => [
            Web::AssetLib::InputEngine::LocalFile->new(
                search_paths => [ '/my/local/asset/dir' ]
            )
        ]
    );

    # asset existing at "/my/local/asset/dir/myfile.js":
    my $asset = Web::AssetLib::Asset->new(
        type         => 'javascript',
        input_engine => 'LocalFile',
        input_args   => { path => "myfile.js", }
    );

    $library->compile( asset => $asset );

=head1 USAGE

Instantiate with C<< search_paths >> parameter, and include in your library's
input engine list.

Assets using the LocalFile input engine must provide C<< path >> input arg.

=head1 ATTRIBUTES
 
=head2 search_paths
 
Arrayref of local filesystem root paths to search when looking for an
asset.

=head1 METHODS
 
=head2 allSearchPaths

    my @paths = $engine->allSearchPaths();
 
Returns a list of search paths.

=head1 SEE ALSO

L<Web::AssetLib::InputEngine>

L<Web::AssetLib::InputEngine::RemoteFile>

L<Web::AssetLib::InputEngine::Content>

=head1 AUTHOR
 
Ryan Lang <rlang@cpan.org>

=cut
