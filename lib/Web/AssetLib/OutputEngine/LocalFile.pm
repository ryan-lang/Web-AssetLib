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
