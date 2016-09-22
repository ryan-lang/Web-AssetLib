package Web::AssetLib::OutputEngine::LocalFile;

use Method::Signatures;
use Moose;
use Carp;

use Web::AssetLib::Util;

use Path::Tiny;

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

method _exportByType (:$assets!, :$type!, :$minifier?) {

    my ( $output_contents, $digest ) = $self->_concatAssets($assets);
    my $filename    = "$digest.$type";
    my $output_path = path( $self->output_path )->child($filename);
    my $link_path   = path( $self->link_path )->child($filename);

# # output pre-minify
# my $output_path_debug = path( $self->output_path )->child($filename.".orig.$type");
# unless($output_path_debug->exists){
#     $output_path_debug->touchpath;
#     $output_path_debug->spew_utf8($output_contents);
# }

    unless ( $output_path->exists ) {
        $output_path->touchpath;

        if ($minifier) {
            $output_contents = $minifier->minify(
                contents => $output_contents,
                type     => $type
            );
        }

        $output_path->spew_raw($output_contents);
    }

    return $self->generateHtmlTag( src => $link_path, type => $type );
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
