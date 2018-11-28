use strict;
use warnings;
use Test::More;
use Test::LWP::UserAgent;
use HTTP::Response;

use Net::Songkick;
use Data::Dumper qw(Dumper);

my $ua = Test::LWP::UserAgent->new;

$ua->map_response(
  qr{/events[^/]} => HTTP::Response->new(
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

ok( my $events = $ns->get_events( {location => 'San Francisco'} ) );

isa_ok($events, ref []);
is(@$events, 1, 'Array has one element');
isa_ok($events->[0], 'Net::Songkick::Event');

my $event = $events->[0];

isa_ok($event->location,'Net::Songkick::Location');
is($event->location->city, 'San Francisco, CA, US', 'Event will take place in "San Francisco, CA, US"');
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

$ua->map_response(
  qr{/events/3037536} => HTTP::Response->new(
    200, 'OK', ['Content-Type' => 'application/json' ], '{
      "resultsPage": {
        "results": {
          "event": {
            "location": { "city":"London, UK", "lng":-0.1150322, "lat":51.4650846 },
            "popularity":0.526304,
            "uri":"http://www.songkick.com/concerts/3037536-vampire-weekend-at-o2-academy-brixton?utm_source=PARTNER_ID&utm_medium=partner",
            "displayName":"Vampire Weekend with Fan Death at O2 Academy Brixton (February 16, 2010)",
            "id":3037536,
            "type":"Concert",
            "start": { "time":"19:30:00", "date":"2010-02-16", "datetime":"2010-02-16T19:30:00+0000" },
            "ageRestriction": "14+",
            "performance":[
              {
                "artist": {
                  "uri":"http://www.songkick.com/artists/288696-vampire-weekend?utm_source=PARTNER_ID&utm_medium=partner",
                  "displayName":"Vampire Weekend",
                  "id":288696,
                  "identifier":[ { "href":"http://api.songkick.com/api/3.0/artists/mbid:af37c51c-0790-4a29-b995-456f98a6b8c9.json","mbid":"af37c51c-0790-4a29-b995-456f98a6b8c9" } ]
                },
                "displayName":"Vampire Weekend",
                "billingIndex":1,
                "id":5380281,
                "billing":"headline"
              },
              {
                "artist": {
                  "uri":"http://www.songkick.com/artists/2357033-fan-death?utm_source=PARTNER_ID&utm_medium=partner",
                  "displayName":"Fan Death",
                  "id":2357033,
                  "identifier": [ { "href":"http://api.songkick.com/api/3.0/artists/mbid:2ec79a0d-8b5d-4db2-ad6b-e91b90499e87.json","mbid":"2ec79a0d-8b5d-4db2-ad6b-e91b90499e87" } ]
                },
                "displayName":"Fan Death",
                "billingIndex":2,
                "id":7863371,
                "billing":
                "support"
              }
            ],
            "venue": {
              "metroArea": {
                "uri":"http://www.songkick.com/metro_areas/24426-uk-london?utm_source=PARTNER_ID&utm_medium=partner",
                "displayName":"London",
                "country": { "displayName":"UK" },
                "id":24426
              },
              "city": {
                "uri":"http://www.songkick.com/metro_areas/24426-uk-london?utm_source=PARTNER_ID&utm_medium=partner",
                "displayName":"London",
                "country": { "displayName":"UK" },
                "id":24426
               },
               "zip":"SW9 9SL",
               "lat":51.4650846,
               "lng":-0.1150322,
               "uri":"http://www.songkick.com/venues/17522-o2-academy-brixton?utm_source=PARTNER_ID&utm_medium=partner",
               "displayName":"O2 Academy Brixton",
               "street":"211 Stockwell Road",
               "id":17522,
               "website":"http://www.brixton-academy.co.uk/",
               "phone":"020 7771 3000",
               "capacity":4921,
               "description":"Brixton Academy is an award winning music venue situated in the heart of Brixton, South London. The venue has played host to many notable shows and reunions, welcoming a wide variety of artists, from Bob Dylan to Eminem, to the stage. It attracts over half a million visitors per year, accommodating over one hundred events.\n\nBuilt in 1929, the site started life as one of the four state of the art\n Astoria Theaters, screening a variety of motion pictures and shows. In 1972 the venue was transformed into a rock venue and re-branded as The Sundown Centre. With limited success the venue closed it’s doors in 1974 and was not re-opened as a music venue again until 1983, when it became The Brixton Academy.\n\nFeaturing a beautiful Art Deco interior, the venue is now known as the 02 Academy Brixton, and hosts a diverse range of club nights and live performances, as well as seated events. The venue has an upstairs balcony as well as the main floor downstairs. There is disabled access and facilities, a bar and a cloakroom. Club night events are for over 18s, for live music under 14s must be accompanied by an adult."
            },
            "status":"ok"
          }
        },
        "status":"ok"
      }
    }',
  ),
);

ok( my $single_event = $ns->get_event_details( {event_id => 3037536} ) );

isa_ok($single_event, ref []);
is(@$events, 1, 'Array has one element');
isa_ok($single_event->[0], 'Net::Songkick::Event');

my $eventdet = $single_event->[0];

is($eventdet->id, '3037536', 'Correct Vampire Weekend gig ID');
is($eventdet->type, 'Concert', 'Correct event type found');
is($eventdet->ageRestriction, '14+', 'No minors allowed at this gig');
isa_ok($event->location,'Net::Songkick::Location');
is($eventdet->location->city, 'London, UK', 'Gig is in London, UK');
isa_ok($eventdet->performance, ref []);
isa_ok($eventdet->performance->[0], 'Net::Songkick::Performance');
isa_ok($eventdet->performance->[0]->artist, 'Net::Songkick::Artist');
isa_ok($eventdet->performance->[0]->artist->identifier->[0], 'Net::Songkick::MusicBrainz');
isa_ok($eventdet->venue, 'Net::Songkick::Venue');
is($eventdet->venue->city->displayName, 'London', 'Gig venue is in London');
isa_ok($eventdet->venue->metroArea, 'Net::Songkick::MetroArea');
is($eventdet->venue->metroArea->id, '24426', 'Correct MetroArea found');
is($eventdet->venue->displayName, 'O2 Academy Brixton', 'Gig is at O2 Academy Brixton');


$ua->map_response(
  qr{/venues/17522} => HTTP::Response->new(
    200, 'OK', ['Content-Type' => 'application/json' ], '{
    "resultsPage": {
      "results": {
        "venue": {
          "id":17522,
          "displayName":"O2 Academy Brixton",
          "city": {
            "id":24426,
            "uri":"http://www.songkick.com/metro_areas/24426-uk-london",
            "displayName":"London",
            "country": { "displayName":"UK" }
          },
          "metroArea": {
            "id":24426,
            "uri":"http://www.songkick.com/metro_areas/24426-uk-london",
            "displayName":"London",
            "country": { "displayName":"UK" }
          },
          "uri":"http://www.songkick.com/venues/17522-o2-academy-brixton",
          "street":"211 Stockwell Road",
          "zip":"SW9 9SL",
          "lat":51.4651268,
          "lng":-0.115187,
          "phone":"020 7771 3000",
          "website":"http://www.brixton-academy.co.uk",
          "capacity":4921,
          "description": "Brixton Academy is an award winning music venue situated in the heart of Brixton, South London."
        }
      },
      "status": "ok"
      }
    }',
  ),
);

