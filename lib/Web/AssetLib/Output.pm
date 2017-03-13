package Web::AssetLib::Output;

use Moo;
use Types::Standard qw/Str HashRef/;

has 'type' => (
    is  => 'rw',
    isa => Str
);

has 'default_html_attrs' => (
    is      => 'rw',
    isa     => HashRef,
    default => sub { {} }
);

1;
