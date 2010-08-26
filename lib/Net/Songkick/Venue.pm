package Net::Songkick::Venue;

use strict;
use warnings;

use Moose;

use Net::Songkick::MetroArea;

has $_ => (
    is => 'ro',
    isa => 'Str',
) for qw[uri lat id lng displayName];

has metro_area => (
    is => 'ro',
    isa => 'Net::Songkick::MetroArea',
);

sub new_from_xml {
    my $class = shift;
    my ($xml) = @_;

    my $self = {};

    foreach (qw[uri lat id lng displayName]) {
        $self->{$_} = $xml->findvalue("\@$_");
    }

    $self->{metro_area} =
        Net::Songkick::MetroArea->new_from_xml(
            ($xml->findnodes('metroArea'))[0]
        );

    return $class->new($self);
}

1;
