use Test::More;
use Test::LWP::UserAgent;
use HTTP::Response;

use Net::Songkick;

my $ua = Test::LWP::UserAgent->new;

$ua->map_response(
  qr{/events} => HTTP::Response->new(
    200, 'OK', ['Content-Type' => 'application/json' ], '{
  "resultsPage": {
    "page": 1,
    "totalEntries": 2,
    "perPage": 50,
    "results": {
      "event": [{
        "displayName": "Vampire Weekend at O2 Academy Brixton (February 16, 2010)",
        "type": "Concert",
        "uri": "http://www.songkick.com/concerts/3037536-vampire-weekend-at-o2-academy-brixton?utm_medium=partner&utm_source=PARTNER_ID",
        "venue": {
          "lng": -0.1187418,
          "displayName": "O2 Academy Brixton",
          "lat": 51.4681089,
          "id": 17522
        },
        "location": {
          "lng": -0.1187418,
          "city": "London, UK",
          "lat": 51.4681089
        },
        "start": {
          "time": "19:30:00",
          "date": "2010-02-16",
          "datetime": "2010-02-16T19:30:00+0000"
        },
        "performance": [{
          "artist": {
            "uri": "http://www.songkick.com/artists/288696-vampire-weekend",
            "displayName": "Vampire Weekend",
            "id": 288696,
            "identifier": [{"mbid": "af37c51c-0790-4a29-b995-456f98a6b8c9"}]
          },
          "displayName": "Vampire Weekend",
          "billingIndex": 1,
          "id": 5380281,
          "billing": "headline"
        }],
        "id": 3037536
      }]
    }
  }
}',
  ),
);

my $ns = Net::Songkick->new({
    api_key => 'dummy',
    ua      => $ua,
});

ok(my $events = $ns->get_events);

isa_ok($events, ref []);
is(@$events, 1, 'Array has one element');
isa_ok($events->[0], 'Net::Songkick::Event');

my $event = $events->[0];

isa_ok($event->location,'Net::Songkick::Location');
isa_ok($event->performance, ref []);
isa_ok($event->performance->[0], 'Net::Songkick::Performance');
isa_ok($event->venue, 'Net::Songkick::Venue');

done_testing;
