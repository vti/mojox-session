package MojoX::Session;

use strict;
use warnings;

our $VERSION = '0.01';

use base 'Mojo::Base';

use MojoX::Session::Object;

__PACKAGE__->attr('store', chained => 1);
__PACKAGE__->attr('transport', chained => 1);

__PACKAGE__->attr('ip_match', default => 0, chained => 1);
__PACKAGE__->attr('expires', default => 3600, chained => 1);

__PACKAGE__->attr('_is_new', default => 0);
__PACKAGE__->attr('_is_expired', default => 0);
__PACKAGE__->attr('_is_stored', default => 0);

__PACKAGE__->attr('o', chained => 1);

sub create {
    my $self = shift;

    my $expires = time + $self->expires;
    my $o = MojoX::Session::Object->new(expires => $expires);

    $self->_is_new(1);

    if ($self->ip_match) {
        $o->data('__ip_match', $self->_remote_addr);
    }

    $self->o($o);

    $self->transport->set($o->sid, $expires) if $self->transport;

    return $self->sid;
}

sub load {
    my $self = shift;
    my ($sid) = @_;

    unless ($sid) {
        $sid = $self->transport->get if $self->transport;
        return unless $sid;
    }

    my ($expires, $data) = $self->store->load($sid);
    return unless $expires;

    my $o = MojoX::Session::Object->new(
        sid     => $sid,
        expires => $expires
    );

    while (my ($key, $value) = each %$data) {
        $o->data($key, $value);
    }

    if ($o->is_expired) {
        $self->store->delete($sid);
        return;
    }

    if ($self->ip_match) {
        return unless $self->_remote_addr;

        return unless $o->data('__ip_match');

        return unless $self->_remote_addr eq $o->data('__ip_match');
    }

    $self->o($o);

    $self->_is_stored(1);

    return $self->sid;
}

sub flush {
    my $self = shift;

    my $o = $self->o;

    if ($self->_is_expired && $self->_is_stored) {
        $self->store->delete($o->sid);
        $self->_is_stored(0);
        return;
    }

    if ($self->_is_new) {
        $self->store->create($o->sid, $o->expires, $o->data);
        $self->_is_new(0);
    } else {
        $self->store->update($o->sid, $o->expires, $o->data);
    }

    $self->_is_stored(1);
}

sub sid {
    my $self = shift;
    return $self->o->sid(@_);
}

sub data {
    my $self = shift;
    return $self->o->data(@_);
}

sub clear {
    my $self = shift;
    $self->o->clear;
}

sub expire {
    my $self = shift;
    $self->clear;
    $self->o->expires(0);
    $self->_is_expired(1);
    return $self;
}

sub _remote_addr { $ENV{REMOTE_ADDR} }

1;
__END__

=head1 NAME

MojoX::Session - Session management for Mojo

=head1 SYNOPSIS

    my $session = MojoX::Session->new(
        store     => MojoX::Session::Store::DBI->new(dbh  => $dbh),
        transport => MojoX::Session::Transport::Cookie->new(tx => $tx),
        ip_match  => 1
    );

    $session->create(); # creates new session
    $session->load();   # tries to find session

    $session->sid; # session id

    $session->data('foo' => 'bar'); # set foo to bar
    $session->data('foo'); # get foo value

    $session->flush(); # writes session to the store

=head1 DESCRIPTION

L<MojoX::Session> is a session management for L<Mojo>. Based on L<CGI::Session>
and L<HTTP::Session> but without any dependencies except the core ones.

=head1 ATTRIBUTES

L<MojoX::Session> implements the following attributes.

=head2 C<store>
    
    Store object

    my $store = $session->store;
    $session  = $session->store(MojoX::Session::Store::DBI->new(dbh => $dbh));

=head2 C<transport>

    Transport to find and store session id

    my $transport = $session->transport;
    $session
        = $session->transport(MojoX::Session::Transport::Cookie->new(tx => $tx));

=head2 C<ip_match>

    Check if ip matches, default is 0

    my $ip_match = $session->ip_match;
    $ip_match    = $session->ip_match(0);

=head2 C<expires>

    Seconds until session is considered expired

    my $expires = $session->expires;
    $expires    = $session->expires(3600);

=head1 METHODS

L<MojoX::Session> inherits all methods from L<Mojo::Base> and implements the
following new ones.

=head2 C<new>
    
    my $session = MojoX::Session->new(...);

    Returns new L<MojoX::Session> object.

=head2 C<create>

    my $sid = $session->create;
    $session->flush;

Creates new session. Puts sid into the transport. Call flush if you want to
store it.

=head2 C<load>

    $session->load;
    $session->load($sid);

Tries to load session from the store, gets sid from transport unless it is
provided.

=head2 C<flush>

    $session->flush;

Actually writes session to the store.

=head2 C<sid>

    my $sid = $session->sid;

Returns session id.

=head2 C<data>
    
    my $foo = $session->data('foo');
    $session->data('foo' => 'bar');
    # or
    my $foo = $session->data->{foo};
    $session->data->{foo} = 'bar';

Get and set values to the session.

=head2 C<clear>

    $session->clear;
    $session->flush;

Clear session values. Call flush if you want to clear it in the store.

=head2 C<expire>

    $session->expire;
    $session->flush;

Force session to expire. Call flush if you want to remove it from the store.

=head1 SEE ALSO

L<CGI::Session>, L<HTTP::Session>

=head1 AUTHOR

vti, C<vti@cpan.org>.

=head1 COPYRIGHT

Copyright (C) 2008, Viacheslav Tikhanovskii.

This program is free software, you can redistribute it and/or modify it under
the same terms as Perl 5.10.

=cut
