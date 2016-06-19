=head1 NAME

Net::Songkick::Venue - Models a venue in the Songkick API

=cut

package Net::Songkick::Venue;

use strict;
use warnings;

use Moose;
use Moose::Util::TypeConstraints;

use Net::Songkick::MetroArea;

coerce 'Net::Songkick::Venue',
  from 'HashRef',
  via { Net::Songkick::Venue->new($_) };

has $_ => (
    is => 'ro',
    isa => 'Str',
) for qw[uri lat id lng displayName];

has metroArea => (
    is => 'ro',
    isa => 'Net::Songkick::MetroArea',
    coerce => 1,
);

# Backwards compatibility
sub metro_area { return $_[0]->metroArea }

=head1 METHODS

=head2 Net::Songkick::Venue->new_from_xml

Creates a new Net::Songkick::Venue object from an XML::Element object that
has been created from an <venue> ... </venue> element in the XML returned
from a Songkick API request.

=cut

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
