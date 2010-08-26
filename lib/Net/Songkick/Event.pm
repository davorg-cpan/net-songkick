package Net::Songkick::Event;

use strict;
use warnings;

use Moose;
use DateTime::Format::Strptime;

use Net::Songkick::Location;
use Net::Songkick::Performance;
use Net::Songkick::Venue;

has $_ => (
    is => 'ro',
    isa => 'Str',
) for qw(type tickeetsUri status uri displayName popularity id);

has location => (
    is => 'ro',
    isa => 'Net::Songkick::Location',
);

has performances => (
    is => 'ro',
    isa => 'ArrayRef[Net::Songkick::Performance]',
);

has start => (
    is => 'ro',
    isa => 'DateTime',
);

has venue => (
    is => 'ro',
    isa => 'Net::Songkick::Venue',
);

sub new_from_xml {
    my $class = shift;
    my ($xml) = @_;

    my $self = {};

    foreach (qw[type ticketsURI status uri displayName popularity id]) {
        $self->{$_} = $xml->findvalue("\@$_");
    }

    $self->{location} = Net::Songkick::Location->new_from_xml(
        ($xml->findnodes('location'))[0]
    );

    my $start_date = $xml->findvalue('start/@date');
    my $start_time = $xml->findvalue('start/@time') || '00:00:00';

    if ($start_date) {
        my $p = DateTime::Format::Strptime->new(
            pattern => '%Y-%m-%d %H:%M:%S',
        );

        $self->{start} = $p->parse_datetime("$start_date $start_time");
    }

    $self->{venue} = Net::Songkick::Venue->new_from_xml(
        ($xml->findnodes('venue'))[0]
    );

    foreach ($xml->findnodes('performance')) {
        push @{$self->{performances}},
            Net::Songkick::Performance->new_from_xml($_);
    }

    return $class->new($self);
}

1;
