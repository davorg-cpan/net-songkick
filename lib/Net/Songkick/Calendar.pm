=head1 NAME

Net::Songkick::Calendar - Models a metropolitan area in the Songkick API

=cut

package Net::Songkick::Calendar;

use strict;
use warnings;

use Moose;
use Moose::Util::TypeConstraints;

use Data::Dumper;

use Net::Songkick::CalendarEntry;

subtype 'Net::Songkick::CalendarEntries'
  => as 'ArrayRef[Net::Songkick::CalendarEntry]';

coerce 'Net::Songkick::Calendar',
  from 'HashRef',
  via {
    warn "In coerce\n";
    warn Dumper @_;
    my $obj = Net::Songkick::Calendar->new( calendarEntries => [ $_ ] );
    warn Dumper $obj;
    return $obj;
  };

coerce 'Net::Songkick::CalendarEntries',
  from 'ArrayRef',
  via {
    my $cal = $_;
    [ map { Net::Songkick::CalendarEntry->new($_) } @$cal ];
  };

has 'calendarEntries' => (
    is => 'ro',
    isa => 'Net::Songkick::CalendarEntries',
    coerce => 1,
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
