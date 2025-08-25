#!/bin/perl
#

$nl = 8;
$nr = 236;
$nc = 304;
$nrc = $nr * $nc;
$iunit = 11;
$theFlag = "#";
$lcound = 0;

do "./textFileIOSub2.pl";

$ibsIn = $ARGV[0];
$ibsOut = $ARGV[1];

if(!$ibsOut) {die "Usage: reArraySSM.pl [templateFileIn] [ibsFileOut]\n";}

open(INFIL,$ibsIn) or die "Cannot open $ibsIn\n";
open(OUTFIL,">$ibsOut") or die "Cannot open $ibsOut for writing\n";
while(!eof(INFIL)) {
	$lastStr = EchoUntil(INFIL,OUTFIL,"$theFlag",1,1);
	($sep,$fileName,$layerText,$l) = split(/\s+/,$lastStr);
	$l=~s/\n//;$l=~s/\r//;
	if($sep eq $theFlag) {
		($varName) = split(/_/,$fileName);
		$lcount++;
		print "Processing $varName STRESS PERIOD: $lcount\n";
		open(ARYFIL,$fileName) or die "Cannot locate $fileName for reading array\n";
		$theRef = ReadN(ARYFIL,$nrc);
		close(ARYFIL);
		WriteN96(OUTFIL,10,$nc,$theRef,"$varName Layer $l",$iunit);
	} else {
		print OUTFIL $lastStr;
	}
}
close(INFIL);
close(OUTFIL);
