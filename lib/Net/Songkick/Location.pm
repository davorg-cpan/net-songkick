=head1 NAME

Net::Songkick::Location - Models a location in the Songkick API

=cut

package Net::Songkick::Location;

use strict;
use warnings;

use Moose;

has $_ => (
    is => 'ro',
    isa => 'Str',
) for qw[lng lat city];

=head1 METHODS

=head2 Net::Songkick::Location->new_from_xml

Creates a new Net::Songkick::Location object from an XML::Element object that
has been created from a <location> ... </location> element in the XML returned
from a Songkick API request.

=cut


sub new_from_xml {
    my $class = shift;
    my ($xml) = @_;

    my $self = {};

    foreach (qw[lng lat city]) {
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