ok( my $venue = $ns->get_venue( { venue_id => 17522 } ) );

isa_ok($venue, ref []);
is(@$venue, 1, 'Array has one element');
isa_ok($venue->[0], 'Net::Songkick::Venue');

my $venuedet = $venue->[0];

is($venuedet->id, '17522', 'Correct Brixton Academy venue ID');
is($venuedet->displayName, 'O2 Academy Brixton', 'Venue is O2 Academy Brixton');
is($venuedet->street, '211 Stockwell Road', 'O2 Brixton Academy is at 211 Stockwell Road');
is($venuedet->city->displayName, 'London', 'O2 Brixton Academy is in London');
is($venuedet->metroArea->id, '24426', 'O2 Brixton Academy is in Metro Area 24426');
is($venuedet->city->country->displayName, 'UK', 'O2 Brixton Academy is in the UK');
is($venuedet->capacity, '4921', 'O2 Brixton Academy capacity is 4921');

$ua->map_response(
  qr{/venues[^/]} => HTTP::Response->new(
    200, 'OK', ['Content-Type' => 'application/json' ], '{
    "resultsPage": {
      "results": {
        "venue": [
          {
            "id":17522,
            "displayName":"O2 Academy Brixton",
            "city": {
              "id":24426,
              "uri":"http://www.songkick.com/metro_areas/24426-uk-london",
              "displayName":"London",
              "country": { "displayName":"UK" }
            },
            "metroArea": {
              "id":24426,
              "uri":"http://www.songkick.com/metro_areas/24426-uk-london",
              "displayName":"London",
              "country": { "displayName":"UK" }
            },
            "uri":"http://www.songkick.com/venues/17522-o2-academy-brixton",
            "street":"211 Stockwell Road",
            "zip":"SW9 9SL",
            "lat":51.4651268,
            "lng":-0.115187,
            "phone":"020 7771 3000",
            "website":"http://www.brixton-academy.co.uk",
            "capacity":4921,
            "description": "Brixton Academy is an award winning music venue situated in the heart of Brixton, South London."
          }
        ]
    },
    "totalEntries":1,
    "perPage":50,
    "page":1,
    "status":"ok"
  }
}',
  ),
);

