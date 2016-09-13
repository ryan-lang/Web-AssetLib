package Web::AssetLib::Bundle;

use Moose;

has 'assets' => (
    is      => 'rw',
    isa     => 'ArrayRef[Web::AssetLib::Asset]',
    traits  => [qw/Array/],
    handles => { addAsset => 'push', allAssets => 'elements' }
);

no Moose;
1;
