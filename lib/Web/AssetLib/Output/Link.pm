package Web::AssetLib::Output::Link;

use Moo;
use Types::Standard qw/Str/;

extends 'Web::AssetLib::Output';

has 'src' => (
    is       => 'rw',
    isa      => Str,
    required => 1
);

1;
