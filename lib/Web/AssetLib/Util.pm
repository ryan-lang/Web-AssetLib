package Web::AssetLib::Util;

use Method::Signatures;
use Moose;
use Carp;

my %FILE_TYPES = (
    js         => 'js',
    javascript => 'js',
    css        => 'css',
    stylesheet => 'css'
);

my %MIME_TYPES = (
    js         => 'text/javascript',
    javascript => 'text/javascript',
    css        => 'text/css',
    stylesheet => 'text/css'
);

func normalizeFileType ($type!) {
    if ( my $normalized = $FILE_TYPES{$type} ) {
        return $normalized;
    }
    else {
        croak "could not map type '$type'";
    }
}

func normalizeMimeType ($type!) {
    if ( my $normalized = $MIME_TYPES{$type} ) {
        return $normalized;
    }
    else {
        croak "could not map type '$type'";
    }
}

no Moose;
1;
