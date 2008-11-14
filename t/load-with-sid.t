use Test::More tests => 5;

use_ok('MojoX::Session');
use_ok('MojoX::Session::Store::DBI');
use_ok('MojoX::Session::Transport::Cookie');

use DBI;
use Mojo::Transaction;
use Mojo::Cookie::Response;

my $dbh = DBI->connect("dbi:SQLite:table.db") or die $DBI::errstr;

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
