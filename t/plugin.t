#!/usr/bin/env perl

# Copyright (C) 2010, Yaroslav Korshak.

use strict;
use warnings;

use Test::More;

plan tests => 8;

use FindBin;
use lib "$FindBin::Bin/lib";

use Test::Mojo;
use Mojo::Client;
use Mojolicious::Lite;

# Silence
app->log->level('error');

plugin 'session',
  store         => 'dummy',
  expires_delta => 10,
  init          => sub {
    my ($self, $session) = @_;
    $self->stash(init => 'ok');
  };

sub reset_id {
    my ($s, $sid) = @_;

    $s->sid($sid);

    # Quite dirty, yea :(
    $s->tx->res->headers->remove('Set-Cookie');
    $s->tx->res->headers->remove('Set-Cookie2');
    $s->transport->set($s->sid, $s->expires);

    return $s;
}

get '/sleepy' => sub {
    my $self = shift;

    my $session = $self->stash('session');
    $session->create;
    reset_id($session, 'sleepy');

    $self->pause;
    my $result;

    $self->client->get(
        '/fasty' => sub {
            my ($client, $tx) = @_;

            $self->resume;

            my $result = $tx->res;
            $self->render_text("Session id is: '"
                  . $session->sid . "'; "
                  . "fasty session returned "
                  . $result->code . ': \''
                  . $result->body
                  . '\'; fasty cookie: \''
                  . $result->cookie('sid')->value
                  . "'");
        }
    )->process;

};

get '/fasty' => sub {
    my $self    = shift;
    my $session = $self->stash('session');

    $session->create();
    reset_id($session, 'fasty');

    $self->render_text("This is a fasty session!");

};

my $client = Mojo::Client->new(app => app);
app->client($client);

my $t = Test::Mojo->new;
$t->client($client);

# Touching sleepy session, which will touch fasty
$t->get_ok('/sleepy')->status_is(200);

my $ct = $t->_get_content($t->tx);

# Just parse response
ok($ct
      =~ qr/^Session id is: '(.*)'; fasty session returned (\d+): '(.*?)'; fasty cookie: '(.*)'$/
);

my ($sleepy_id, $fasty_status, $fasty_response, $fasty_sid) =
  ($1, $2, $3, $4);

# Main test: data of sleepy session should be 'sleepy'
is($sleepy_id, "sleepy", 'sleepy session');
is($t->tx->res->cookie('sid')->value, 'sleepy');

# Checking fasty status
is($fasty_status,   "200");
is($fasty_response, 'This is a fasty session!');
is($fasty_sid,      'fasty');
