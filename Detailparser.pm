#--- File Detailparser.pm ---

package Detailparser;
use strict;
use Exporter qw(import);
use HTML::TreeBuilder;
use LWP::UserAgent;
use Switch 'Perl 6';

our @EXPORT = qw(&parse_details);

sub parse_details
{
  my ($page, $torrent) = @_;
  my $root = HTML::TreeBuilder->new;
  $root->parse($page);

#  my ($title) = $root->look_down(_tag => 'div', id => 'title');
#  print $title->as_text();

  #For all children of 'dl' tags we extract the key and value of each element of the list
  my @dl_array = $root->look_down(_tag => 'dl');

  foreach my $dl (@dl_array){
    foreach my $dt ($dl->look_down(_tag => 'dt')){
      my $key = $dt->as_text();
      my $dd = $dt->right()->as_text();

      #We remove non printable characters
      $dd =~ s/[^!-~\s]//g;
      given ($key) {
	when ('Type:'){$torrent->{TYPE} = $dd}
	when ('Uploaded:'){$torrent->{DATE} = $dd}
	when ('By:'){$torrent->{AUTHOR} = $dd}
	when ('Leechers:'){$torrent->{LEECHERS} = $dd}
	when ('Seeders:'){$torrent->{SEEDERS} = $dd}
	when ('Size:'){$torrent->{SIZE} = $dd}
      }
    }
  }

  #Get the infos and remove all-space lines
  my ($nfo) = $root->look_down(_tag => 'div', class => 'nfo');
  $nfo = $nfo->as_text();
  $nfo =~ s/(^|\n)[\n\s]*/$1/g;
  $torrent->{INFO} = $nfo;

  $root->eof();
}
1;
