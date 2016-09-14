package Web::AssetLib::Bundle;

use Method::Signatures;
use Moose;

has 'assets' => (
    is      => 'rw',
    isa     => 'HashRef[Web::AssetLib::Asset]',
    traits  => [qw/Hash/],
    handles => {
        _addAsset   => 'set',
        allAssets   => 'values',
        deleteAsset => 'delete',
        countAssets => 'count'
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

method addAsset (@assets) {
    foreach (@assets) {
        $self->_addAsset( $_->name => $_ );
    }
}

has 'html_links' => (
    is      => 'rw',
    isa     => 'ArrayRef',
    default => sub { [] }
);

no Moose;
1;
