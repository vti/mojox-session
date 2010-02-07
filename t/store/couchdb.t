#!/usr/bin/perl

BEGIN {
    use Test::More;

    plan skip_all => 'set TEST_AUTHOR to enable this test (developer only!)'
      unless $ENV{TEST_AUTHOR};
}

use strict;
use warnings;

plan tests => 16;

use_ok('MojoX::Session');
use_ok('MojoX::Session::Store::Couchdb');

is(MojoX::Session::Store::Couchdb->new->is_async, 1);

use Mojo::Client;
use Mojo::IOLoop;

my $ioloop = Mojo::IOLoop->new;

my $client = Mojo::Client->new;
$client->delete('http://localhost:5984/session' => sub { })->process;
$client->put('http://localhost:5984/session' => sub { })->process;
$client = undef;

$ioloop->start;

$client = Mojo::Client->new;

my $sid;

# Create
my $session = MojoX::Session->new(store => 'couchdb');
$session->create(
    sub {
        my ($self, $sid_) = @_;

        $sid = $sid_;

        ok($sid);
    }
);

ok($sid);

$session->data(foo => 'bar');

$session->flush(
    sub {
        my $session = shift;

        ok(not defined $session->error);
    }
);

# Load
$session = MojoX::Session->new(store => 'couchdb');
$session->load(
    $sid => sub {
        my ($self, $sid_) = @_;

        ok(not defined $self->error);
        is($sid_,              $sid);
        is($self->sid,         $sid);
        is($self->data('foo'), 'bar');
    }
);

# Update
$session->store->client(Mojo::Client->new);
$session->data(foo => 'baz');
$session->flush(
    sub {
        my ($self) = @_;

        ok(not defined $self->error);
    }
);

# Load
$session = MojoX::Session->new(store => 'couchdb');
$session->load(
    $sid => sub {
        my ($self, $sid_) = @_;

        ok(not defined $self->error);
        is($sid_,              $sid);
        is($self->data('foo'), 'baz');
    }
);

# Delete
$session->expire;
$session->flush(
    sub {
        my $self = shift;

        ok(not defined $self->error);
    }
);

# Load after delete
$session = MojoX::Session->new(store => 'couchdb');
$session->load(
    $sid => sub {
        my ($session, $sid) = @_;

        ok(not defined $sid);
    }
);
