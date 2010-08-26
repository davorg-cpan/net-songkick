=head1 NAME

Net::Songkick::Event - Models an event in the Songkick API

=cut

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

=head1 METHODS

=head2 Net::Songkick::Event->new_from_xml

Creates a new Net::Songkick::Event object from an XML::Element object that
has been created from an <event> ... </event> element in the XML returned
from a Songkick API request.

=cut

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

=head1 AUTHOR

Dave Cross <dave@mag-sol.com>

=head1 SEE ALSO

perl(1), L<http://www.songkick.com/>, L<http://developer.songkick.com/>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2010, Magnum Solutions Ltd.  All Rights Reserved.

This script is free software; you can redistribute it and/or modify it
under the same terms as Perl itself. 

=cut

1;
