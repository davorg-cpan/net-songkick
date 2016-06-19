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