use Test::More tests => 4;

use_ok('MojoX::Session');

my $session = MojoX::Session->new();

$session->create();
$session->data('foo' => 'bar');
$session->clear;

ok($session->sid);
ok($session->expires);
ok(not defined $session->data('foo'));
