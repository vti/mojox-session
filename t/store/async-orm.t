#!/usr/bin/perl

BEGIN {
    use Test::More;

    eval "use DBD::SQLite";
    plan skip_all => "DBD::SQLite is required to run this test" if $@;

    eval "use Async::ORM";
    plan skip_all => "Async::ORM is required to run this test" if $@;
}

package DB;

use strict;
use warnings;

use base 'Async::ORM';

__PACKAGE__->schema(
    table        => 'session',
    columns      => [qw/sid data expires/],
    primary_keys => 'sid'
);

package main;

use strict;
use warnings;

use lib 't/lib';

plan tests => 12;

use_ok('MojoX::Session');
use_ok('MojoX::Session::Store::AsyncOrm');

use NewDB;

use Async::ORM::DBI::Simple;

my $dbh = Async::ORM::DBI::Simple->new(dbi => NewDB->dbi);

is(MojoX::Session::Store::AsyncOrm->new->is_async, 1);

my $session =
  MojoX::Session->new(store => [async_orm => {dbh => $dbh, class => 'DB'}]);

my $sid;

# Create
$session->create(
    sub {
        my ($self, $sid_) = @_;

        $sid = $sid_;

        ok($sid);
    }
);

ok($sid);

$session->flush(sub { ok(not defined $_[0]->error) });

# Load
$session->load(
    $sid => sub {
        my ($self, $sid_) = @_;

        is($sid_,      $sid);
        is($self->sid, $sid);
    }
);

# Update
$session->data(foo => 'bar');
$session->flush(sub { ok(not defined $_[0]->error) });

# Load
$session->load(
    $sid => sub {
        my ($self, $sid_) = @_;
        is($self->data('foo'), 'bar');
    }
);

# delete
$session->expire;
$session->flush(sub { ok(not defined $_[0]->error) });

$session->load($sid => sub { ok(not defined $_[1]) });

1;
