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

method addAssets (@_) {
    return $self->addAsset(@_);
}

method addAsset (@assets) {
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

has 'html_links' => (
    is      => 'rw',
    isa     => 'ArrayRef',
    default => sub { [] }
);

method groupByType () {
    my $types;
    foreach my $asset ( $self->allAssets ) {
        push
            @{ $$types{ Web::AssetLib::Util::normalizeFileType( $asset->type )
            } }, $asset;
    }
    return $types;
}

method as_html () {
    return join( "\n", @{ $self->html_links } );
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
