use Test::More tests => 11;

use lib 't/lib';

use NewDB;

use_ok('MojoX::Session');
use_ok('MojoX::Session::Store::DBI');

my $dbh = NewDB->dbh;

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
