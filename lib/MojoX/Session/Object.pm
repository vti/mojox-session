package MojoX::Session::Object;

use strict;
use warnings;

use base 'Mojo::Base';

use Digest::SHA1 ();

__PACKAGE__->attr('sid', chained => 1);
__PACKAGE__->attr('expires', chained => 1);
__PACKAGE__->attr('_data', default => sub {{}});

sub new {
    my $class = shift;
    my $self = $class->SUPER::new(@_);

    $self->_init();

    return $self;
}

sub _init {
    my $self = shift;

    unless ($self->sid) {
        $self->generate_sid;
    }
}

sub generate_sid {
    my $self = shift;

    # based on CGI::Session::ID
    my $sha1 = Digest::SHA1->new();
    $sha1->add($$, time, rand(time));
    $self->sid($sha1->hexdigest);
}

sub is_expired {
    my ($self) = shift;

    return time > $self->expires;

    return 0;
}

sub data {
    my $self = shift;
    my ($key, $value) = @_;

    if ($key) {
        if ($value) {
            $self->_data->{$key} = $value;
        } else {
            return $self->_data->{$key};
        }
    } else {
        return $self->_data;
    }
}

sub clear {
    my $self = shift;

    $self->_data({});
}

1;
__END__

=head1 NAME

MojoX::Session::Object - Object representing session in MojoX::Session

=head1 SYNOPSIS

    This is only for internal use

=head1 DESCRIPTION

L<MojoX::Session::Object> is a session object for L<MojoX::Session>.

=head1 ATTRIBUTES

L<MojoX::Session::Store::DBI> implements the following attributes.

=head2 C<sid>
    
    my $sid = $o->sid;
    $o      = $o->sid($sid);

Holds session id.

=head2 C<expires>
    
    my $expires = $o->expires;
    $o          = $o->expires($expires);

Holds session expire time.

=head1 METHODS

L<MojoX::Session::Object> inherits all methods from L<Mojo::Base> and provides
the following ones.

=head2 C<new>

Returns new L<MojoX::Session::Object> session object.

=head2 C<generate_sid>

Generates new session id.

=head2 C<data>

Session data accessor.

=head2 C<is_expired>

Check if session is expired.

=head2 C<clear>

Clear all data in session.

=head1 AUTHOR

vti, C<vti@cpan.org>.

=head1 COPYRIGHT

Copyright (C) 2008, Viacheslav Tikhanovskii.

This program is free software, you can redistribute it and/or modify it under
the same terms as Perl 5.10.

=cut
