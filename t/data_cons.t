#!/usr/bin/env perl

# Copyright (C) 2010, Yaroslav Korshak.

use strict;
use warnings;

use Test::More;

plan tests => 11;

use FindBin;
use lib "$FindBin::Bin/lib";

use Mojo::Transaction::Single;
use Test::Mojo; 

use_ok('SessionTest');

my $t = Test::Mojo->new(app => SessionTest->new());
$t->app->{'TestServer'} = $t;

# Touching sleepy session, which will touch fasty

$t->get_ok('/sleepy')
  ->status_is(200)
  ->header_is(Server         => 'Mojo (Perl)')
  ->header_is('X-Powered-By' => 'Mojolicious (Perl)');

my $ct =$t->_get_content($t->tx);
# Just parse response
ok($ct =~ qr/^Session id is: '(.*)'; fasty session returned (\d+): '(.*?)'; fasty cookie: '(.*)'$/); 

my ($sleepy_id, $fasty_status, $fasty_response, $fasty_sid) = ($1,$2,$3, $4);

# Main test: data of sleepy session should be 'sleepy'
is($sleepy_id, "sleepy", 'sleepy session');
is($t->tx->res->cookie('sid')->value, 'sleepy');

# Checking fasty status
is($fasty_status, "200");
is($fasty_response, 'This is a fasty session!');
is($fasty_sid, 'fasty');
