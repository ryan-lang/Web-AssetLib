package Web::AssetLib::Output::Content;

use Moo;
use Types::Standard qw/Str/;

extends 'Web::AssetLib::Output';

has 'content' => (
    is       => 'rw',
    isa      => Str,
    required => 1
);

1;