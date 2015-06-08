# --- file Details.pm ---
package Details;
use strict;

#Class for each torrents
sub new
{
    my ($class, $info, $date, $author, $seeders, $leechers, $size, $comments) = @_;
    my $this = {};
    bless ($this, $class);
    $this->{INFO} = $info;
    $this->{DATE} = $date;
    $this->{AUTHOR} = $author;
    $this->{SEEDERS} = $seeders;
    $this->{LEECHERS} = $leechers;
    $this->{SIZE} = $size;
    $this->{COMMENTS} = $comments;

    return $this;
}
1;
