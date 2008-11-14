package NewDB;

use strict;
use warnings;

use DBI;
use File::Spec;

sub dbh {
    my $table = File::Spec->catfile(File::Spec->tmpdir, 'test.db');

    my $exists = -f $table;

    my $dbh = DBI->connect("dbi:SQLite:$table") or die $DBI::errstr;

    unless ($exists) {
        my $sth = $dbh->prepare(<<"");
            CREATE TABLE session (
                sid          VARCHAR(32) PRIMARY KEY,
                data         TEXT,
                expires      INTEGER UNSIGNED NOT NULL,
                UNIQUE(sid)
            );

        $sth->execute();
    }

    return $dbh;
}

1;
