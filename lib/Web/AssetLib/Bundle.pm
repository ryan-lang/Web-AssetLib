package Web::AssetLib::Bundle;

use Method::Signatures;
use Moose;
use Carp;
use Web::AssetLib::Util;

with 'Web::AssetLib::Role::Logger';

use v5.14;
no if $] >= 5.018, warnings => "experimental";

# store assets as hashref
has 'assets' => (
    is      => 'rw',
    isa     => 'ArrayRef[Web::AssetLib::Asset]',
    traits  => [qw/Array/],
    handles => {
        _addAsset    => 'push',
        allAssets    => 'elements',
        countAssets  => 'count',
        filterAssets => 'grep',
        findAsset    => 'first',
        findAssetIdx => 'first_index',
        deleteAsset  => 'delete',
        filterAssets => 'grep',
        getAsset     => 'get'
    }
);

has '_digest_map' => (
    is      => 'rw',
    isa     => 'HashRef',
    traits  => [qw/Hash/],
    handles => {
        addDigest => 'set',
        getDigest => 'get'
    }
);

has 'isCompiled' => (
    is      => 'ro',
    isa     => 'Bool',
    writer  => '_set_isCompiled',
    default => 0
);

method addAssets (@_) {
    $self->_set_isCompiled(0);
    return $self->addAsset(@_);
}

method addAsset (@assets) {
    $self->_set_isCompiled(0);
    foreach my $asset (@assets) {
        for ( ref($asset) ) {
            when ('Web::AssetLib::Asset') {
                unless ( $self->_checkForDuplicate($asset) ) {
                    $self->_addAsset($asset);
                }
            }
            when ('') {

                # shortcut: strings will be interpreted as LocalFiles

                $asset =~ m/\.(\w+)$/;
                my $extension = $1;

                my $a = Web::AssetLib::Asset->new(
                    input_args => { path => $asset },
                    type       => $extension
                );

                unless ( $self->_checkForDuplicate($a) ) {
                    $self->_addAsset($a);
                }
            }
            default {
                $self->log->dump( 'unknown asset type=', $asset, 'warn' );
                croak
                    "assets must be either a string or a Web::AssetLib::Asset object - got a $_";
            }
        }
    }
}

has 'link_paths' => (
    is      => 'rw',
    isa     => 'HashRef',
    default => sub { {} }
);

method groupByType () {
    my $types;
    foreach my $asset ( $self->allAssets ) {
        push @{ $$types{ $asset->type } }, $asset;
    }
    return $types;
}

method as_html ( :$type!, :$html_attrs = {} ) {

    $self->log->warn('attempting to generate html before bundle is compiled')
        unless $self->isCompiled;

    my @tags;
    my $links = $self->link_paths->{$type};

    if ( $links && ref $links eq 'ARRAY' ) {
        foreach my $link (@$links) {
            my $tag = Web::AssetLib::Util::generateHtmlTag(
                src  => $link,
                type => $type
            );
            push @tags, $tag;
        }
    }

    return join( "\n", @tags );
}

method _checkForDuplicate ($asset!) {
    if ( my $dup
        = $self->findAsset( sub { $asset->fingerprint eq $_->fingerprint } ) )
    {
        $self->log->dump( 'duplicate fingerprint found for asset=',
            { adding => $asset, found => $dup }, 'trace' );
        return 1;
    }
    else {
        return 0;
    }
}

no Moose;
1;

=pod
 
=encoding UTF-8
 
=head1 NAME

Web::AssetLib::Bundle - an indexed grouping of L<Web::AssetLib::Asset> objects

=head1 SYNOPSIS

    my $bundle = Web::AssetLib::Bundle->new();

    my $asset = Web::AssetLib::Asset->new(
        type         => 'javascript',
        input_engine => 'LocalFile',
        rank         => -100,
        input_args => { path => "your/local/path/jquery.min.js", }
    );

    $bundle->addAsset( $asset );
    $bundle->addAsset( '/my/local/file.js', '/my/local/file.css' );

    $library->compile( bundle => $bundle );

=head1 ATTRIBUTES
 
=head2 assets
 
Arrayref of L<Web::AssetLib::Asset> objects

=head1 METHODS

=head2 addAsset(@assets)

=head2 addAssets(@assets)
 
Adds an asset to the bundle. Accepts an array of L<Web::AssetLib::Asset> 
instances, or an array of strings. Using a string is a shortcut for defining
a LocalFile asset, with the type determined by the file extension.

=head2 as_html()
 
Returns an HTML-formatted string linking to bundle's output location.  Only 
available after the bundle has been compiled, otherwise returns undef.

=head1 AUTHOR
 
Ryan Lang <rlang@cpan.org>

=cut
