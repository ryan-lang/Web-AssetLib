package Web::AssetLib::InputEngine;

use Moose;

with 'Web::AssetLib::Role::Logger';

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
