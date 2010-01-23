package SessionTest;

use strict;
use warnings;

use base 'Mojolicious';

sub startup {
    my $self = shift;

    # Only log errors to STDERR
    $self->log->level('fatal');

    # Default handler
    $self->renderer->default_handler('epl');
    $self->plugin(
        'session',
        store         => 'dummy',
        expires_delta => 10
    );

    # Routes
    my $r = $self->routes;

    $r->route('/sleepy')
      ->to(controller => 'sess', action => 'sleepy_session');

    $r->route('/fasty')->to(controller => 'sess', action => 'fasty_session');
}

1;
