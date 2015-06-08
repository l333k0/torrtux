# --- file Opensubs.pm ---
package Opensubs;
use strict;
use LWP::Simple;
use XML::RPC;
use File::Basename;
use IO::Uncompress::Gunzip qw(gunzip $GunzipError) ;
use Configfile;

use Term::ANSIColor qw(:constants);
$Term::ANSIColor::AUTORESET = 1;

binmode(STDOUT, ":utf8");
our @ISA = qw(Exporter);
our @EXPORT = qw(&search_dwnld);
my $USER_AGENT = "torrtux v1.0";

sub search_dwnld
{
    my $film = shift;
    my $season;
    my $episode;
    my @links = ();
    my $nb;
    my $token;
    my $comp = 0;
    my $sublanguage = read_filerc()->langsubs;
    $token = login();

    if(!$sublanguage){
	$sublanguage = "eng";
    }

    my @args = [ { 'sublanguageid' => $sublanguage, 'query' => $film, 'season' => $season, 'episode' => $episode} ];

    my $xmlrpc = XML::RPC->new('http://api.opensubtitles.org/xml-rpc');
    my $data = $xmlrpc->call('SearchSubtitles', $token->{token}, @args);
    my @tab = $data->{data};
    if(!$data->{data}){
	print "No subs\n";
	return -1;
    }

    for my $i (@tab){
	for my $j (@$i){
	    $comp++;
	    print YELLOW BOLD $comp." ". RESET $j->{SubFileName}.GREEN BOLD "  ===> ".$j->{SubLanguageID}."\n";
	    push(@links,$j->{SubDownloadLink});
	}
    }
    print YELLOW BOLD "==> ";
    $nb = <STDIN>;
    $nb =~ s/\n//g;
    if(!($nb =~ m/^\d+$/)){
	print "Not a number !";
	return 0;
    }
    print $links[$nb-1];
    my $input = get($links[$nb-1]);
    gunzip \$input => "$film.srt" 
	or die "gunzip failed: $GunzipError\n";
}

sub login{
    my $xmlrpc = XML::RPC->new('http://api.opensubtitles.org/xml-rpc');
    my $log = $xmlrpc->call('LogIn', '', '', '',  $USER_AGENT );
    print BLUE BOLD $log->{status}."\n";
    return $log;
}