ok( my $venues = $ns->get_venues( {query => 'O2 Brixton Academy'} ) );

isa_ok($venues, ref []);
is(@$venues, 1, 'Array has one element');
isa_ok($venues->[0], 'Net::Songkick::Venue');

my $venuesdet = $venues->[0];

is($venuesdet->id, '17522', 'Correct Brixton Academy venue ID');
is($venuesdet->displayName, 'O2 Academy Brixton', 'Venue is O2 Academy Brixton');
is($venuesdet->street, '211 Stockwell Road', 'O2 Brixton Academy is at 211 Stockwell Road');
is($venuesdet->city->displayName, 'London', 'O2 Brixton Academy is in London');
is($venuesdet->metroArea->id, '24426', 'O2 Brixton Academy is in Metro Area 24426');
is($venuesdet->city->country->displayName, 'UK', 'O2 Brixton Academy is in the UK');
is($venuesdet->capacity, '4921', 'O2 Brixton Academy capacity is 4921');


$ua->map_response(
  qr{/locations[^/]} => HTTP::Response->new(
    200, 'OK', ['Content-Type' => 'application/json' ], '{
    "resultsPage": {
      "results": {
        "location": [
          {
            "city": {
              "displayName":"London",
              "country": { "displayName":"UK" },
              "lng":-0.128,
              "lat":51.5078
            },
            "metroArea": {
              "id":24426,
              "uri":"http://www.songkick.com/metro_areas/24426-uk-london",
              "displayName":"London",
              "country":{"displayName":"UK"},
              "lng":-0.128,
              "lat":51.5078
            }
          },
          {
            "city": {
              "displayName":"London",
              "country":{"displayName":"US"},
              "lng":null,
              "lat":null,
              "state": { "displayName":"KY" }
            },
            "metroArea": {
              "id":24580,
              "uri":"http://www.songkick.com/metro_areas/24580",
              "displayName":"Lexington",
              "country": { "displayName":"US" },
              "lng":-84.4947,
              "lat":38.0297,
              "state": { "displayName":"KY" }
            }
          }
        ]
      },
      "totalEntries":2,
      "perPage":10,
      "page":1,
      "status":"ok"
    }
  }',
  ),
);

ok( my $locations = $ns->get_locations( {query => 'London'} ) ); 

isa_ok($locations, ref []);
is(@$locations, 2, 'Array has two elements');
isa_ok($locations->[0], 'Net::Songkick::Location');
isa_ok($locations->[1], 'Net::Songkick::Location');

my $londonuk = $locations->[0];
my $londonus = $locations->[1];

is($londonuk->city->displayName, 'London', 'Location result 1 is for London');
is($londonus->city->displayName, 'London', 'Location result 2 is for a different London');
is($londonuk->city->country->displayName, 'UK', 'There is a London in the UK');
is($londonuk->metroArea->id, '24426', 'London in the UK has its own Metro Area with ID = 24426');
is($londonus->city->country->displayName, 'US', 'There is a London in the US');
is($londonus->metroArea->id, '24580', 'London in the US is in the Metro Area with ID = 24580');
is($londonus->metroArea->displayName, 'Lexington', 'The Lexington Metro Area has ID = 24580 ');
is($londonus->city->state->displayName, 'KY', 'The London in the US is in Kentucky');

