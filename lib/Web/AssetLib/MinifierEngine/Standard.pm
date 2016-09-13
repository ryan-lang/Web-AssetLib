package Web::AssetLib::MinifierEngine::Standard;

use Method::Signatures;
use Moose;
use Carp;

use Web::AssetLib::Util;

use v5.14;
no if $] >= 5.018, warnings => "experimental";

extends 'Web::AssetLib::MinifierEngine';

has 'minifiers' => (
    is      => 'rw',
    isa     => 'HashRef',
    default => sub {
        my $self = shift;
        {   js => sub {
                my $minifier = \&{ $self->javascript_module . '::minify' };
                return $minifier->( $_[0] );
            },
            css => sub {
                my $minifier = \&{ $self->css_module . '::minify' };
                return $minifier->( $_[0] );
            }
        };
    }
);

has 'javascript_module' => (
    is         => 'rw',
    isa        => 'Str',
    lazy_build => 1,
);

has 'css_module' => (
    is         => 'rw',
    isa        => 'Str',
    lazy_build => 1,
);

method _build_css_module {
    return 'CSS::Minifier::XS' if $INC{'CSS/Minifier/XS.pm'};

    return 'CSS::Minifier::XS' if eval { require CSS::Minifier::XS; 1; };
    $self->log->warn(
        'installing CSS::Minifier::XS could yield better performance');
    return 'CSS::Minifier' if eval { require CSS::Minifier; 1 };
    croak
        "no css minifier found (requires CSS::Minifier::XS or CSS::Minifier)";
}

method _build_javascript_module {
    return 'JavaScript::Minifier::XS' if $INC{'JavaScript/Minifier/XS.pm'};

    return 'JavaScript::Minifier::XS'
        if eval { require JavaScript::Minifier::XS; 1; };
    $self->log->warn(
        'installing JavaScript::Minifier::XS could yield better performance');
    return 'JavaScript::Minifier' if eval { require JavaScript::Minifier; 1 };
    croak
        "no Javascript minifier found (requires JavaScript::Minifier::XS or JavaScript::Minifier)";
}

method minify (:$contents!,:$type!) {
    croak "type $type minifier not found" unless $self->minifiers->{$type};

    return $self->minifiers->{$type}->($contents);
}

no Moose;
1;
