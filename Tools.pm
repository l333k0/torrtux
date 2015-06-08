# --- file Tools.pm ---
package Tools;
use strict;
use LWP::Simple;
use LWP::UserAgent;
use Exporter;
use Configfile;
use Term::ANSIColor qw(:constants);
$Term::ANSIColor::AUTORESET = 1;

our @ISA = qw(Exporter);
our @EXPORT = qw(&get_input &page_dwnld &download $page_n $site);
#my $sort = 7;
our $page_n = 0;
our $site = read_filerc()->site;


sub get_input{
    my $input = <STDIN>;
    $input =~ s/\n//g;

    return $input;
}

sub page_dwnld
{
    my $research = shift;
    my $choice = shift;
    my $url = shift;
    my $sort = shift;
    my $ua = LWP::UserAgent->new();
    $ua->agent("Mozilla");
    $ua->show_progress('TRUE');
    if($choice == 1){
    	my $r = $ua->get($site."/search/$research/$page_n/$sort/0");
	$page_n += 1;
	return $r->decoded_content();
    }
    elsif($choice == 2){
	my $r = $ua->get($url);
	return $r->decoded_content();
    }

}
1;