$ua->map_response(
  qr{/users/bob/calendar} => HTTP::Response->new(
    200, 'OK', ['Content-Type' => 'application/json' ], '{
      "resultsPage": {
        "results": {
          "calendarEntry": [
            {
              "reason": {
                "trackedArtist": [{
                  "uri":"http://www.songkick.com/artists/29835-wild-flag?utm_source=PARTNER_ID&utm_medium=partner",
                  "displayName":"Wild Flag",
                  "id":29835,
                  "identifier":[ { "mbid": "a74b1b7f-71a5-4011-9441-d0b5e4122711", "href": "http://blah.com"}]
                }],
                "attendance": "i_might_go|im_going"
              },
              "event": {
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
              }
            }
          ]
        }
      }
    }',
  ),
);

# TODO: Fix Event parsing when received as part of Calendar entry
ok( my $calendar = $ns->get_upcoming_calendar( { user => 'bob', reason => 'attendance'} ) );

isa_ok($calendar, 'Net::Songkick::Calendar');
isa_ok($calendar->calendarEntries, ref []);
is(@{ $calendar->calendarEntries }, 1, 'calendarEntry array has one element');
isa_ok($calendar->calendarEntries->[0], 'Net::Songkick::CalendarEntry');

my $centry = $calendar->calendarEntries->[0];

isa_ok($centry->reason, 'Net::Songkick::Reason');
is($centry->reason->attendance, 'i_might_go|im_going', 'Calendar entry has expected attendance attribute');
isa_ok($centry->reason->trackedArtist->[0], 'Net::Songkick::Artist');
isa_ok($centry->event, 'Net::Songkick::Event');

$ua->map_response(
  qr{/users/bob/metro_areas/tracked} => HTTP::Response->new(
    200, 'OK', ['Content-Type' => 'application/json' ], '{
      "resultsPage": {
        "results": {
          "metroArea": [
            {
              "uri":"http://www.songkick.com/metro_areas/26330-us-sf-bay-area?utm_source=PARTNER_ID&utm_medium=partner",
              "displayName":"SF Bay Area",
              "country": { "displayName":"US" },
              "id":26330,
              "state": { "displayName":"CA" }
            },
            {
              "uri":"http://www.songkick.com/metro_areas/24426-uk-london?utm_source=PARTNER_ID&utm_medium=partner",
              "displayName":"London",
              "country": { "displayName":"UK" },
              "id":24426
            },
            {
              "id":24580,
              "uri":"http://www.songkick.com/metro_areas/24580",
              "displayName":"Lexington",
              "country": { "displayName":"US" },
              "lng":-84.4947,
              "lat":38.0297,
              "state": { "displayName":"KY" }              
            }
          ]
        }
      },
      "status": "ok",
      "page": 1,
      "totalEntries": 3,
      "perPage": 50
    }',
  ),
);

ok( my $tracked_metro = $ns->get_tracked( { user => 'bob', tracked => 'metro_areas'} ) );

isa_ok($tracked_metro, ref []);
is(@$tracked_metro, 3, 'Tracked MetroArea array has 3 elements');
isa_ok($tracked_metro->[0], 'Net::Songkick::MetroArea');
isa_ok($tracked_metro->[1], 'Net::Songkick::MetroArea');
isa_ok($tracked_metro->[2], 'Net::Songkick::MetroArea');

$ua->map_response(
  qr{/users/bob/artists/tracked} => HTTP::Response->new(
    200, 'OK', ['Content-Type' => 'application/json' ], '{
      "resultsPage": {
        "results": {
          "artist": [
            {
              "uri":"http://www.songkick.com/artists/29835-wild-flag?utm_source=PARTNER_ID&utm_medium=partner",
              "displayName":"Wild Flag",
              "id":29835,
              "identifier":[ { "mbid": "a74b1b7f-71a5-4011-9441-d0b5e4122711", "href": "http://blah.com"}]
            },
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
            }          ]
        }
      },
      "status": "ok",
      "page": 1,
      "totalEntries": 2,
      "perPage": 50
    }',
  ),
);

ok( my $tracked_artists = $ns->get_tracked( { user => 'bob', tracked => 'artists'} ) );

