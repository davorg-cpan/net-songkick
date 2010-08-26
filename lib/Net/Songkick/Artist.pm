package Net::Songkick::Artist;

use strict;
use warnings;

use Moose;

has $_ => (
    is => 'ro',
    isa => 'Str',
) for qw[id displayName];

sub new_from_xml {
    my $class = shift;
    my ($xml) = @_;

    my $self = {};

    foreach (qw[id displayName]) {
        $self->{$_} = $xml->findvalue("\@$_");
    }

    return $class->new($self);
}

1;
