=head1 NAME

Net::Songkick::Calendar - Models a metropolitan area in the Songkick API

=cut

package Net::Songkick::Calendar;

use strict;
use warnings;

use Moose;
use Moose::Util::TypeConstraints;

use Net::Songkick::Event;
use Net::Songkick::Reason;

coerce 'Net::Songkick::Calendar',
  from 'HashRef',
  via { Net::Songkick::Calendar->new($_) };


has 'reason' => (
    is => 'ro',
    isa => 'Net::Songkick::Reason',
    coerce => 1,
);

has 'event' => (
    is => 'ro',
    isa => 'Net::Songkick::Event',
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
