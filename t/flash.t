use Test::More tests => 7;

use_ok('MojoX::Session');

my $session = MojoX::Session->new;

$session->create;
$session->data('foo' => 'bar');
$session->flush;

is($session->flash('foo'), 'bar');
is($session->_is_flushed, 0);
is($session->data('foo'), undef);
is($session->flash('foo'), undef);
is($session->data('foo'), undef);

is_deeply($session->data, {})
