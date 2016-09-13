package Web::AssetLib::Asset;

use Moose;

has 'name' => (
    is  => 'rw',
    isa => 'Maybe[Str]'
);

has 'rank' => (
    is  => 'rw',
    isa => 'Maybe[Int]'
);

# javascript, css
has 'type' => (
    is       => 'rw',
    isa      => 'Str',
    required => 1
);

# the engine that knows what to do
has 'input_engine' => (
    is       => 'rw',
    isa      => 'Str',
    required => 1
);

has 'input_args' => (
    is      => 'rw',
    isa     => 'HashRef',
    default => sub { {} }
);

# private attrs:

has '_contents' => (
    is  => 'rw',
    isa => 'Str'
);

has '_digest' => (
    is  => 'rw',
    isa => 'Str'
);

has 'isMinified' => (
    is      => 'rw',
    isa     => 'Bool',
    default => 0
);

no Moose;

1;
