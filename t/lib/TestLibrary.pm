package TestLibrary;

use Method::Signatures;
use Moose;
use FindBin qw($Bin);

use Web::AssetLib::InputEngine::LocalFile;
use Web::AssetLib::InputEngine::RemoteFile;

use Web::AssetLib::MinifierEngine::Standard;
use Web::AssetLib::OutputEngine::LocalFile;

extends 'Web::AssetLib::Library';

has '+input_engines' => (
    default => sub {
        [   Web::AssetLib::InputEngine::LocalFile->new(
                search_paths => ["$Bin/assets/"]
            ),
            Web::AssetLib::InputEngine::RemoteFile->new()
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
                link_path   => '/static/'
            )
        ];
    }
);

sub testjs_local {
    return Web::AssetLib::Asset->new(
        name         => 'testjs_local',
        type         => 'javascript',
        input_engine => 'LocalFile',
        input_args   => { path => 'test.js', }
    );
}

sub testcss_local {
    return Web::AssetLib::Asset->new(
        name         => 'testcss_local',
        type         => 'css',
        input_engine => 'LocalFile',
        input_args   => { path => 'test.css', }
    );
}

sub testjs_remote {
    return Web::AssetLib::Asset->new(
        name         => 'testjs_remote',
        type         => 'javascript',
        input_engine => 'RemoteFile',
        input_args   => {
            url =>
                'https://ajax.googleapis.com/ajax/libs/jquery/3.1.0/jquery.min.js',
        }
    );
}

sub testcss_remote {
    return Web::AssetLib::Asset->new(
        name         => 'testcss_remote',
        type         => 'css',
        input_engine => 'RemoteFile',
        input_args   => {
            url =>
                'https://ajax.googleapis.com/ajax/libs/jquerymobile/1.4.5/jquery.mobile.min.css',
        }
    );
}

sub missingjs_remote {
    return Web::AssetLib::Asset->new(
        name         => 'missingjs_remote',
        type         => 'javascript',
        input_engine => 'RemoteFile',
        input_args   => { url => 'https://foo/bar', }
    );
}

1;
