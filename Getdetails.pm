package Getdetails;
use strict;
use LWP::Simple;
use LWP::UserAgent;

use Details;
use Tools;
use Configfile;
use Detailparser;
use Opensubs;

use Exporter qw(import);
use Switch 'Perl6';
use Term::ANSIColor qw(:constants);
$Term::ANSIColor::AUTORESET = 1;

binmode(STDOUT, ":utf8");
our @EXPORT = qw(&display_details);

#Function for displaying details
sub display_details
{

#Initation of the variables
    my $urls = shift;
    my $urls_download = shift;
    my ($number, $page, $choice, $choice_magnet);
    my $torrent = Details->new();
    my $searchsubactivated = read_filerc()->subs;
    my $comments = read_filerc()->comments;
    my $subname;
    my $prog = "torrtux";

    print CLEAR BLUE BOLD "For which torrent display details ?\n" . YELLOW BOLD "==> ";
    $number = <STDIN>;
    print BLUE BOLD "Getting ...\n";

#Get the page of the details
    $page = page_dwnld('', 2, $urls->[$number]); 

    parse_details($page, $torrent);
    print_details($torrent);
    if($comments eq "yes"){
	get_comments_details($page);
    }

    print CLEAR BLUE BOLD "Get the magnet link (Y/n) | return (r) | new search (s) ?\n" . BOLD YELLOW "==> ";
    $choice = get_input();

    if($choice eq "r"){
	$page_n -= 1;
	return 1;
    }

    elsif($choice eq "n"){
	exit(0);
    }
    
    elsif($choice eq "s"){
	exec $prog;
		die "$prog not found";
	}
	     

#Get the magnet link if asked 
    else{
	print CLEAR BLUE BOLD "\nMagnet link :\n" . RESET "$urls_download->[$number]\n";
	system("echo \"$urls_download->[$number]\" | xclip -in -selection clipboard");
	print CLEAR BLUE BOLD "Magnet link copied in the clipboard.\nOpen your torrent manager ? (Y/n)\n" . BOLD YELLOW "==> ";
	my $choice_magnet = get_input();
	if($choice_magnet ne "n"){
	    launch_torrent_prog($urls_download->[$number]);
	}
	if($searchsubactivated eq "yes"){
	    ($subname) = ($urls->[$number] =~ m/^.*\/(.*)/g);
	    print CLEAR BLUE BOLD "Search subtitles for $subname on opensubtitles.org ? (y/n)\n"; 
	    print YELLOW BOLD "==> ";
	    my $choicesub = get_input();
	    if($choicesub eq "y"){
		search_dwnld($subname);
	    }
	}
    }
    return 0;

}

#Function for printing details
sub print_details
{
    my $torrent = shift;
    print BLUE BOLD "-" x 30 . "INFOS" . "-" x 40 . "\n\n";
    print BOLD BLUE "\nType:\t\t" . RESET "$torrent->{TYPE}\t\t" . BOLD BLUE "Size:\t\t".RESET "$torrent->{SIZE}\n\n";
    print BOLD BLUE "Uploaded:\t".RESET "$torrent->{DATE}\t".BOLD BLUE "By:\t\t".RESET "$torrent->{AUTHOR}\n\n";
    print BOLD BLUE "Seeders:\t".RESET "$torrent->{SEEDERS}\t\t\t".BOLD BLUE"Leechers:\t".RESET "$torrent->{LEECHERS}\n\n";
    print $torrent->{INFO} . "\n\n";
}


#Function for getting comments
sub get_comments_details
{
    my $page = shift;
    my @table = split(/comment-\d+/, $page);
    my($author, $comment);
    foreach (@table){
	if($_ =~ m/class="comment"/)
	{
	    $_ =~ s/<script.*$|<\/div><\/div><\/div><\/div>.*//gs;
	    $_ =~ s/<\/div>/ENDCOMM/;
	    $_ =~ s/<[^>]*>|<div id="|">|&nbsp;//gs;
	    if (($author, $comment) = ($_ =~ /^[\W]*(.*CET:)\n(.*)ENDCOMM/s)){
		print BOLD YELLOW "Comment by: $author";
#	$comment =~ s/[\d{1}\t]+//g;
		$comment =~ s/1 2.*//g;
		print RESET "$comment";
	    }
	}
    }
}
1;
