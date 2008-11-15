use Test::More tests => 10;

use lib 't/lib';

use_ok('MojoX::Session');

use MojoX::Session::Store::Dummy;

my $session =
  MojoX::Session->new(store => MojoX::Session::Store::Dummy->new());

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
