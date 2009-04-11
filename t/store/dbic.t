use Test::More;

BEGIN {
    eval "use DBD::SQLite";
    plan skip_all => "DBD::SQLite is required to run this test" if $@;

    eval "use DBIx::Class::Schema::Loader";
    plan skip_all => "DBIx::Class::Schema::Loader "
      . "is required to run this test"
      if $@;
}

use lib 't/lib';

plan tests => 8;

use_ok('MojoX::Session');
use_ok('MojoX::Session::Store::DBIC');

use NewDB;

my $table  = NewDB->dbh->{Name};
my $schema = DB->connect("dbi:SQLite:$table");
my $rs     = $schema->resultset('Session');

my $session =
  MojoX::Session->new(
    store => MojoX::Session::Store::DBIC->new(resultset => $rs));

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


package DB;
use base 'DBIx::Class::Schema::Loader';

__PACKAGE__->loader_options(relationships => 1,);

