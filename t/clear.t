use Test::More tests => 3;

use_ok('MojoX::Session');

my $session = MojoX::Session->new();

$session->create();
$session->data('foo' => 'bar');
$session->clear;

ok(not defined $session->sid);
ok(not defined $session->data('foo'));
