package Web::AssetLib::OutputEngine::String;

use Method::Signatures;
use Moose;
use Carp;

use Web::AssetLib::Util;
use Web::AssetLib::Output::Link;
use Web::AssetLib::Output::Content;

use v5.14;
no if $] >= 5.018, warnings => "experimental";

extends 'Web::AssetLib::OutputEngine';

method export (:$assets!, :$minifier?) {
    my $output = [];

    my $assets_by_type = $self->sortAssetsByType($assets);

    foreach my $type ( keys %$assets_by_type ) {
        foreach my $asset ( @{ $$assets_by_type{$type} } ) {

            my $contents = ref($asset) ? $asset->contents : $asset;

            if ( $minifier && ( ref($asset) ? !$asset->isPassthru : 1 ) ) {
                $contents = $minifier->minify(
                    contents => $contents,
                    type     => $type
                );
            }

            push @$output,
                Web::AssetLib::Output::Content->new(
                type    => $type,
                content => $contents
                );
        }
    }

    return $output;
}

no Moose;
1;

=pod
 
=encoding UTF-8
 
=head1 NAME

Web::AssetLib::OutputEngine::String - allows exporting an asset or bundle to a string

=head1 SYNOPSIS

    my $library = My::AssetLib::Library->new(
        output_engines => [
            Web::AssetLib::OutputEngine::String->new()
        ]
    );

=head1 USAGE

Include in your library's output engine list.

=head1 SEE ALSO

L<Web::AssetLib::OutputEngine>

=head1 AUTHOR
 
Ryan Lang <rlang@cpan.org>

=cut
