# --- file Configfile.pm ---
package Configfile;
use strict;

use AppConfig qw(:expand :argcount);
use Exporter;

our @ISA = qw(Exporter);
our @EXPORT = qw(&read_filerc &launch_torrent_prog);

#Read the config file and return the favourite torrent manager
sub read_filerc{
    my $config = AppConfig->new(
	    'site' => {ARGCOUNT => ARGCOUNT_ONE},
	    'torrent_client' => {ARGCOUNT => ARGCOUNT_ONE},
	    'subs' => {ARGCOUNT => ARGCOUNT_ONE},
	    'langsubs' => {ARGCOUNT => ARGCOUNT_ONE},
	    'comments' => {ARGCOUNT => ARGCOUNT_ONE},
	    'compact' => {ARGCOUNT => ARGCOUNT_ONE});
    my $home = $ENV{'HOME'};
    $config->file("$home/.torrtuxrc");
    return $config;
}

#Launch the favourite torrent manager
sub launch_torrent_prog{
    my $link = shift;
    my $name = read_filerc()->torrent_client;
    my $command = "";
    die("No config file in /~ or no torrent manager chosen !")
	if(!($name));
    if($name =~ m/rtorrent/)
    {
	$command = "$name \"$link\"";
    }
    else{
	$command = "$name \"$link\" > \/dev\/null 2>&1 &";
    }

#Launch
    system($command);
}



