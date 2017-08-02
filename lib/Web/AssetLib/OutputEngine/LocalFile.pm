package Web::AssetLib::OutputEngine::LocalFile;

use Method::Signatures;
use Moose;
use Carp;

use Web::AssetLib::Util;
use Web::AssetLib::Output::Link;

use Path::Tiny;

use v5.14;
no if $] >= 5.018, warnings => "experimental";

extends 'Web::AssetLib::OutputEngine';

has 'output_path' => (
    is       => 'rw',
    isa      => 'Str',
    required => 1
);

# should correspond with the root of output_path
has 'link_path' => (
    is       => 'rw',
    isa      => 'Str',
    required => 1
);

# asset name will be [name].[hash].[type]
has 'prepend_asset_name' => (
    is      => 'rw',
    isa     => 'Bool',
    default => 1
);

method export (:$assets!, :$minifier?) {
    my $output = [];

    my $assets_by_type = $self->sortAssetsByType($assets);

    foreach my $type ( keys %$assets_by_type ) {
        foreach my $asset ( @{ $$assets_by_type{$type} } ) {

            my $contents = ref($asset) ? $asset->contents : $asset;
            my $name     = ref($asset) ? $asset->name     : 'bundle';
            my $digest
                = ref($asset)
                ? $asset->digest
                : $self->generateDigest($contents);

            my $filename    = "$name.$digest.$type";
            my $output_path = path( $self->output_path )->child($filename);
            my $link_path   = path( $self->link_path )->child($filename);

            unless ( $output_path->exists ) {
                $output_path->touchpath;

                if ( $minifier && ( ref($asset) ? !$asset->isPassthru : 1 ) )
                {
                    $contents = $minifier->minify(
                        contents => $contents,
                        type     => $type
                    );
                }

                $output_path->spew_utf8($contents);
            }

            push @$output,
                Web::AssetLib::Output::Link->new(
                src  => "$link_path",
                type => $type
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

Web::AssetLib::OutputEngine::LocalFile - allows exporting an asset or bundle to your local filesystem

=head1 SYNOPSIS

    my $library = My::AssetLib::Library->new(
        output_engines => [
            Web::AssetLib::OutputEngine::LocalFile->new(
                output_path => '/my/local/output/path',
                link_path => '/output/path/relative/to/webserver'
            )
        ]
    );

=head1 USAGE

Instantiate with C<< output_path >> and C<< link_path >> parameters, and include in your library's
output engine list.

=head1 ATTRIBUTES
 
=head2 output_path
 
String; the absolute path that the compiled assets should be exported to

=head2 link_path
 
String; the path relative to your webserver root, which points to the L<< /output_path >>.
Used in generating HTML tags.

=head1 SEE ALSO

L<Web::AssetLib::OutputEngine>

=head1 AUTHOR
 
Ryan Lang <rlang@cpan.org>

=cut
