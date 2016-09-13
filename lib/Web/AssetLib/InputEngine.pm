package Web::AssetLib::InputEngine;

use Moose;

has 'asset_cache' => (
    is      => 'rw',
    isa     => 'HashRef',
    default => sub { {} },
    traits  => [qw/Hash/],
    handles => {
        addAssetToCache   => 'set',
        getAssetFromCache => 'get'
    }
);

no Moose;
1;
