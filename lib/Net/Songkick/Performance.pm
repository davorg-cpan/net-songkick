=head1 NAME

Net::Songkick::Performance - Models a performance in the Songkick API

=cut

package Net::Songkick::Performance;

use strict;
use warnings;
use Moose;

use Net::Songkick::Artist;

has $_ => (
    is => 'ro',
    isa => 'Str',
) for qw[displayName billing billingIndex id];

has artist => (
    is => 'ro',
    isa => 'Net::Songkick::Artist',
);

=head1 METHODS

=head2 Net::Songkick::Performance->new_from_xml

Creates a new Net::Songkick::Performance object from an XML::Element object
that has been created from a <performance> ... </performance> element in the
XML returned from a Songkick API request.

=cut

sub new_from_xml {
    my $class = shift;
    my ($xml) = @_;

    my $self = {};

    for (qw[displayName billing billingIndex id]) {
        $self->{$_} = $xml->findvalue("\@$_");
    }

    $self->{artist} = Net::Songkick::Artist->new_from_xml(
        ($xml->findnodes('artist'))[0]
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
