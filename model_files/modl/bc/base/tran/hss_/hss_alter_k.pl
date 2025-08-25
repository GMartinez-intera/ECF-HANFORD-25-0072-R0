#!/bin/perl
#
#

#use diagnostics;
use POSIX;
  #reads an entire space delimited file and returns it as an array
  #note that if the delimiter is of the type \s+ or the like, use single
  #quotes in the call. I don't know why double quotes don't work 
  sub ReadDelimFile {#filename (i.e. "myfile.txt"), delimiter
      (my $fileName, my $delim) = @_;
      my @valArray;
      my $theStr;

      open(INFIL,$fileName) or die "$fileName not found.\n";
      while(<INFIL>) {
        $theStr = $_;
        $theStr=~s/\n//;$theStr=~s/\r//;$theStr=~s/^\s+//;$theStr=~s/\s+$//;
        push @valArray,split(/$delim/,$theStr);
      } 
      return @valArray;
  }


  #this sub returns an array of references, each reference pointing to an array
  #which contains the elements of one line of the file
  sub ReadDelimFileAoA {#filename (i.e. "myfile.txt"), delimiter
      (my $fileName, my $delim, my $skipOneBoo) = @_;
      my @refArray;
      my $theStr;

      open(INFIL,$fileName) or print "ReadDelimFileAoA Warning: $fileName not found.\n";
      if($skipOneBoo) {
	      <INFIL>;
      }
      while(<INFIL>) {
        $theStr = $_;
        $theStr=~s/\n//;$theStr=~s/\r//;$theStr=~s/^ +//;$theStr=~s/ +$//;
        my @tmpArray = split(/$delim/,$theStr);
        push @refArray,\@tmpArray;
      } 
      return @refArray;
  }
  



# FIELD DEFINITIONS

$fileIn = $ARGV[0];
$fileSat = $ARGV[1];
$fileOut = $ARGV[2];

$nr = 236;
$nc = 304;
$nl = 8;
$nrc = $nr*$nc;

my @sat_lay;
push @sat_lay, [(0.0) x $nrc] ;

@tmpS = ReadDelimFile($fileSat,'\s+');

for ($j=1;$j<=$nc;$j++) {
  for ($i=1;$i<=$nr;$i++) {
    $lnode = (((($i-1)*$nc)+$j)-1);
    $sat_lay[$lnode] = $tmpS[$lnode];
  }
}


open(OUTFIL,">$fileOut");
@aRefs = ReadDelimFileAoA("$fileIn",'\s+');
$blnFirst=1;
$numline=0;
$oldID = 0;
foreach $aRef (@aRefs[0..$#aRefs]) {
  if ($numline == 0) {
    ($tmpK,$tmpI,$tmpJ,$tmpStp) = @{$aRef};
    $tmpMaxHSS = $tmpJ *3;
    print OUTFIL "$tmpK $tmpI $tmpMaxHSS NoRunHSSM\n";
  } elsif ($numline == 1) {
    print OUTFIL "  1  1  1\n";
  } elsif ($numline == 2) {
    print OUTFIL "@{$aRef}\n";
  } elsif (($numline % 2) == 0) {
    ($tmpK,$tmpI,$tmpJ,$tmpStp) = @{$aRef};
    $lnode = (((($tmpI-1)*$nc)+$tmpJ)-1);
    # if sat_lay is equal to zero find the next non-zero cell to the south
    if ($sat_lay[$lnode] != 0) {  
      print OUTFIL "$sat_lay[$lnode] $tmpI $tmpJ 1 COPC\n";
    } else {
      $tmp_sat_lay = $sat_lay[$lnode];
      $new_row = $tmpI;
      while ($tmp_sat_lay == 0) {
        $new_row = $new_row+1;
        $lnode = (((($new_row-1)*$nc)+$tmpJ)-1);
        $tmp_sat_lay = $sat_lay[$lnode];
      }
      print OUTFIL "$tmp_sat_lay $new_row $tmpJ 1 COPC\n";
    }
  } else {
    print OUTFIL "@{$aRef}\n";
  }
  $numline++;
}
close(OUTFIL);

