#!/bin/perl
#
#

#use diagnostics;
use POSIX;
use File::Copy qw(copy);

# FIELD DEFINITIONS

$fileIn = $ARGV[0];
$fileOut = $ARGV[1];
$base_Time = $ARGV[2];

$min_THICK = 5;
$min_HSU = 2;
$RLM = 5;
$RA = 6;

$nr = 236;
$nc = 304;
$nl = 8;
$nfields = 16;
$nrc = $nr*$nc;
$min_thk = 4.0;
$chan_zone = 9;
$numHSU = 6;


$cnt=0;
$blnFirst = 0;


$dirname = $fileIn;
opendir(DIR, $dirname);
while ($filename  = readdir(DIR)) {
  #print substr($filename,-8);
  
  if (substr($filename,-8) eq '_hss.dat') {
    $readname = $dirname . '/' . $filename;
    print "$readname\n";
    open(INFIL,"<$readname");
    $cnt=0;
    $tmpname = $fileOut . '/' . $filename;
    open(TMPFIL,">$tmpname");
    
    while (<INFIL>) { 					   
      $theStr = $_;
      $theStr =~ s/\n//g;
      ($new_Time,$tmpZero,$newVal) = split(/\s+/,$theStr);
      
      $old_Time = $old_Time - $base_Time;

      if ($new_Time > $base_Time) {
          $outVal = $oldVal;
          if ($old_Time < 0) {
             $old_Time = 0.0;
          }
          printf TMPFIL "$old_Time 0 $outVal\n";
      }
      $old_Time = $new_Time;
      $oldVal = $newVal;

      $cnt++;
    }
    printf TMPFIL "$new_Time 0 $newVal\n";
    close(INFIL);
    close(TMPFIL);
    
  }
}
closedir(DIR);



