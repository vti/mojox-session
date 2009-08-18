use Test::More tests => 10;

use lib 't/lib';

use_ok('MojoX::Session');
use_ok('MojoX::Session::Transport::Cookie');

use Mojo::Transaction::Single;
use Mojo::Cookie::Response;
use MojoX::Session::Store::Dummy;

my $cookie = Mojo::Cookie::Request->new(name => 'sid', value => 'bar');

my $tx = Mojo::Transaction::Single->new();
$tx->req->cookies($cookie);

my $session = MojoX::Session->new(
    tx        => $tx,
    store     => MojoX::Session::Store::Dummy->new(),
    transport => MojoX::Session::Transport::Cookie->new
);

my $sid = $session->create();
$session->flush();
ok($sid);

my $old_cookie = $tx->res->cookies->[0];

$cookie = Mojo::Cookie::Request->new(name => 'sid', value => $sid);
$tx->req->cookies($cookie);
is($session->load(), $sid);

diag 'Sleep 2 seconds to expire session';
sleep(2);

$session->extend_expires;
$session->flush;

my $new_cookie = $tx->res->cookies->[0];
ok($old_cookie->expires->epoch < $new_cookie->expires->epoch);

$session->expire;
ok($tx->res->cookies->[0]->expires->epoch <= time - 30 * 24 * 3600);
is($tx->res->cookies->[0]->max_age, 0);
is($tx->res->cookies->[0]->path, '/');

$tx = Mojo::Transaction::Single->new;
$session->tx($tx);
$session->load(123);
is($session->is_expired, 1);
ok($tx->res->cookies->[0]->expires->epoch < time);
