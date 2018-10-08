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


$ua->map_response(
  qr{/search/artists} => HTTP::Response->new(
    200, 'OK', ['Content-Type' => 'application/json' ], '{
      "resultsPage": {
        "results": {
          "artist": [
            {
              "id":"253846",
              "uri":"http://www.songkick.com/artists/253846-radiohead",
              "displayName":"Radiohead",
              "onTourUntil":"2010-01-01",
              "identifier": [
                {
                  "href": "http://api.songkick.com/api/3.0/artists/mbid:a74b1b7f-71a5-4011-9441-d0b5e4122711.json",
                  "mbid": "a74b1b7f-71a5-4011-9441-d0b5e4122711"
                }
              ]
            }
          ]
        },
        "totalEntries":"1",
        "perPage":"50",
        "page":"1",
        "status":"ok"
      }
    }',
  ),
);

ok( my $artists = $ns->get_artists( {query => 'Radiohead'} ) );

isa_ok($artists, ref []);
is(@$artists, 1, 'Array has one element');
isa_ok($artists->[0], 'Net::Songkick::Artist');

my $artist = $artists->[0];

is($artist->id, '253846', 'Artist ID found');
is($artist->displayName, 'Radiohead', 'Artist displayName found');
isa_ok($artist->identifier->[0], 'Net::Songkick::MusicBrainz');
is( ''. $artist->onTourUntil,
   ''. DateTime::Format::Strptime->new(
        pattern => '%Y-%m-%d',
      )->parse_datetime('2010-01-01'),
   'Artist tour end date parsed');


$ua->map_response(
  qr{/artists/00000/similar_artists} => HTTP::Response->new(
    200, 'OK', ['Content-Type' => 'application/json' ], '{
      "resultsPage": {
        "results": {
          "artist": [
            {
              "displayName": "Gorillaz",
              "id": 68043,
              "identifier": [
                {
                  "eventsHref": "http://api.songkick.com/api/3.0/artists/mbid:e21857d5-3256-4547-afb3-4b6ded592596/calendar.json",
                  "href": "http://api.songkick.com/api/3.0/artists/mbid:e21857d5-3256-4547-afb3-4b6ded592596.json",
                  "mbid": "e21857d5-3256-4547-afb3-4b6ded592596"
                }
              ],
              "onTourUntil": null,
              "uri": "http://www.songkick.com/artists/68043-gorillaz?utm_source=1976&utm_medium=partner"
            }
          ]
        },
        "status": "ok",
        "perPage": 50,
        "page": 1,
        "totalEntries": 136
      }
    }',
  ),
);

ok( my $similar_artists = $ns->get_similar_artists( {artist_id => '00000'} ) );

isa_ok($similar_artists, ref []);
is(@$similar_artists, 1, 'Array has one element');
isa_ok($similar_artists->[0], 'Net::Songkick::Artist');

my $similar_artist = $similar_artists->[0];

is($similar_artist->id, '68043', 'Similar artist ID found');
is($similar_artist->displayName, 'Gorillaz', 'Similar artist displayName found');
isa_ok($similar_artist->identifier->[0], 'Net::Songkick::MusicBrainz');
is( $similar_artist->onTourUntil,
   ''. DateTime::Format::Strptime->new(
        pattern => '%Y-%m-%d',
      )->parse_datetime('1970-01-01'),
   'Similar artist tour end date parsed');








done_testing;
