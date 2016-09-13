package Web::AssetLib::Util;

use Method::Signatures;
use Moose;
use Carp;

my %TYPES = (
    js         => 'js',
    javascript => 'js',
    css        => 'css',
    stylesheet => 'css'
);

func normalizeType ($type!) {
    if ( my $normalized = $TYPES{$type} ) {
        return $normalized;
    }
    else {
        croak "could not map type '$type'";
    }
}

no Moose;
1;
