package Web::AssetLib::Output;

use Moo;
use Types::Standard qw/Str/;

has 'type' => (
    is  => 'rw',
    isa => Str
);

1;