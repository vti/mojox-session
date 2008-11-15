use Test::More tests => 6;

use_ok('MojoX::Session');

my $session = MojoX::Session->new();

$session->create();
$session->data('foo' => 'bar');
$session->clear;

ok($session->sid);
ok($session->expires_delta);
is_deeply($session->data, {});

$session->data('foo' => 'bar', 'baz' => 'faz');
$session->clear('foo');
is_deeply($session->data, {baz => 'faz'});

$session->clear();
$session->data('foo' => undef);
is_deeply($session->data, {foo => undef});
