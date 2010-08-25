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

our $VERSION = '0.01';

use Moose;

use LWP::UserAgent;

my $API_URL = 'http://api.songkick.com/api/3.0';
my $EVT_URL = "$API_URL/events";
my $UPC_URL = "$API_URL/users/USERNAME/events";
my $GIG_URL = "$API_URL/users/USERNAME/gigography";
my $SET_URL = "$API_URL/events/EVENT_ID/setlists/";

my @EVT_PRM = qw(type artists artist_name artist_id venue_id setlist_item_name
		 min_date max_date location);
my %EVT_PRM = map { $_ => 1 } @EVT_PRM;

my @UPC_PRM = (@EVT_PRM, 'attendance');
my %UPC_PRM = map { $_ => 1 } @UPC_PRM;

my @GIG_PRM = qw(page);
my %GIG_PRM = map { $_ => 1 } @GIG_PRM;

my @SET_PRM = qw();
my %SET_PRM = map { $_ => 1 } @SET_PRM;

my $DEF_FMT = 'xml';

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

sub _request {
  my $self = shift;
  my ($url) = @_;

  my $resp = $self->ua->get($url);

  if ($resp->is_success) {
    return $resp->content;
  }
}

=head2 $sk->get_events({ ... options ... });

Gets a list of upcoming events from Songkick. Various parameters to control
the events returned are supported for the full list see
L<http://www.songkick.com/developer/event-search>.

In addition, this method takes an extra parameter, B<format>, which control
the format of the data returned. This can be either I<xml> or I<json>. If this
parameter is omitted, then I<xml> is assumed.

=cut

sub get_events {
  my $self = shift;
  my ($params) = @_;

  my $format = $DEF_FMT;
  if (exists $params->{format}) {
    $format = lc delete $params->{format};
  }

  my $url = "$EVT_URL.$format?apikey=" . $self->api_key;

  foreach (keys %$params) {
    if ($EVT_PRM{$_}) {
      $url .= "&$_=$params->{$_}";
    }
  }

  return $self->_request($url);
}

=head2 $sk->get_upcoming_events({ ... options ... });

Gets a list of upcoming events for a particular user from Songkick. This
method accepts all of the same search parameters as C<get_events>. It also
supports the optional B<format> parameter.

This method has another, mandatory, parameter called B<user>. This is the
username of the user that you want information about.

=cut

sub get_upcoming_events {
  my $self = shift;

  my ($params) = @_;

  my $format = $DEF_FMT;
  if (exists $params->{format}) {
    $format = lc delete $params->{format};
  }

  my $user;
  if (exists $params->{user}) {
    $user = delete $params->{user};
  } else {
    die "user not passed to get_past_events\n";
  }

  my $url = "$UPC_URL.$format?apikey=" . $self->api_key;
  $url =~ s/USERNAME/$user/;

  foreach (keys %$params) {
    if ($UPC_PRM{$_}) {
      $url .= "&$_=$params->{$_}";
    }
  }

  return $self->_request($url);
}

=head2 $sk->get_past_events({ ... options ... });

Gets a list of upcoming events for a particular user from Songkick.

This method has an optional parameter, B<page> to control which page of
the data you want to return. It also supports the B<format> parameter.

This method has another, mandatory, parameter called B<user>. This is the
username of the user that you want information about.

=cut

sub get_past_events {
  my $self = shift;

  my ($params) = @_;

  my $format = $DEF_FMT;
  if (exists $params->{format}) {
    $format = lc delete $params->{format};
  }

  my $user;
  if (exists $params->{user}) {
    $user = delete $params->{user};
  } else {
    die "user not passed to get_past_events\n";
  }

  my $url = "$GIG_URL.$format?apikey=" . $self->api_key;
  $url =~ s/USERNAME/$user/;

  foreach (keys %$params) {
    if ($GIG_PRM{$_}) {
      $url .= "&$_=$params->{$_}";
    }
  }

  return $self->_request($url);
}

=head2 $sk->get_setlist({ ... options ... });

Returns information about a set list from a gig. It supports the B<format>
parameter.

This method also has a mandatory parameter called B<event_id>. This is the
Songkick identifier for the gig that you want the set list for. For more
details about this parameter, see
L<http://www.songkick.com/developer/setlists>.

=cut

sub get_setlist {
  my $self = shift;

  my ($params) = @_;

  my $format = $DEF_FMT;
  if (exists $params->{format}) {
    $format = lc delete $params->{format};
  }

  my $event_id;
  if (exists $params->{event_id}) {
    $event_id = delete $params->{event_id};
  } else {
    die "event_id not passed to get_setlist\n";
  }

  my $url = "$SET_URL.$format?apikey=" . $self->api_key;
  $url =~ s/EVENT_ID/$event_id/;

  foreach (keys %$params) {
    if ($SET_PRM{$_}) {
      $url .= "&$_=$params->{$_}";
    }
  }

  return $self->_request($url);
}

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
