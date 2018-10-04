use strict;
use warnings;
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
        "id":11129128,
        "type":"Concert",
        "uri":"http://www.songkick.com/concerts/11129128-wild-flag-at-fillmore?utm_source=PARTNER_ID&utm_medium=partner",
        "displayName":"Wild Flag at The Fillmore (April 18, 2012)",
        "start": {
          "time":"20:00:00",
          "date":"2012-04-18",
          "datetime":"2012-04-18T20:00:00-0800"
        },
        "performance": [{
          "artist":{
              "uri":"http://www.songkick.com/artists/29835-wild-flag?utm_source=PARTNER_ID&utm_medium=partner",
              "displayName":"Wild Flag",
              "id":29835,
              "identifier":[ { "mbid": "a74b1b7f-71a5-4011-9441-d0b5e4122711", "href": "http://blah.com"}]
          },
          "id":21579303,
          "displayName":"Wild Flag",
          "billingIndex":1,
          "billing":"headline"
        }],
        "location": {
          "city":"San Francisco, CA, US",
          "lng":-122.4332937,
          "lat":37.7842398
        },
        "venue": {
          "id":6239,
          "displayName":"The Fillmore",
          "uri":"http://www.songkick.com/venues/6239-fillmore?utm_source=PARTNER_ID&utm_medium=partner",
          "lng":-122.4332937,
          "lat":37.7842398,
          "metroArea": {
            "uri":"http://www.songkick.com/metro_areas/26330-us-sf-bay-area?utm_source=PARTNER_ID&utm_medium=partner",
            "displayName":"SF Bay Area",
            "country": { "displayName":"US" },
            "id":26330,
            "state": { "displayName":"CA" }
          }
        },
        "status":"ok",
        "popularity":0.012763
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

ok( my $events = $ns->get_events( {location => 'London'} ) );

isa_ok($events, ref []);
is(@$events, 1, 'Array has one element');
isa_ok($events->[0], 'Net::Songkick::Event');

my $event = $events->[0];

isa_ok($event->location,'Net::Songkick::Location');
isa_ok($event->performance, ref []);
isa_ok($event->performance->[0], 'Net::Songkick::Performance');
isa_ok($event->performance->[0]->artist, 'Net::Songkick::Artist');
isa_ok($event->performance->[0]->artist->identifier->[0], 'Net::Songkick::MusicBrainz');
isa_ok($event->venue, 'Net::Songkick::Venue');
isa_ok($event->venue->metroArea, 'Net::Songkick::MetroArea');


done_testing;
