# --- file Torrent.pm ---
package Torrent;
use strict;

sub new
{
    my ($class, $name, $seeders, $author, $genre, $leechers) = @_;
    my $this = {
	"LEECHERS" => $leechers,
	"NAME"     => $name,
	"SEEDERS"  => $seeders,
	"AUTHOR"   => $author,
	"GENRE"    => $genre
    };
    bless ($this, $class);

    return $this;
}
1;
