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

sub get_events {
  my $self = shift;
  my ($params) = @_;

  my $format = $DEF_FMT;
  if (exists $params->{format}) {
    $format = delete $params->{format};
  }

  my $url = "$EVT_URL.$format?apikey=" . $self->api_key;

  foreach (keys %$params) {
    if ($EVT_PRM{$_}) {
      $url .= "&$_=$params->{$_}";
    }
  }

  return $self->_request($url);
}

sub get_upcoming_events {
  my $self = shift;

  my ($params) = @_;

  my $format = $DEF_FMT;
  if (exists $params->{format}) {
    $format = delete $params->{format};
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

sub get_past_events {
  my $self = shift;

  my ($params) = @_;

  my $format = $DEF_FMT;
  if (exists $params->{format}) {
    $format = delete $params->{format};
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

sub get_setlist {
  my $self = shift;

  my ($params) = @_;

  my $format = $DEF_FMT;
  if (exists $params->{format}) {
    $format = delete $params->{format};
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

1;
