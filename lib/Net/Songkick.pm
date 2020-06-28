=head1 NAME

Net::Songkick - Perl wrapper for the Songkick API

=head1 SYNOPSIS

  use Net::Songkick;

  my $api_key = 'your_api_key';
  my $sk = Net::Songkick->new({ api_key => $api_key });

  # Returns XML by default
  my $events = $sk->get_events;

  # Or returns JSON
  my $events = $sk->get_events({ format => 'json' });

=head1 DESCRIPTION

This module presents a Perl wrapper around the Songkick API.

Songkick (L<http://www.songkick.com/>) is a web site that tracks gigs
around the world. Users can add information about gigs (both in the past
and the future) and can track their attendance at those gigs.

For more details of the Songkick API see L<http://developer.songkick.com/>.

=head1 METHODS

=head2 Net::Songkick->new({ api_key => $api_key })

Creates a new object which can be used to request data from the Songkick
API. Requires one parameter which is the user's API key.

To request an API key from Songkick, see
L<http://www.songkick.com/api_keys/index>.

Returns a Net::Songkick object if successful.

=cut

package Net::Songkick;

use strict;
use warnings;

our $VERSION = '1.0.2';

use Moose;

use LWP::UserAgent;
use URI;
use JSON;

use Net::Songkick::Calendar;
use Net::Songkick::Event;

has api_key => (
  is => 'ro',
  isa => 'Str',
  required => 1,
);

has ua => (
  is => 'ro',
  isa => 'LWP::UserAgent',
  lazy_build => 1,
);

sub _build_ua {
  my $self = shift;

  return LWP::UserAgent->new;
}

has json_decoder => (
  is => 'ro',
  isa => 'JSON',
  lazy_build => 1,
);

sub _build_json_decoder {
  return JSON->new;
}

has ['api_format', 'return_format' ] => (
  is => 'ro',
  isa => 'Str',
  lazy_build => 1,
);

sub _build_api_format {
  my $format = $_[0]->return_format;
  $format = 'json' if $format eq 'perl';
  return $format;
}

sub _build_return_format {
  return 'perl';
}

has ['api_url', 'events_url', 'user_events_url', 'user_calendar_url',
     'user_gigs_url', 'user_tracked_url', 'user_muted_url',
     'user_trackings_url',
     'artists_url', 'artists_mb_url', 'artist_gigs_url',
     'artist_search_url', 'similar_artist_search_url',
     'venue_events_url', 'metro_url', 'event_details_url',
     'venue_details_url', 'venues_url', 'locations_url'] => (
  is => 'ro',
  isa => 'URI',
  lazy_build => 1,
);

sub _build_api_url {
  return URI->new('http://api.songkick.com/api/3.0');
}

sub _build_events_url {
  return URI->new(shift->api_url . '/events');
}

sub _build_user_events_url {
  return URI->new(shift->api_url . '/users/USERNAME/events');
}

sub _build_user_calendar_url {
  return URI->new(shift->api_url . '/users/USERNAME/calendar');
}

sub _build_user_gigs_url {
  return URI->new(shift->api_url . '/users/USERNAME/gigography');
}

sub _build_user_tracked_url {
  return URI->new(shift->api_url . '/users/USERNAME/THING/tracked');
}

sub _build_user_muted_url {
  return URI->new(shift->api_url . '/users/USERNAME/artists/muted');
}

sub _build_user_trackings_url {
  return URI->new(shift->api_url . '/users/USERNAME/trackings/TRACKEE');
}

sub _build_artists_url {
  return URI->new(shift->api_url . '/artists/ARTIST_ID/calendar');
}

sub _build_artists_mb_url {
  return URI->new(shift->api_url . '/artists/mbid:MB_ID/calendar');
}

sub _build_artist_gigs_url {
  return URI->new(shift->api_url . '/artists/ARTIST_ID/gigography');
}

sub _build_venue_events_url {
  return URI->new(shift->api_url . '/venues/VENUE_ID/calendar');
}

sub _build_metro_url {
  return URI->new(shift->api_url . '/metro/METRO_ID/calendar');
}

sub _build_artist_search_url {
  return URI->new(shift->api_url . '/search/artists');
}

sub _build_similar_artist_search_url {
  return URI->new(shift->api_url . '/artists/ARTIST_ID/similar_artists');
}

sub _build_event_details_url {
  return URI->new(shift->api_url . '/events/EVENT_ID');
}

sub _build_venue_details_url {
  return URI->new(shift->api_url . '/venues/VENUE_ID');
}

sub _build_venues_url {
  return URI->new(shift->api_url . '/venues');
}

sub _build_locations_url {
  return URI->new(shift->api_url . '/locations');
}

has ['events_params', 'user_events_params', 'user_calendar_params',
     'user_gigs_params', 'user_tracked_params', 'user_muted_params',
     'artist_events_params', 'artist_gigs_params',
     'artist_search_params', 'similar_artist_search_params',
     'venue_events_params', 'metro_events_params',
     'venues_params', 'locations_params'] => (
  is => 'ro',
  isa => 'HashRef',
  lazy_build => 1,
);

sub _build_events_params {
  my @params = qw(type artists artist_name artist_id venue_id
                  min_date max_date location page per_page);

  return { map { $_ => 1 } @params };
}

sub _build_user_events_params {
  my @params = qw[ attendance created_after page per_page order ];

  return { map { $_ => 1 } @params };
}

sub _build_user_calendar_params {
  my @params = qw[ created_after page per_page order ];

  return { map { $_ => 1 } @params };
}

sub _build_user_gigs_params {
  my @params = qw [ page per_page order];

  return { map { $_ => 1 } @params };
}

sub _build_user_tracked_params {
  my @params = qw[ page per_page fields created_after ];

  return { map { $_ => 1} @params };
}

sub _build_user_muted_params {
  my @params = qw[ page per_page fields ];

  return { map { $_ => 1} @params };
}

sub _build_artist_events_params {
  my @params = qw[ min_date max_date page per_page order ];

  return { map { $_ => 1} @params };
}

sub _build_artist_gigs_params {
  my @params = qw[ min_date max_date page per_page order ];

  return { map { $_ => 1} @params };
}

sub _build_venue_events_params {
  my @params = qw[ min_date max_date page per_page ];

  return { map { $_ => 1 } @params };
}

sub _build_metro_events_params {
  my @params = qw[ min_date max_date page per_page ];

  return { map { $_ => 1 } @params };
}

sub _build_artist_search_params {
  my @params = qw[ page per_page ];

  return { map { $_ => 1 } @params };
}

sub _build_similar_artist_search_params {
  my @params = qw[ page per_page ];

  return { map { $_ => 1 } @params };
}

sub _build_venues_params {
  my @params = qw[ page per_page ];

  return { map { $_ => 1 } @params };
}

sub _build_locations_params {
  my @params = qw[ page per_page query location ];

  return { map { $_ => 1 } @params };
}

has responses_handled => (
  is => 'ro',
  isa => 'HashRef',
  lazy_build => 1,
);

sub _build_responses_handled {
  return {
    artist    =>  'Net::Songkick::Artist',
    calendarEntry => 'Net::Songkick::Calendar',
    event     =>  'Net::Songkick::Event',
    location  => 'Net::Songkick::Location',
    metroArea =>  'Net::Songkick::MetroArea',
    venue     =>  'Net::Songkick::Venue',
  };
}

sub _request {
  my $self = shift;
  my ($url, $args) = @_;

  $args->{apikey} = $self->api_key;
  $url->query_form($args) if $args;

  my $resp = $self->ua->get($url);

  if ($resp->is_success) {
    return $resp->content;
  }

  # Tracking requests return may legitimately return 404
  if ($resp->is_error( '404' )) {
    return undef;
  }

  die $resp->content;
}

=head2 $sk->return_perl

Returns a Boolean value indicating whether or not this Net::Songkick
object should return Perl data structures for requests.

=cut

sub return_perl {
  return $_[0]->return_format eq 'perl';
}

=head2 $sk->parse_results_from_json($json_text)

Takes the JSON returns by a request for a list of events, parses the JSON
and returns a list of Net::Songkick::... objects.

=cut

sub parse_results_from_json {
  my $self = shift;
  my ($json) = @_;

  my @objects;
  my $data = $self->json_decoder->decode($json) || die "Failure parsing: ".Dumper($json);

  # Dump the two top levels of the JSON
  $data = $data->{resultsPage} if exists $data->{resultsPage};
  $data = $data->{results}     if exists $data->{results};

  # Ensure we have a recognised response key
  my $type = (keys %$data)[0];
  die "JSON response not recognised\n" unless exists $self->responses_handled->{ $type };

  # Ensure we have an array of events
  #$data->{$type} = [ $data->{$type} ] if ref $data->{$type} ne 'ARRAY';

  #foreach (@{$data->{$type}}) {
    push @objects, $self->responses_handled->{ $type }->new($_);
  #}

  return @objects;
}

=head2 $sk->get_events({ ... options ... });

Gets a list of upcoming events from Songkick. Various parameters to control
the events returned are supported; for the full list see
L<http://www.songkick.com/developer/event-search>.

In addition, this method takes an extra parameter, B<format>, which control
the format of the data returned. This can be either I<xml>, I<json> or
I<perl>. If it is either I<xml> or I<json> then the method will return the
raw XML or JSON from the Songkick API. If ii is I<perl> then this method
will return a list of L<Net::Songkick::Event> objects. If this parameter is
omitted, then I<perl> is assumed.

=cut

sub get_events {
  my $self = shift;
  my ($params) = @_;

  unless (exists $params->{artist_name} or exists $params->{location}) {
    die "One of artist_name or location must be specified"
  }

  my $url = URI->new($self->events_url . '.' . $self->api_format);

  my %req_args;

  foreach (keys %$params) {
    if ($self->events_params->{$_}) {
      $req_args{$_} = $params->{$_};
    }
  }

  my $resp = $self->_request($url, \%req_args);

  return $resp unless $self->return_perl;

  return wantarray ? $self->parse_results_from_json($resp)
                   : [ $self->parse_results_from_json($resp) ];
}

=head2 $sk->get_upcoming_events({ ... options ... });

Gets a list of upcoming events for a particular user from Songkick.

This method has optional parameters: B<attendance> to filter results based
upon user-flagged attendance, B<created_after> to filter out older events,
B<page> to control which page of the data you want to return, B<per_page>
to control the number of results to return in each page, and B<order> to
control date ordering.
See L<https://www.songkick.com/developer/upcoming-events-for-user> for details.

This method also supports the B<format> parameter.

This method has another, mandatory, parameter called B<user>. This is the
username of the user that you want information about.

=cut

sub get_upcoming_events {
  my $self = shift;

  my ($params) = @_;

  my $user;
  if (exists $params->{user}) {
    $user = delete $params->{user};
  } else {
    die "user not passed to get_past_events\n";
  }

  my $url = $self->user_events_url . '.' . $self->api_format;
  $url =~ s/USERNAME/$user/;
  $url = URI->new($url);

  my %req_args;

  foreach (keys %$params) {
    if ($self->user_events_params->{$_}) {
      $req_args{$_} = $params->{$_};
    }
  }

  my $resp = $self->_request($url, \%req_args);

  return $resp unless $self->return_perl;

  return wantarray ? $self->parse_results_from_json($resp)
                   : [ $self->parse_results_from_json($resp) ];
}

=head2 $sk->get_past_events({ ... options ... });

Gets a list of previously attended events (the "gigogaphy)" for a
particular user from Songkick.

This method has optional parameters: B<page> to control which page of
the data you want to return, B<per_page> to control the number of
results to return in each page, and B<order> to control date ordering.
See L<https://www.songkick.com/developer/past-events-for-user> for details.

This method also supports the B<format> parameter.

This method has another, mandatory, parameter called B<user>. This is the
username of the user that you want information about.

=cut

sub get_past_events {
  my $self = shift;

  my ($params) = @_;

  my $user;
  if (exists $params->{user}) {
    $user = delete $params->{user};
  } else {
    die "user not passed to get_past_events\n";
  }

  my $url = $self->user_gigs_url . '.' . $self->api_format;
  $url =~ s/USERNAME/$user/;
  $url = URI->new($url);

  my %req_args;

  foreach (keys %$params) {
    if ($self->user_gigs_params->{$_}) {
      $req_args{$_} = $params->{$_};
    }
  }

  my $resp = $self->_request($url, \%req_args);

  return $resp unless $self->return_perl;

  return wantarray ? $self->parse_results_from_json($resp)
                   : [ $self->parse_results_from_json($resp) ];
}

=head2 $sk->get_venue_events({ ... options ...});

Gets a list of upcoming events for a venue.

This method has optional parameters: B<min_date> and B<max_date> to control the
timeframe for upcoming events, B<page> to control which page of the data you
want to return, B<per_page> to control the number of results to return in each page.
See L<https://www.songkick.com/developer/upcoming-events-for-venue> for details.

This method also supports the B<format> parameter.

This method has another, mandatory, parameter called B<venue_id>. This is the
ID of the venue that you want information about.

=cut

sub get_venue_events {
  my $self = shift;

  my ($params) = @_;

  my $url;

  if (exists $params->{venue_id}) {
    $url = $self->venue_events_url . '.' . $self->api_format;
    $url =~ s/VENUE_ID/$params->{venue_id}/;
  } else {
    die "No venue id passed to get_venue_events\n";
  }

  $url = URI->new($url);

  my %req_args;

  foreach (keys %$params) {
    if ($self->venue_events_params->{$_}) {
      $req_args{$_} = $params->{$_};
    }
  }

  my $resp = $self->_request($url, \%req_args);

  return $resp unless $self->return_perl;

  return wantarray ? $self->parse_results_from_json($resp)
                   : [ $self->parse_results_from_json($resp) ];
}

=head2 $sk->get_artist_events({ ... options ... });

Gets a list of upcoming events for an artist.

This method has optional parameters: B<min_date> and B<max_date> to control the
timeframe for upcoming events, B<page> to control which page of the data you
want to return, B<per_page> to control the number of results to return in each page.
See L<https://www.songkick.com/developer/upcoming-events-for-artist> for details.

This method also supports the B<format> parameter.

This method requires another, mandatory, parameter identifying the artist.
This can be either the B<artist_id>, containing the Songkick ID for the artist,
or the B<mb_id> MusicBrainz ID for the artist.

=cut

sub get_artist_events {
  my $self = shift;

  my ($params) = @_;

  my $url;

  if (exists $params->{artist_id}) {
    $url = $self->artists_url . '.' . $self->api_format;
    $url =~ s/ARTIST_ID/$params->{artist_id}/;
  } elsif (exists $params->{mb_id}) {
    $url = $self->artists_mb_url . '.' . $self->api_format;
    $url =~ s/MB_ID/$params->{mb_id}/;
  } else {
    die "No artist_id or mb_id passed to get_artist_events\n";
  }

  $url = URI->new($url);

  my %req_args;

  foreach (keys %$params) {
    if ($self->artist_events_params->{$_}) {
      $req_args{$_} = $params->{$_};
    }
  }

  my $resp = $self->_request($url, \%req_args);

  return $resp unless $self->return_perl;

  return wantarray ? $self->parse_results_from_json($resp)
                   : [ $self->parse_results_from_json($resp) ];
}

=head2 $sk->get_artist_past_events({ ... options ... });

Gets a list of past events for an artist..

This method has optional parameters: B<min_date> and B<max_date to control the
timeframe for upcoming events, >B<page> to control which page of the data you
want to return, B<per_page> to control the number of results to return in each page.
See L<https://www.songkick.com/developer/upcoming-events-for-artist> for details.

This method also supports the B<format> parameter.

This method requires another, mandatory, parameter identifying the artist.
This can be either the B<artist_id>, containing the Songkick ID for the artist,
or the B<mb_id> MusicBrainz ID for the artist.

=cut

sub get_artist_past_events {
  my $self = shift;

  my ($params) = @_;

  my $url;

  if (exists $params->{artist_id}) {
    $url = $self->artists_url . '.' . $self->api_format;
    $url =~ s/ARTIST_ID/$params->{artist_id}/;
  } elsif (exists $params->{mb_id}) {
    $url = $self->artists_mb_url . '.' . $self->api_format;
    $url =~ s/MB_ID/$params->{mb_id}/;
  } else {
    die "No artist_id or mb_id passed to get_artist_events\n";
  }

  $url = URI->new($url);

  my %req_args;

  foreach (keys %$params) {
    if ($self->artist_gigs_params->{$_}) {
      $req_args{$_} = $params->{$_};
    }
  }

  my $resp = $self->_request($url, \%req_args);

  return $resp unless $self->return_perl;

  return wantarray ? $self->parse_results_from_json($resp)
                   : [ $self->parse_results_from_json($resp) ];
}

=head2 $sk->get_metro_events({ ... options ... });

Find upcoming events for a metro area. A metro area is a city or a collection of cities that Songkick uses to notify users of concerts near them.

This method has optional parameters: B<min_date> and B<max_date to control the
timeframe for upcoming events, >B<page> to control which page of the data you
want to return, B<per_page> to control the number of results to return in each page.
See L<https://www.songkick.com/developer/upcoming-events-for-artist> for details.

This method also supports the B<format> parameter.

This method has another, mandatory, parameter called B<metro_id>. This is the
ID of the metro area to return events for.

=cut

sub get_metro_events {
  my $self = shift;

  my ($params) = @_;

  my $url;

  if (exists $params->{metro_id}) {
    $url = $self->metro_url . '.' . $self->api_format . '?api_key=' . $self->api_key;
    $url =~ s/METRO_ID/$params->{metro_id}/;
  } else {
    die "No metro area id passed to get_metro_events\n";
  }

  $url = URI->new($url);

  my %req_args;

  foreach (keys %$params) {
    if ($self->metro_events_params->{$_}) {
      $req_args{$_} = $params->{$_};
    }
  }

  my $resp = $self->_request($url, \%req_args);

  return $resp unless $self->return_perl;

  return wantarray ? $self->parse_results_from_json($resp)
                   : [ $self->parse_results_from_json($resp) ];
}

=head2 $sk->get_artists({ ... options ... });

Search for artists by name using full text search. Sorted by relevancy.

This method has optional parameters: B<page> to control which page of the data you
want to return, B<per_page> to control the number of results to return in each page.
See L<https://www.songkick.com/developer/artist-search> for details.

This method also supports the B<format> parameter.

This method has another, mandatory, parameter called B<metro_id>. This is the
ID of the metro area to return events for.

=cut

sub get_artists {
  my $self = shift;

  my ($params) = @_;

  my $url;

  my $query;
  if (exists $params->{query}) {
    $query = delete $params->{query};
  } else {
    die "name of the artist not passed in <query> parameter to get_artists\n";
  }

  $url = $self->artist_search_url . '.' . $self->api_format . '?api_key='
    . $self->api_key .'&query=' . $query;
  $url = URI->new($url);

  my %req_args;

  foreach (keys %$params) {
    if ($self->artist_search_params->{$_}) {
      $req_args{$_} = $params->{$_};
    }
  }

  my $resp = $self->_request($url, \%req_args);

  return $resp unless $self->return_perl;

  return wantarray ? $self->parse_results_from_json($resp)
                   : [ $self->parse_results_from_json($resp) ];
}

=head2 $sk->get_similar_artists({ ... options ... });

A list of artists similar to a given artist, based on tracking and attendance data.

This method has optional parameters: B<page> to control which page of the data you
want to return, B<per_page> to control the number of results to return in each page.
See L<https://www.songkick.com/developer/similar-artists> for details.

This method also supports the B<format> parameter.

This method has another, mandatory, parameter called B<artist_id>. This is the
ID of the artist to return similar artists for.

=cut

sub get_similar_artists {
  my $self = shift;

  my ($params) = @_;

  my $url;

  my $artist_id;
  if (exists $params->{artist_id}) {
    $artist_id = delete $params->{artist_id};
  } else {
    die "ID of the artist not passed in <artist_id> parameter to get_similar_artists\n";
  }

  $url = $self->similar_artist_search_url . '.' . $self->api_format . '?api_key='
    . $self->api_key;
  $url =~ s/ARTIST_ID/$artist_id/;
  $url = URI->new($url);

  my %req_args;

  foreach (keys %$params) {
    if ($self->similar_artist_search_params->{$_}) {
      $req_args{$_} = $params->{$_};
    }
  }

  my $resp = $self->_request($url, \%req_args);

  return $resp unless $self->return_perl;

  return wantarray ? $self->parse_results_from_json($resp)
                   : [ $self->parse_results_from_json($resp) ];
}

=head2 $sk->get_event_details({ ... options ... });

Gets detailed event information, including full venue information,
for the specified event.

This method has a single, mandatory, parameter called B<event_id>.
This is the ID of the event to return information about. This method
has no optional parameters.

This method also supports the B<format> parameter.

=cut

sub get_event_details {
  my $self = shift;

  my ($params) = @_;

  my $event_id;
  if (exists $params->{event_id}) {
    $event_id = delete $params->{event_id};
  } else {
    die "event_id not passed to get_event\n";
  }

  my $url = $self->event_details_url . '.' . $self->api_format;
  $url =~ s/EVENT_ID/$event_id/;
  $url = URI->new($url);

  my %req_args;

  my $resp = $self->_request($url, \%req_args);

  return $resp unless $self->return_perl;

  return wantarray ? $self->parse_results_from_json($resp)
                   : [ $self->parse_results_from_json($resp) ];
}

=head2 $sk->get_venue({ ... options ... });

Gets detailed venue information, venue information, complete address,
phone number, description, and more. See
L<https://www.songkick.com/developer/venue-details> for details.

This method has a single, mandatory, parameter called B<venue_id>.
This is the ID of the venue to return information about. This method
has no optional parameters.

This method also supports the B<format> parameter.

=cut

sub get_venue {
  my $self = shift;

  my ($params) = @_;

  my $venue_id;
  if (exists $params->{venue_id}) {
    $venue_id = delete $params->{venue_id};
  } else {
    die "venue_id not passed to get_venue\n";
  }

  my $url = $self->venue_details_url . '.' . $self->api_format;
  $url =~ s/VENUE_ID/$venue_id/;
  $url = URI->new($url);

  my %req_args;

  my $resp = $self->_request($url, \%req_args);

  return $resp unless $self->return_perl;

  return wantarray ? $self->parse_results_from_json($resp)
                   : [ $self->parse_results_from_json($resp) ];
}

=head2 $sk->get_venues({ ... options ... });

Gets listings of venues on Songkick using full text search, including
past names and aliases. Sorted by relevancy.See
L<https://www.songkick.com/developer/venue-search> for details.

This method has optional parameters: B<page> to control which page of the data you
want to return, B<per_page> to control the number of results to return in each page.

This method also supports the B<format> parameter.

This method has another, mandatory, parameter called B<query>. This is the
name of the venue you are searching for.

=cut

sub get_venues {
  my $self = shift;

  my ($params) = @_;

  my $query;
  if (exists $params->{query}) {
    $query = delete $params->{query};
  } else {
    die "query not passed to get_venues\n";
  }

  my $url = $self->venues_url . '.' . $self->api_format;
  $url = URI->new($url);

  my %req_args;

  foreach (keys %$params) {
    if ($self->venues_params->{$_}) {
      $req_args{$_} = $params->{$_};
    }
  }

  my $resp = $self->_request($url, \%req_args);

  return $resp unless $self->return_perl;

  return wantarray ? $self->parse_results_from_json($resp)
                   : [ $self->parse_results_from_json($resp) ];
}

=head2 $sk->get_locations({ ... options ... });

Gets listings locations: a city and its metro area. A metro area is a city or a
collection of cities that Songkick uses to notify users of concerts near them. See
L<https://www.songkick.com/developer/location-search> for details.

This method has optional parameters: B<page> to control which page of the data you
want to return, B<per_page> to control the number of results to return in each page.

This method also supports the B<format> parameter.

This method requires another, mandatory, parameter identifying the artist.
This can be either the B<query>, containing the name of the location you are searching
for, or the B<location>, which dictates how the content returned should be localised.

=cut

sub get_locations {
  my $self = shift;

  my ($params) = @_;

  unless(exists $params->{query} || exists $params->{location}) {
    die "No query or location passed to get_locations\n";
  }

  my $url = $self->locations_url . '.' . $self->api_format;
  $url = URI->new($url);

  my %req_args;

  foreach (keys %$params) {
    if ($self->locations_params->{$_}) {
      $req_args{$_} = $params->{$_};
    }
  }

  my $resp = $self->_request($url, \%req_args);

  return $resp unless $self->return_perl;

  return wantarray ? $self->parse_results_from_json($resp)
                   : [ $self->parse_results_from_json($resp) ];
}

=head2 $sk->get_upcoming_calendar({ ... options ... });

Gets a list of upcoming events for a particular user from Songkick, returning
calendar entry objects.
See L<https://www.songkick.com/developer/upcoming-events-for-user> for details.

This method requires a mandatory B<user> parameter identifying the user and a
B<reason> parameter containing either I<tracked_artist> or I<attendance>.

This method has optional parameters: B<created_after> to filter out older
events, B<page> to control which page of the data you want to return, B<per_page>
to control the number of results to return in each page, and B<order> to
control date ordering.

This method also supports the B<format> parameter.

=cut

sub get_upcoming_calendar {
  my $self = shift;

  my ($params) = @_;

  my $user;
  if (exists $params->{user}) {
    $user = delete $params->{user};
  } else {
    die "user not passed to get_upcoming_calendar\n";
  }

  unless (exists $params->{reason}) {
    die "reason not passed to get_upcoming_calendar\n";
  }

  my $url = $self->user_calendar_url . '.' . $self->api_format;
  $url =~ s/USERNAME/$user/;
  $url = URI->new($url);

  my %req_args;

  foreach (keys %$params) {
    if ($self->user_events_params->{$_}) {
      $req_args{$_} = $params->{$_};
    }
  }

  my $resp = $self->_request($url, \%req_args);

  return $resp unless $self->return_perl;

  return wantarray ? $self->parse_results_from_json($resp)
                   : [ $self->parse_results_from_json($resp) ];
}

=head2 $sk->get_tracked({ ... options ... });

Returns the artists or metro areas tracked by a user. See
L<https://www.songkick.com/developer/trackings> for details.

This method requires a mandatory B<user> parameter identifying the user.
An B<artist_id> ,B<event_id>, or B<metro_id> parameter, containing the
relevant Songkick ID to check for, must also be passed.

This method has optional parameters: B<page> to control which page of the
data you want to return, B<per_page> to control the number of results to
return in each page, B<field> to specify a subset of fields to return in
the response, and B<created_after> to specify that only items created
on or after a given time/date should be included in the response.

This method also supports the B<format> parameter.

=cut

sub get_tracked {
  my $self = shift;

  my ($params) = @_;

  my $user;
  if (exists $params->{user}) {
    $user = delete $params->{user};
  } else {
    die "user not passed to get_tracking\n";
  }

  my $tracked;
  if( exists $params->{tracked} ) {
    $tracked = delete $params->{tracked};
  } else {
    die "No tracked parameter passed to get_tracking\n";
  }

  my $url = $self->user_tracked_url . '.' . $self->api_format; #/users/USERNAME/THING/tracked
  $url =~ s/USERNAME/$user/;
  $url =~ s/THING/$tracked/;
  $url = URI->new($url);

  my %req_args;

  foreach (keys %$params) {
    if ($self->user_tracked_params->{$_}) {
      $req_args{$_} = $params->{$_};
    }
  }

  my $resp = $self->_request($url, \%req_args);

  return $resp unless $self->return_perl;

  return wantarray ? $self->parse_results_from_json($resp)
                   : [ $self->parse_results_from_json($resp) ];
}

=head2 $sk->get_muted({ ... options ... });

Returns the artists that a user once tracked but has subsequently untracked.
See L<https://www.songkick.com/developer/trackings> for details.

This method requires a mandatory B<user> parameter identifying the user.

This method has optional parameters: B<page> to control which page of the
data you want to return, B<per_page> to control the number of results to
return in each page, and B<field> to specify a subset of fields to return in
the response.

This method also supports the B<format> parameter.

=cut

sub get_muted {
  my $self = shift;

  my ($params) = @_;

  my $user;
  if (exists $params->{user}) {
    $user = delete $params->{user};
  } else {
    die "user not passed to get_tracking\n";
  }


  my $url = $self->user_muted_url . '.' . $self->api_format; #/users/USERNAME/artists/muted
  $url =~ s/USERNAME/$user/;
  $url = URI->new($url);

  my %req_args;

  foreach (keys %$params) {
    if ($self->user_muted_params->{$_}) {
      $req_args{$_} = $params->{$_};
    }
  }

  my $resp = $self->_request($url, \%req_args);

  return $resp unless $self->return_perl;

  return wantarray ? $self->parse_results_from_json($resp)
                   : [ $self->parse_results_from_json($resp) ];
}

=head2 $sk->get_tracking({ ... options ... });

Checks whether a user tracks a given artist, event, or metro area. See
L<https://www.songkick.com/developer/trackings> for details.

This method requires a mandatory B<user> parameter identifying the user.
An B<artist_id> ,B<event_id>, or B<metro_id> parameter, containing the
relevant Songkick ID to check for, must also be passed.

This method has no optional parameters.

This method also supports the B<format> parameter.

If the requested item is tracked by the user, a tracking object will be
returned. If not, I<undef> is returned.

=cut

sub get_tracking {
  my $self = shift;

  my ($params) = @_;

  my $user;
  if (exists $params->{user}) {
    $user = delete $params->{user};
  } else {
    die "user not passed to get_tracking\n";
  }

  my $url = $self->user_trackings_url . '.' . $self->api_format; #/users/USERNAME/trackings/TRACKEE
  $url =~ s/USERNAME/$user/;

  my $trackee;
  if (exists $params->{artist_id}) {
    $trackee = 'artist:'.delete $params->{artist_id};
  } elsif (exists $params->{event_id}) {
    $trackee = 'event:'.delete $params->{event_id};
  } elsif (exists $params->{metro_area_id}) {
    $trackee = 'metro_area:'.delete $params->{metro_area_id};
  } else {
    die "No artist_id, event_id, or metro_area_id passed to get_tracking\n";
  }
  $url =~ s/TRACKEE/$trackee/;

  $url = URI->new($url);

  my %req_args;

  foreach (keys %$params) {
    if ($self->user_trackings_params->{$_}) {
      $req_args{$_} = $params->{$_};
    }
  }

  my $resp = $self->_request($url, \%req_args);

  # $resp may contain 404 if the user does not track the specified item
  return $resp unless ($self->return_perl && $resp);

  return wantarray ? $self->parse_results_from_json($resp)
                   : [ $self->parse_results_from_json($resp) ];
}

no Moose;
__PACKAGE__->meta->make_immutable;

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
