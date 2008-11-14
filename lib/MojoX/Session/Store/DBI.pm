package MojoX::Session::Store::DBI;

use strict;
use warnings;

use base 'MojoX::Session::Store';

use MIME::Base64;
use Storable qw/nfreeze thaw/;

__PACKAGE__->attr('dbh', chained => 1);

sub create {
    my ($self, $sid, $expires, $data) = @_;

    $data = encode_base64(nfreeze($data)) if $data;

    my $sth = $self->dbh->prepare(
        "INSERT INTO session (sid,expires,data) VALUES (?,?,?)");

    return $sth->execute($sid, $expires, $data);
}

sub update {
    my ($self, $sid, $expires, $data) = @_;

    $data = encode_base64(nfreeze($data)) if $data;

    my $sth = $self->dbh->prepare(
        "UPDATE session SET expires=?,data=? WHERE sid=?");

    return $sth->execute($expires, $data, $sid);
}

sub load {
    my ($self, $sid) = @_;

    my $sth = $self->dbh->prepare("SELECT * FROM session WHERE sid=?");
    my $rv = $sth->execute($sid);
    return unless $rv;

    my $result = $sth->fetchrow_hashref;
    return unless $result;

    $result->{data} = thaw(decode_base64($result->{data})) if $result->{data};

    return ($result->{expires}, $result->{data});
}

sub delete {
    my ($self, $sid) = @_;

    my $sth = $self->dbh->prepare("DELETE FROM session WHERE sid=?");
    return $sth->execute($sid);
}

1;
__END__

=head1 NAME

MojoX::Session::Store::DBI - DBI Store for MojoX::Session

=head1 SYNOPSIS

    CREATE TABLE session (
        sid          VARCHAR(32) PRIMARY KEY,
        data         TEXT,
        expires      INTEGER UNSIGNED NOT NULL,
        UNIQUE(sid)
    );

    my $session = MojoX::Session->new(
        store => MojoX::Session::Store::DBI->new(dbh  => $dbh),
        ...
    );

=head1 DESCRIPTION

L<MojoX::Session::Store::DBI> is a store for L<MojoX::Session> that stores
session in database.

=head1 ATTRIBUTES

L<MojoX::Session::Store::DBI> implements the following attributes.

=head2 C<dbh>
    
    my $dbh = $store->dbh;
    $store  = $store->dbh($dbh);

Get and set dbh handler.

=head1 METHODS

L<MojoX::Session::Store::DBI> inherits all methods from
L<MojoX::Session::Store>.

=head2 C<create>

Insert session to database.

=head2 C<update>

Update session in database.

=head2 C<load>

Load session from database.

=head2 C<delete>

Delete session from database.

=head1 AUTHOR

vti, C<vti@cpan.org>.

=head1 COPYRIGHT

Copyright (C) 2008, Viacheslav Tikhanovskii.

This program is free software, you can redistribute it and/or modify it under
the same terms as Perl 5.10.

=cut
