# Copyright (C) 2008-2010, Sebastian Riedel.

package SessionTest;

use strict;
use warnings;

use base 'Mojolicious';

# Let's face it, comedy's a dead art form. Tragedy, now that's funny.
sub startup {
    my $self = shift;

    # Only log errors to STDERR
    $self->log->level('fatal');

    # Default handler
    $self->renderer->default_handler('epl');
    $self->plugin('session', 
        store => 'dummy', 
        expires_delta => 10
    );

    # Routes
    my $r = $self->routes;

    $r->route('/sleepy')
      ->to(controller => 'sess', action => 'sleepy_session');

    $r->route('/fasty')
      ->to(controller => 'sess', action => 'fasty_session');
}

1;
