
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

        my $bundle;
        lives_ok {
            $bundle = Web::AssetLib::Bundle->new();

            $bundle->addAsset( $library->testjs );
            $bundle->addAsset( $library->testcss );
        }
        "creates bundle and adds assets";

        lives_ok {
            my $output = $library->compile(
                bundle          => $bundle,
                minifier_engine => 'Standard'
            );
            $self->log->dump( 'bundle=', $output, 'info' );
        }
        "compiles bundle";

        lives_ok {
            $bundle = Web::AssetLib::Bundle->new();

            $bundle->addAsset( $library->testjs );
            $bundle->addAsset( $library->testcss );
            $bundle->addAsset( $library->testcss );

            my $output = $library->compile(
                bundle          => $bundle,
                minifier_engine => 'Standard'
            );
            $self->log->dump( 'bundle=', $output, 'info' );
        }
        "prevents adding same asset twice";
    }

    1;
}
