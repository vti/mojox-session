use Test::More tests => 5;

use lib 't/lib';

use_ok('MojoX::Session');
use_ok('MojoX::Session::Store::DBI');

use NewDB;

my $dbh = NewDB->dbh;

my $session =
  MojoX::Session->new(store => MojoX::Session::Store::DBI->new(dbh => $dbh));

ok(not defined $session->sid);
is($session->is_expired, 1);
is_deeply($session->data, {});
