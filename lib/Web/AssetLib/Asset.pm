package Web::AssetLib::Asset;

use Moose;
use MooseX::Aliases;
use Data::Dumper;
use Digest::MD5 'md5_hex';

has 'fingerprint' => (
    is      => 'rw',
    isa     => 'Str',
    lazy    => 1,
    default => sub {
        my $self = shift;
        local $Data::Dumper::Terse = 1;
        my $string = sprintf( '%s%s%s',
            $self->type, $self->input_engine, Dumper( $self->input_args ) );
        $string =~ s/\s//g;
        return md5_hex $string;
    }
);

has 'rank' => (
    is      => 'rw',
    isa     => 'Num',
    default => 0
);

# javascript, css
has 'type' => (
    is       => 'rw',
    isa      => 'Str',
    required => 1
);

# the engine that knows what to do
has 'input_engine' => (
    is      => 'rw',
    isa     => 'Str',
    default => 'LocalFile'
);

has 'input_args' => (
    is      => 'rw',
    isa     => 'HashRef',
    default => sub { {} }
);

# private attrs:

has 'contents' => (
    is     => 'ro',
    isa    => 'Str',
    writer => 'set_contents'
);

has 'digest' => (
    is     => 'ro',
    isa    => 'Str',
    writer => 'set_digest'
);

has 'html_link' => (
    is    => 'rw',
    isa   => 'Str',
    alias => 'as_html'
);

no Moose;

1;
