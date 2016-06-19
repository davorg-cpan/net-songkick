=head1 NAME

Net::Songkick::Types - USeful type stuff for Net::Songkick

=head1 SYNOPSIS

  use Net::Songkick::Types;
  # This really won't be very useful outside of Net::Songkick.

=cut

package Net::Songkick::Types;

use Moose::Util::TypeConstraints;

use DateTime::Format::Strptime;

subtype 'Net::Songkick::DateTime',
  as 'DateTime';
  
coerce 'Net::Songkick::DateTime',
  from 'HashRef',
  via {
    if ($_) {
      DateTime::Format::Strptime->new(
        pattern => '%Y-%m-%d %H:%M:%S%z',
      )->parse_datetime($_);
    }
  };

1;

=head1 AUTHOR

Dave Cross <dave@perlhacks.com>

=head1 SEE ALSO

L<Net::Songkick>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2016, Magnum Solutions Ltd.  All Rights Reserved.

This script is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut

