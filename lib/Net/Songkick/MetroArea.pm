=head1 NAME

Net::Songkick::Event - Models a metropolitan area in the Songkick API

=cut

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

=head1 METHODS

=head2 Net::Songkick::MetroArea->new_from_xml

Creates a new Net::Songkick::MetroArea object from an XML::Element object that
has been created from an <metroArea> ... </metroArea> element in the XML
returned from a Songkick API request.

=cut

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
