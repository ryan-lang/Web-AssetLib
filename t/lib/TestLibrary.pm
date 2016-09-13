package TestLibrary;

use Method::Signatures;
use Moose;
use FindBin qw($Bin);

use Web::AssetLib::InputEngine::LocalFile;
use Web::AssetLib::MinifierEngine::Standard;
use Web::AssetLib::OutputEngine::LocalFile;

extends 'Web::AssetLib::Library';

has '+input_engines' => (
    default => sub {
        [   Web::AssetLib::InputEngine::LocalFile->new(
                search_paths => ["$Bin/assets/"]
            )
        ];
    }
);

has '+minifier_engines' => (
    default => sub {
        [ Web::AssetLib::MinifierEngine::Standard->new() ];
    }
);

has '+output_engines' => (
    default => sub {
        [   Web::AssetLib::OutputEngine::LocalFile->new(
                output_path => "$Bin/output/",
                html_path   => '/static/'
            )
        ];
    }
);

sub testjs {
    return Web::AssetLib::Asset->new(
        name         => 'testjs',
        type         => 'javascript',
        input_engine => 'LocalFile',
        input_args   => { path => 'test.js', }
    );
}

sub testcss {
    return Web::AssetLib::Asset->new(
        name         => 'testcss',
        type         => 'css',
        input_engine => 'LocalFile',
        input_args   => { path => 'test.css', }
    );
}

1;
