use Test::More tests => 5;

use_ok('MojoX::Session');
use_ok('MojoX::Session::Store::DBI');

use DBI;

my $dbh = DBI->connect("dbi:SQLite:table.db") or die $DBI::errstr;

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
