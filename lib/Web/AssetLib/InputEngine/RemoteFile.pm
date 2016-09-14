package Web::AssetLib::InputEngine::RemoteFile;

use Method::Signatures;
use Moose;
use Carp;

use HTTP::Request;
use LWP::UserAgent;
use Digest::MD5 'md5_hex';

use Path::Tiny;

extends 'Web::AssetLib::InputEngine';

has 'ua' => (
    is         => 'rw',
    isa        => 'LWP::UserAgent',
    lazy_build => 1
);

method _build_ua () {
    my $ua = LWP::UserAgent->new;
    return $ua;
}

method load ($asset!) {
    croak sprintf( "%s requires 'url' asset input_arg", ref($self) )
        unless $asset->input_args->{url};

    my $request = $self->buildRequest( url => $asset->input_args->{url} );
    my $contents = $self->doRequest( request => $request );

    my $digest = md5_hex $contents;
    $self->addAssetToCache( $digest => $contents );

    $asset->set_digest($digest);
    $asset->set_contents($contents);
}

method buildRequest (:$url!) {
    return HTTP::Request->new( GET => $url );
}

method doRequest (:$request!) {
    my $res = $self->ua->request($request);
    if ( $res->code == 200 ) {
        return $res->decoded_content;
    }
    else {
        croak $res->decoded_content;
    }

}

no Moose;
1;
