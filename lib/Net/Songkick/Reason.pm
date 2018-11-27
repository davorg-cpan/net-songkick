=head1 NAME

Net::Songkick::Reason - Models a metropolitan area in the Songkick API

=cut

package Net::Songkick::Reason;

use strict;
use warnings;

use Moose;
use Moose::Util::TypeConstraints;

use Net::Songkick::Artist;

coerce 'Net::Songkick::Reason',
  from 'HashRef',
  via { Net::Songkick::Reason->new($_) };

has $_ => (
    is => 'ro',
    isa => 'Str',
) for qw[attendance];

has trackedArtist => (
    is => 'ro',
    isa => 'ArrayRef[Net::Songkick::Artist]',
);

no Moose;
__PACKAGE__->meta->make_immutable;

=head1 AUTHOR

Dave Cross <dave@mag-sol.com>

=head1 SEE ALSO

perl(1), L<http://www.songkick.com/>, L<http://developer.songkick.com/>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2018, Magnum Solutions Ltd.  All Rights Reserved.

This script is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut

1;
