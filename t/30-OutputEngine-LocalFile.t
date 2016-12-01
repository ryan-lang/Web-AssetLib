
my $test = unit_test->new();
$test->main();

BEGIN {

    package unit_test;

    use Moose;
    use Test::Most qw(no_plan -Test::Deep);
    use Try::Tiny;
    use FindBin qw($Bin);
    use lib "$Bin/lib";
    use Carp;

    use Web::AssetLib::Bundle;
    use TestLibrary;

    with qw/TestRole/;

    sub do_tests {
        my ($self) = @_;

        my $library = TestLibrary->new();

        lives_ok {
            my $bundle = Web::AssetLib::Bundle->new();

            $bundle->addAsset( $library->testjs_remote );
            $bundle->addAsset( $library->testcss_remote );

            $library->compile( output_engine => 'LocalFile', bundle => $bundle );

            my $js  = $bundle->as_html( type => 'js' );
            my $css = $bundle->as_html( type => 'css' );

            $self->log->info($js);
            $self->log->info($css);
        }
        "exports bundle using LocalFile output engine";

    }

    1;
}
