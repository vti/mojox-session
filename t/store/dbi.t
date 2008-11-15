use Test::More tests => 8;

use lib 't/lib';

use_ok('MojoX::Session');
use_ok('MojoX::Session::Store::DBI');

use NewDB;

my $dbh = NewDB->dbh;

my $session =
  MojoX::Session->new(store => MojoX::Session::Store::DBI->new(dbh => $dbh));

# create
my $sid = $session->create();
ok($sid);
$session->flush();

# load
ok($session->load($sid));
is($session->sid, $sid);

# update
$session->data(foo => 'bar');
$session->flush;
ok($session->load($sid));
is($session->data('foo'), 'bar');

# delete
$session->expire;
$session->flush;
ok(not defined $session->load($sid));
