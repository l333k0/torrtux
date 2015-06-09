# --- file Getinfos.pm ---
package Getinfos;
use strict;
use Torrent;
use Exporter;
use Configfile;
use Tools;
use Opensubs;
use HTML::TreeBuilder;
use Term::ANSIColor qw(:constants);
$Term::ANSIColor::AUTORESET = 1;
our @ISA = qw(Exporter);
our @EXPORT = qw(&get_and_display_infos &display_magnetic_link);


sub torrents_list{
  my $torrent = shift;
  my $compact = shift;
  my $return;
  if($compact){
    $return = GREEN " $torrent->{SEEDERS}". RED " $torrent->{LEECHERS}".WHITE " $torrent->{GENRE}". CLEAR BLUE BOLD" $torrent->{NAME}". DARK GREEN " $torrent->{AUTHOR}";
  }
  else{
    $return = "\t$torrent->{SEEDERS}\t$torrent->{LEECHERS}\t$torrent->{GENRE}\t" . CLEAR BLUE BOLD . "$torrent->{NAME}\n" . "\t"x4 . RESET GREEN "ULed by $torrent->{AUTHOR}\n";
  }
  return $return;
}

sub get_and_display_infos
{
  my $page = shift;
  my $table_magnets = shift;
  my $urls_details = shift;
  my $compact = shift;

  my $torrent = Torrent->new;
  my $i = 0;
  my $root = HTML::TreeBuilder->new;
  $root->parse($page);

  my @tr = $root->look_down(_tag => 'tr');

  foreach my $tor (@tr){
    unless(defined $tor->attr('class') && $tor->attr('class') eq "header"){
      $i += 1;
      $torrent->{GENRE} = $tor->look_down(_tag => 'a', title => "More from this category")->as_text();

      my $detName = $tor->look_down(_tag => 'div', class => "detName");
      my $link_array = $detName->extract_links();
      my $link = @$link_array[0];
      $urls_details->[$i] = $site.@$link[0];
      $torrent->{NAME} = $detName->as_text();

      $table_magnets->[$i] = $tor->look_down(_tag => 'a', href => qr/^magnet.*/)->attr('href');

      my $author = $tor->find_by_tag_name('font')->find_by_tag_name('a');
      if(defined $author){$torrent->{AUTHOR} = $author->as_text();}
      else {$torrent->{AUTHOR} = 'Anonymous';}

      my ($seeders, $leechers) = $tor->look_down(_tag => 'td', align => 'right');
      $torrent->{SEEDERS} = $seeders->as_text();
      $torrent->{LEECHERS} = $leechers->as_text();
      print BOLD YELLOW "\n$i";
      print torrents_list($torrent, $compact);
    }
  }
  $root->eof();
  return $i;
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
1;
