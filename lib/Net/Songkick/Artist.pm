=head1 NAME

Net::Songkick::Artist - Models an artist in the Songkick API

=cut

package Net::Songkick::Artist;

use strict;
use warnings;

use Moose;

has $_ => (
    is => 'ro',
    isa => 'Str',
) for qw[id displayName];

=head1 METHODS

=head2 Net::Songkick::Artist->new_from_xml

Creates a new Net::Songkick::Artist object from an XML::Element object that
has been created from an <artist> ... </artist> element in the XML returned
from a Songkick API request.

=cut

sub new_from_xml {
    my $class = shift;
    my ($xml) = @_;

    my $self = {};

    foreach (qw[id displayName]) {
        $self->{$_} = $xml->findvalue("\@$_");
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
