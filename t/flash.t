use Test::More tests => 5;

use_ok('MojoX::Session');

my $session = MojoX::Session->new();

$session->create();
$session->data('foo' => 'bar');

is($session->flash('foo'), 'bar');
is($session->flash('foo'), undef);
is($session->data('foo'), undef);

is_deeply($session->data, {})
