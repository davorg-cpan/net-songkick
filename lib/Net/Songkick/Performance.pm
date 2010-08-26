package Net::Songkick::Performance;

use strict;
use warnings;
use Moose;

has $_ => (
    is => 'ro',
    isa => 'Str',
) for qw[displayName billing billingIndex id];

has artist => (
    is => 'ro',
    isa => 'Net::Songkick::Artist',
);

sub new_from_xml {
    my $class = shift;
    my ($xml) = @_;

    my $self = {};

    for (qw[displayName billing billingIndex id]) {
        $self->{$_} = $xml->findvalue("\@$_");
    }

    return $class->new($self);
}

1;
