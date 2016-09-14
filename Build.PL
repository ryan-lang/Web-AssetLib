use strict;
use warnings;
use Module::Build::Pluggable ('CPANfile');

my $builder = Module::Build::Pluggable->new(
    module_name       => 'Web-AssetLib',
    license           => 'perl',
    dist_author       => 'Ryan Lang',
    dist_version_from => 'lib/Web/AssetLib.pm',
    dist_abstract     => "Library manager for compiling and serving static assets"
);

$builder->create_build_script();
