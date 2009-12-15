#!/usr/bin/env perl

use FindBin;

use lib "$FindBin::Bin/../lib";
use lib "$FindBin::Bin/../t/lib";

use Mojolicious::Lite;

use MojoX::Session;
use MojoX::Session::Transport::Cookie;
use MojoX::Session::Store::Dummy;

my $session = MojoX::Session->new(
    transport => MojoX::Session::Transport::Cookie->new,
    store     => MojoX::Session::Store::Dummy->new
);

get '/' => sub {
    my $c = shift;

    my $message = '';

    $session->tx($c->tx);

    # Check if we already have a session
    if ($session->load) {
        if ($session->is_expired) {

            # Delete session from the store
            $session->flush;

            # Create a new session
            $session->create;

            # Write session to the store
            $session->flush;

            $message = 'Welcome again';
        }
        else {
            $message = 'Welcome back';
        }
    }
    else {
        # Create a new session
        $session->create;

        # Write session to the store
        $session->flush;

        $message = 'Welcome';
    }

    $c->res->code(200);
    $c->res->body("session: $message\n");
} => 'root';

shagadelic('daemon');

1;
