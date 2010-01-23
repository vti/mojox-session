# Copyright (C) 2010, Yaroslav Korshak.

package SessionTest::Sess;

use strict;
use warnings;

use base 'Mojolicious::Controller';

sub reset_id {
    my ($s, $sid) = @_;

    $s->sid($sid);

    # Quite dirty, yea :(
    $s->tx->res->headers->remove('Set-Cookie');
    $s->tx->res->headers->remove('Set-Cookie2');
    $s->transport->set($s->sid, $s->expires);

    return $s;
}

sub sleepy_session {
    my $c = shift;

    my $session = $c->stash('session');
    $session->create;
    reset_id($session, 'sleepy');

    $c->app->client->app($c->app);
    $c->tx->pause;
    my $result;

    # Now we'll touch fasty session
    $c->app->client->get(
        '/fasty',
        {},
        sub {
            my ($self, $tx) = @_;

            $c->tx->resume;

            $result = $tx->res;
        }
    )->process;

    $c->render_text("Session id is: '"
          . $session->sid . "'; "
          . "fasty session returned "
          . $result->code . ': \''
          . $result->body
          . '\'; fasty cookie: \''
          . $result->cookie('sid')->value
          . "'");
}

sub fasty_session {
    my $c = shift;

    my $session = $c->stash('session');

    $session->create();
    reset_id($session, 'fasty');

    $c->render_text("This is a fasty session!");
}

1;
