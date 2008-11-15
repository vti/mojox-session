use Test::More tests => 4;

use lib 't/lib';

use_ok('MojoX::Session');

use MojoX::Session::Store::Dummy;

my $session = MojoX::Session->new(
    store    => MojoX::Session::Store::Dummy->new(),
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
