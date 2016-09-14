package Web::AssetLib::InputEngine::Content;

use Method::Signatures;
use Moose;
use Carp;
use Digest::MD5 'md5_hex';

extends 'Web::AssetLib::InputEngine';

method load ($asset!) {
    croak sprintf( "%s requires 'content' asset input_arg", ref($self) )
        unless $asset->input_args->{content};

    my $contents = $asset->input_args->{content};

    $contents =~ s/^<script type="text\/javascript">//g;
    $contents =~ s/<\/script>$//g;

    my $digest = md5_hex $contents;
    $self->addAssetToCache( $digest => $contents );

    $asset->set_digest($digest);
    $asset->set_contents($contents);
}

no Moose;
1;
