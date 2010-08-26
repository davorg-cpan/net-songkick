=head1 NAME

Net::Songkick::SetList - Models a set list in the Songkick API

=cut

package Net::Songkick::SetList;

use strict;
use warnings;

use Moose;

use Net::Songkick::Artist;
use Net::Songkick::SetListItem;

has $_ => (
  is => 'ro',
  isa => 'Str',
) for qw[displayName id];

has artist => (
  is => 'ro',
  isa => 'Net::Songkick::Artist',
);

has setlist_items => (
  is => 'ro',
  isa => 'ArrayRef[Net::Songkick::SetListItem]',
);

=head1 METHODS

=head2 Net::Songkick::SetList->new_from_xml

Creates a new Net::Songkick::SetList object from an XML::Element object that
has been created from a <setlist> ... </setlist> element in the XML returned
from a Songkick API request.

=cut

sub new_from_xml {
  my $class = shift;
  my ($xml) = @_;

  my $self = {};

  foreach (qw[displayName id]) {
    $self->{$_} = $xml->findvalue("\@$_");
  }

  $self->{artist} = Net::Songkick::Artist->new_from_xml(
    ($xml->findnodes('artist'))[0]
);

  foreach ($xml->findnodes('setlistItem')) {
    push @{$self->{setlist_items}},
        Net::Songkick::SetListItem->new_from_xml($_);
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
