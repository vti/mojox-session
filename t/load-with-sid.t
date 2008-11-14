use Test::More tests => 5;

use lib 't/lib';

use NewDB;

use_ok('MojoX::Session');
use_ok('MojoX::Session::Store::DBI');
use_ok('MojoX::Session::Transport::Cookie');

use Mojo::Transaction;
use Mojo::Cookie::Response;

my $dbh = NewDB->dbh;

my $tx = Mojo::Transaction->new();
my $session = MojoX::Session->new(
    store     => MojoX::Session::Store::DBI->new(dbh  => $dbh),
    transport => MojoX::Session::Transport::Cookie->new(tx => $tx)
);

$session->create();
my $sid = $session->sid;
ok($sid);
$session->flush();

is($session->load($sid), $sid);
