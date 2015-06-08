# --- file Getinfos.pm ---
package Getinfos;
use strict;
use Torrent;
use Exporter;
use Configfile;
use Tools;
use Opensubs;
use Term::ANSIColor qw(:constants);
$Term::ANSIColor::AUTORESET = 1;
our @ISA = qw(Exporter);
our @EXPORT = qw(&get_author_torrent &get_genre_torrent &get_url_torrent &get_seeds_leechers_torrent &get_urls_details &display_magnetic_link);


#Function for getting the torrent author
sub get_author_torrent
{
    my $line = shift;
    my $torrent = shift;
    ($torrent->{AUTHOR}) = ($line =~ m/ULed by \<.*\>(.+)\<\/[ia]/);

    return 0;
}

#Function for getting the torrent genre
sub get_genre_torrent
{
    my $line = shift;
    my $torrent = shift;
    ($torrent->{GENRE}) = ($line =~ m/\"More from this category\"\>(\w+)\</);

    return 0;
}

#Function for getting the torrent url
sub get_url_torrent
{
    my $table_urls = shift;
    my $line = shift;
    my $i = shift;
# my ($torrent_url) = ($line =~ m/href=\"(http:\/\/torrents\.thepiratebay\.se[^\"]*)/);
    my ($torrent_url) = ($line =~ m/href=\"(magnet[^\"]*)/);

    $table_urls->[$i] = $torrent_url; 
}

#Function for getting the details url
sub get_urls_details
{
    my $table_details = shift;
    my $line = shift;
    my $i = shift;
# my $site = read_filerc()->site;
#my $site = "http://thepiratebay.se";
#my $site = read_filerc()->site;

    my ($detail_url) = ($line =~ m/href=\"([^\"]*)\"/);
    $table_details->[$i] = $site.$detail_url;
}


sub get_seeds_leechers_torrent
{
    my $line = shift;
    my $torrent = shift;
    ($torrent->{SEEDERS}, $torrent->{LEECHERS}) = ($line =~ m/\<td align=\"right\"\>(\d+)\<\/td\>/g);

#my @retour = ($seeds, $leechers);
    return 0;
}

sub display_magnetic_link
{
    my $urls = shift;
    my $forsubs = shift;
    my ($choice,$subname);
    my $subsearchactivated = read_filerc()->subs;
    print CLEAR BLUE BOLD "Which torrent ?\n" . BOLD YELLOW "==> ";
    $choice = <STDIN>;
    print "$urls->[$choice]\n";
    system("echo \"$urls->[$choice]\" | xclip -in -selection clipboard");
    print CLEAR BLUE BOLD "Magnet link copied in the clipboard.\nOpen your torrent manager ? (Y/n)\n" . BOLD YELLOW "==> ";
    my $choice2 = get_input();
    if($choice2 ne "n"){
	launch_torrent_prog($urls->[$choice]);
    }
    if($subsearchactivated eq "yes"){
	($subname) = ($forsubs->[$choice] =~ m/^.*\/(.*)/g);
	print CLEAR BLUE BOLD "Search subtitles for $subname on opensubtitles.org ? (y/n)\n". BOLD YELLOW "==> ";
	my $choicesub = get_input();
	if($choicesub eq "y"){
	    search_dwnld($subname);
	}
    }

}
