package Net::Songkick::Country;

use strict;
use warnings;

use Moose;

has displayName => (
    is => 'ro',
    isa => 'Str',
);

sub new_from_xml {
    my $class = shift;
    my ($xml) = @_;

    my $self = {};

    $self->{displayName} = $xml->findvalue('@displayName');

    return $class->new($self);
}

1;
