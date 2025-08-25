#!/bin/perl
#
#

#use diagnostics;
#use POSIX;
#do "./textFileIOSub2.pl";
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

$min_thk = 2.0;
$min_HSU = 2.0;
$pct_HSU_tol = 0.10;

$Channel_Bias_High = 2.0;

$HSU_TOLERANCE = 0.25;
$HSU_RATIO =  9.0;

###################END VARIABLES FOR PEST

$nr = 244;
$nc = 232;
$nl = 8;
$nrc = $nr*$nc;
$numHSU = 9;

##########  CREATE PROCESSING ARRAY INFORMATION
my @ibnd;
push @ibnd, [(0) x $nrc];
my @chex;
push @chex, [(0) x $nrc];
my @top;
push @top, [(0) x $nrc]; 
my @bslt;
push @bslt, [(0) x $nrc];
my @bslt_min;
push @bslt_min, [(0) x $nrc];
my @hiwt;
push @hiwt, [(0) x $nrc];
my @totthk;
push @totthk, [(0) x $nrc];
my @sumthk;
push @sumthk, [(0) x $nrc];
my @satthk;
push @satthk, [(0) x $nrc];
my @numlay;
push @numlay, [(0) x $nrc];
my @numlay_hsu;
push @numlay_hsu, [(0) x $nrc] for 1 .. ($numHSU);
my @thk;
push @thk, [(0) x $nrc] for 1 .. ($numHSU);
my @hsu_k;
push @hsu_k, [(0.0) x $nrc] for 1 .. ($numHSU);
my @hsu_top;
push @hsu_top, [(0.0) x $nrc] for 1 .. ($numHSU);
my @hsu_bot;
push @hsu_bot, [(0.0) x $nrc] for 1 .. ($numHSU);
my @zone;
push @zone, [(0.0) x $nrc] for 1 .. ($nl+1);


##########  CREATE MODEL ARRAYS

my @elev;
push @elev, [(0.0) x $nrc] for 1 .. ($nl+2);
my @fixed;
push @fixed, [(0) x $nrc] for 1 .. ($nl+1);
my @zone;
push @zone, [(0.0) x $nrc] for 1 .. ($nl+1);
my @ibnd_m;
push @ibnd_m, [(0) x $nrc] for 1 .. ($nl+1);
my @hsu;
push @hsu, [(0) x $nrc] for 1 .. ($nl+1);
my @tmphsu;
push @tmphsu, [(0) x $nrc] for 1 .. ($nl+2);


#  HSU ZONATION CODE
#  1 - Hanford
#  2 - Cold Creek
#  3 - Ringold Taylor Flat
#  4 - Ringold E
#  5 - Ringold MUD
#  6 - Ringold A


$fileOut = $ARGV[0];


#####################  RESET HIGH WATER TABLE WITH THE BASALT WHERE THE BASALT IS HIGHER ####################

for ($j=1;$j<=$nc;$j++) {
  for ($i=1;$i<=$nr;$i++) {
    $lnode = (((($i-1)*$nc)+$j)-1);
    if ($hiwt[$lnode] < $bslt[$lnode]) {
      $hiwt[$lnode] = $bslt[$lnode];
    }
    $satthk[$lnode] = $hiwt[$lnode] - $bslt[$lnode];
  }
}


@tmpE = ReadDelimFile("../top1.ref",'\s+');
for ($j=1;$j<=$nc;$j++) {
  for ($i=1;$i<=$nr;$i++) {
    $lnode = (((($i-1)*$nc)+$j)-1);
    $elev[0][$lnode] = $tmpE[$lnode];
  }
}
for ($k=1;$k<=$nl;$k++) {
  @tmpI = ReadDelimFile("../ibnd${k}.inf",'\s+');
  @tmpE = ReadDelimFile("../bot${k}.ref",'\s+');
  for ($j=1;$j<=$nc;$j++) {
    for ($i=1;$i<=$nr;$i++) {
      $lnode = (((($i-1)*$nc)+$j)-1);
      $ibnd[$k][$lnode] = $tmpI[$lnode];
      $elev[$k][$lnode] = $tmpE[$lnode];
      # print " $k $i $j $lnode $ibnd[$k][$lnode] $zone[$k][$lnode] $elev[$k][$lnode] $fixed[$k][$lnode]\n";
    }
  }
}

my @files = glob "./csv/*.txt";
$numloc=0;
foreach my $file (@files) {
  @aRefs = ReadDelimFileAoA("$file",',');
  $locID[$numloc] = $file;
  $lrow[$numloc] = substr($locID[$numloc],7,3)+0;
  $lcol[$numloc] = substr($locID[$numloc],10,3)+0;
  $llay[$numloc] = substr($locID[$numloc],14,1)+0;
  #print  "$locID[$numloc] $lrow[$numloc] $lcol[$numloc] $llay[$numloc] \n";
  $numdate=0;
  $blnFirst=1;
  $oldID = 0;
  foreach $aRef (@aRefs[0..$#aRefs]) {
    if($blnFirst == 0) {
      ($tmptim,$tmphead) = @{$aRef};
      #print "$tmptim     $tmphead\n";
      $date{$locID[$numloc]}[$numdate] = $tmptim;
      $head{$locID[$numloc]}[$numdate] = $tmphead+0.0;
      $numdate++;
    }
    $blnFirst=0;
  }
  $numloc++;
}

open(OUTFIL,">$fileOut");
printf OUTFIL "     10000        50\n"; 
for ($d=0;$d<$numdate;$d++) {
  $numchd = 0;
  for ($l=0;$l<$numloc;$l++) {
     $irow = $lrow[$l];
     $icol = $lcol[$l];
     $ilay = $llay[$l];
     $lnode = (((($irow-1)*$nc)+$icol)-1);
     if ($ibnd[$ilay][$lnode] != 0) {
       if ($d<($numdate-1)){
         if ($head{$locID[$l]}[$d+1] > $elev[$ilay][$lnode]){
           $numchd ++;
         }
       } else {
         if ($head{$locID[$l]}[$d] > $elev[$ilay][$lnode]){
           $numchd ++;
         }
       }
     }
  }
  printf OUTFIL "%10i                # sp - %5i     $date{$locID[0]}[$d]  \n",$numchd,($d+1); 
  for ($l=0;$l<$numloc;$l++) {
    $irow = $lrow[$l];
    $icol = $lcol[$l];
    $ilay = $llay[$l];
    $lnode = (((($irow-1)*$nc)+$icol)-1);
    if ($ibnd[$ilay][$lnode] != 0) {
       if ($d<($numdate-1)){
         if ($head{$locID[$l]}[$d+1] > $elev[$ilay][$lnode]){
           printf OUTFIL "%10i%10i%10i%10.4f%10.4f\n", $ilay, $irow, $icol, $head{$locID[$l]}[$d] , $head{$locID[$l]}[$d+1]; 
         }
       } else {
         if ($head{$locID[$l]}[$d] > $elev[$ilay][$lnode]){
           printf OUTFIL "%10i%10i%10i%10.4f%10.4f\n", $ilay, $irow, $icol, $head{$locID[$l]}[$d] , $head{$locID[$l]}[$d]; 
         }
       }
    }
  }
}
close(OUTFIL);

