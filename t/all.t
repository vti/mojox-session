use Test::More tests => 8;

use lib 't/lib';

use NewDB;

use_ok('MojoX::Session');
use_ok('MojoX::Session::Store::DBI');
use_ok('MojoX::Session::Transport::Cookie');

use Mojo::Transaction;
use Mojo::Cookie::Response;

my $dbh = NewDB->dbh;

my $cookie = Mojo::Cookie::Request->new(name => 'sid', value => 'bar');

my $tx = Mojo::Transaction->new();
$tx->req->cookies($cookie);

my $session = MojoX::Session->new(
    store     => MojoX::Session::Store::DBI->new(dbh  => $dbh),
    transport => MojoX::Session::Transport::Cookie->new(tx => $tx)
);

ok(not defined $session->load());

$session->create();
$session->flush();
my $sid = $session->sid;
ok($sid);

my $old_cookie = $tx->res->cookies->[0];
$cookie = Mojo::Cookie::Request->new(name => 'sid', value => $sid);

$tx->req->cookies($cookie);
ok($session->load());
is($session->sid, $sid);

my $new_cookie = $tx->res->cookies->[0];
ok($old_cookie->expires->epoch < $new_cookie->expires->epoch);
