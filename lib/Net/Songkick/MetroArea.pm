package Net::Songkick::MetroArea;

use strict;
use warnings;

use Moose;

use Net::Songkick::Country;

has $_ => (
    is => 'ro',
    isa => 'Str',
) for qw[id displayName];

has 'country' => (
    is => 'ro',
    isa => 'Net::Songkick::Country',
);

sub new_from_xml {
    my $class = shift;
    my ($xml) = @_;

    my $self = {};

    foreach (qw[id displayName]) {
        $self->{$_} = $xml->findvalue("\@$_");
    }

    $self->{country} = Net::Songkick::Country->new_from_xml(
        ($xml->findnodes('country'))[0]
    );

    return $class->new($self);
}

1;
