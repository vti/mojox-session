use Test::More tests => 11;

use_ok('MojoX::Session');
use_ok('MojoX::Session::Store::DBI');

use DBI;

my $dbh = DBI->connect("dbi:SQLite:table.db") or die $DBI::errstr;

my $session =
  MojoX::Session->new(store => MojoX::Session::Store::DBI->new(dbh => $dbh),);

$session->create();
my $sid = $session->sid;
ok($sid);

$session->data->{foo} = 'bar';
is($session->data->{foo}, 'bar');
is($session->data('foo'), 'bar');

$session->data('foo' => 'baz');
is($session->data->{foo}, 'baz');
is($session->data('foo'), 'baz');
$session->flush();

ok($session->load($sid));
is($session->data('foo'), 'baz');
$session->data('foo' => 'zab');
$session->flush();

ok($session->load($sid));
is($session->data('foo'), 'zab');
