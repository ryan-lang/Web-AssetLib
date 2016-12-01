requires 'Moose';
requires 'Moo';
requires 'Types::Standard';
requires 'Method::Signatures';
requires 'Log::Log4perl';
requires 'MooseX::Log::Log4perl';
requires 'Data::Dump';
requires 'Path::Tiny';
requires 'HTML::Element';
requires 'MooseX::Aliases';

on 'test' => sub {
    requires 'Test::More', '0.98';
    requires 'Test::Compile';
    requires 'Test::Most';
};