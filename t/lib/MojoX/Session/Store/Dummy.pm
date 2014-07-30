package MojoX::Session::Store::Dummy;

use strict;
use warnings;

use base 'MojoX::Session::Store';

__PACKAGE__->attr('sessions' => sub {{}});

sub create {
    my ($self, $sid, $expires, $data, $persistent) = @_;

    $self->sessions->{$sid} = {expires => $expires, data => $data,
		persistent => $persistent};
}

sub load {
    my ($self, $sid) = @_;

    return ($self->sessions->{$sid}->{expires},
		$self->sessions->{$sid}->{data}, $self->sessions->{$sid}->{persistent});
}

sub update {
    my ($self, $sid, $expires, $data, $persistent) = @_;

    $self->sessions->{$sid} = {expires => $expires, data => $data,
		persistent => $persistent};
}

sub delete {
    my ($self, $sid) = @_;

    delete $self->sessions->{$sid};
}

1;
