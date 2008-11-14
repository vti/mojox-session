use Test::More tests => 5;

use lib 't/lib';

use NewDB;

use_ok('MojoX::Session');
use_ok('MojoX::Session::Store::DBI');

my $dbh = NewDB->dbh;

my $session = MojoX::Session->new(
    store    => MojoX::Session::Store::DBI->new(dbh => $dbh),
    ip_match => 1
);

$ENV{REMOTE_ADDR} = '127.0.0.1';
$session->create();
my $sid = $session->sid;
ok($sid);
$session->flush();

$ENV{REMOTE_ADDR} = '127.0.0.2';
ok(not defined $session->load($sid));

$ENV{REMOTE_ADDR} = '127.0.0.1';
ok($session->load($sid));