isa_ok($tracked_artists, ref []);
is(@$tracked_artists, 2, 'Tracked Artist array has 2 elements');
isa_ok($tracked_artists->[0], 'Net::Songkick::Artist');
isa_ok($tracked_artists->[1], 'Net::Songkick::Artist');


$ua->map_response(
  qr{/users/bob/artists/muted} => HTTP::Response->new(
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
        }
      },
      "status": "ok",
      "page": 1,
      "totalEntries": 1,
      "perPage": 50
    }',
  ),
);

ok( my $muted_artists = $ns->get_muted( { user => 'bob', thing => 'artists'} ) );

isa_ok($muted_artists, ref []);
is(@$muted_artists, 1, 'Muted Artist array has 1 element');
isa_ok($muted_artists->[0], 'Net::Songkick::Artist');


$ua->map_response(
  qr{/users/bob/trackings/artist:29835} => HTTP::Response->new(
    200, 'OK', ['Content-Type' => 'application/json' ], '{
      "resultsPage": {
        "results": {
          "artist": [
            {
              "uri":"http://www.songkick.com/artists/29835-wild-flag?utm_source=PARTNER_ID&utm_medium=partner",
              "displayName":"Wild Flag",
              "id":29835,
              "identifier":[ { "mbid": "a74b1b7f-71a5-4011-9441-d0b5e4122711", "href": "http://blah.com"}]
            }
          ]
        }
      },
      "status": "ok",
      "page": 1,
      "totalEntries": 1,
      "perPage": 50
    }',
  ),
);

$ua->map_response(
  qr{/users/bob/trackings/artist:00000} =>
    HTTP::Response->new(404, 'NOT FOUND'),
);

ok( my $tracked_artist_true = $ns->get_tracking( { user => 'bob', artist_id => '29835'} ) );
isa_ok($tracked_artist_true, ref []);
is(@$tracked_artist_true, 1, 'Tracked Artist array has one element');
isa_ok($tracked_artist_true->[0], 'Net::Songkick::Artist');

ok( !defined (my $tracked_artist_false = $ns->get_tracking( { user => 'bob', artist_id => '00000'} ) ) );

$ua->map_response(
  qr{/users/bob/trackings/event:11129128} => HTTP::Response->new(
    200, 'OK', ['Content-Type' => 'application/json' ], '{
      "resultsPage": {
        "results": {
          "event": [
            {
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
            }
          ]
        }
      },
      "status": "ok",
      "page": 1,
      "totalEntries": 1,
      "perPage": 50
    }',
  ),
);

$ua->map_response(
  qr{/users/bob/trackings/event:00000000} =>
    HTTP::Response->new(404, 'NOT FOUND'),
);

ok( my $tracked_event_true = $ns->get_tracking( { user => 'bob', event_id => '11129128'} ) );
isa_ok($tracked_event_true, ref []);
is(@$tracked_event_true, 1, 'Tracked Event array has one element');
isa_ok($tracked_event_true->[0], 'Net::Songkick::Event');

ok( !defined (my $tracked_event_false = $ns->get_tracking( { user => 'bob', event_id => '00000000'} ) ) );

$ua->map_response(
  qr{/users/bob/trackings/metro_area:24426} => HTTP::Response->new(
    200, 'OK', ['Content-Type' => 'application/json' ], '{
      "resultsPage": {
        "results": {
          "metroArea": [
            {
              "id":24426,
              "uri":"http://www.songkick.com/metro_areas/24426-uk-london",
              "displayName":"London",
              "country":{"displayName":"UK"},
              "lng":-0.128,
              "lat":51.5078
            }
          ]
        }
      },
      "status": "ok",
      "page": 1,
      "totalEntries": 1,
      "perPage": 50
    }',
  ),
);

$ua->map_response(
  qr{/users/bob/trackings/metro_area:00000} =>
    HTTP::Response->new(404, 'NOT FOUND'),
);


ok( my $tracked_metro_true = $ns->get_tracking( { user => 'bob', metro_area_id => '24426'} ) );
isa_ok($tracked_metro_true, ref []);
is(@$tracked_metro_true, 1, 'Tracked MetroArea array has one element');
isa_ok($tracked_metro_true->[0], 'Net::Songkick::MetroArea');

ok( !defined (my $tracked_metro_false = $ns->get_tracking( { user => 'bob', metro_area_id => '00000'} ) ) );



done_testing;
