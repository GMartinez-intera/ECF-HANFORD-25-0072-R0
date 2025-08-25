#!/bin/perl
#
#

#use diagnostics;
use POSIX;
do "./textFileIOSub2.pl";

# FIELD DEFINITIONS

$nfR = 0;
$nfC = 1;
#$nfIBND = 18;
$nfWT13 = 9;
$nfCH_0 = 8;
$nfCH_1 = 7;
$nfBS_M = 6;
$nfBS_0 = 15;
$hsRA_6 = 14;
$hsRL_5 = 13;
$hsRE_4 = 12;
$hsRT_3 = 11;
$hsCC_2 = 10;
$hsHA_1 = 9;
$nf_SRF = 8;
$min_thk = 2.0;
$min_HSU = 2.0;
$pct_HSU_tol = 0.10;

$Channel_Bias_High = 2.0;

$HSU_TOLERANCE = 0.25;
$HSU_RATIO =  9.0;

###################END VARIABLES FOR PEST

$nr = 201;
$nc = 274;
$nl = 7;
$nrc = $nr*$nc;
$numHSU = 6;

##########  CREATE PROCESSING ARRAY INFORMATION
my @hsu_thk;
push @hsu_thk, [(0) x $numHSU];
my @hsu_top;
push @hsu_top, [(0) x $numHSU];
my @hsu_bot;
push @hsu_bot, [(0) x $numHSU];
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
my @pct;
push @pct, [(0.0) x $nrc] for 1 .. ($numHSU);
my @tpct;
push @tpct, [(0.0) x $nrc] for 1 .. ($numHSU);
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




######################

# Reading rows and columns from original dbf
# all of the dbf data gets passed back as a hash reference
# we dereference the hash and grab the values as an array

%dbfHT = %{ReadDBF("../grid_274_XY.dbf")};
@dbfAry = @{$dbfHT{"data"}};
@dbfNAry = @{$dbfHT{"field_names"}};

###################################  POPULATE PROCESSING ARRAYS  ########################################

foreach $j (0..($nrc-1)) {
  $irow = $dbfAry[$j][$nfR];
  $icol = $dbfAry[$j][$nfC];
  $lnode = (((($irow-1)*$nc)+$icol) -1);
  $thk[1][$lnode] = 0;
  $thk[2][$lnode] = 0;
  $thk[3][$lnode] = 0;
  $thk[4][$lnode] = 0;

#  $ibnd[$lnode] = $dbfAry[$j][$nfIBND]; 
  $top[$lnode] = $dbfAry[$j][$nf_SRF]; 
  $bslt[$lnode] = $dbfAry[$j][$nfBS_0]; 
  $bslt_min[$lnode] = $dbfAry[$j][$nfBS_M]; 
  $hiwt[$lnode] = $dbfAry[$j][$nfWT13]; 
  $chex[$lnode] = $dbfAry[$j][$nfCH_1]; 
  $thk[1][$lnode] += $dbfAry[$j][$hsHA_1]; 
  $thk[2][$lnode] += $dbfAry[$j][$hsCC_2]; 
  $thk[3][$lnode] += $dbfAry[$j][$hsRT_3]; 
  $thk[4][$lnode] += $dbfAry[$j][$hsRE_4]; 
  $thk[5][$lnode] += $dbfAry[$j][$hsRL_5]; 
  $thk[6][$lnode] += $dbfAry[$j][$hsRA_6]; 
  $totthk[$lnode] = $top[$lnode] - $bslt[$lnode];
  for ($i=1;$i<=$numHSU;$i++) {
    if ($thk[$i][$lnode] > $min_thk) {
      $sumthk[$lnode] += $thk[$i][$lnode];
    }
  }
}



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

###################  GET TOTAL PERCENTAGES and ELEVATION ###############################

for ($j=1;$j<=$nc;$j++) {
  for ($i=1;$i<=$nr;$i++) {
    $lnode = (((($i-1)*$nc)+$j)-1);
    $hsu_elev[0][$lnode] = $top[$lnode];
    if ($sumthk[$lnode] > 0) {
      for ($k=1;$k<=$numHSU;$k++) {
        if ($thk[$k][$lnode] > $min_thk) {
          $tpct[$k][$lnode] = $thk[$k][$lnode]/$sumthk[$lnode];
          $hsu_elev[$k][$lnode] = $hsu_elev[$k-1][$lnode] - ($tpct[$k][$lnode]*$totthk[$lnode]); 
         if ($i == 59 && $j == 130) {
            print "$k $i $j $bslt[$lnode] $sumthk[$lnode] $tpct[$k][$lnode] $hsu_elev[$k][$lnode]  $hsu_elev[$k-1][$lnode] $thk[$k][$lnode] \n" ;
         }
        } else {
          $hsu_elev[$k][$lnode] = $hsu_elev[$k-1][$lnode];
         if ($i == 59 && $j == 130) {
            print "$k $i $j $bslt[$lnode] $sumthk[$lnode] $tpct[$k][$lnode] $hsu_elev[$k][$lnode]  $hsu_elev[$k-1][$lnode] $thk[$k][$lnode] \n" ;
         }
        }
      }
    }
  }
}

# Print out Ref Files

print "TOP HSU ELEVATION 1\n";
open(OUTFIL,">hsu_top1\.ref");
WriteN(OUTFIL,10,$nc,@hsu_elev[0]);
close(OUTFIL);
for($l=1;$l<=$numHSU;$l++) {
   print "BOT HSU ELEVATION $l \n";
   open(OUTFIL,">hsu_bot$l\.ref");
   WriteN(OUTFIL,10,$nc,@hsu_elev[$l]);
   close(OUTFIL);
   $p = $l + 1;
   print "TOP HSU ELEVATION $p \n";
   open(OUTFIL,">hsu_top$p\.ref");
   WriteN(OUTFIL,10,$nc,@hsu_elev[$l]);
   close(OUTFIL);
}


#unshift (@myAry,\@dbfNAry); #field names are the first reference in the


							   #array that gets passed to the output sub
							   
#DumpDBF("head.dbf",\@myAry);  #write the array to a file called head.dbf



sub ReadDBF {
	use strict;
	use warnings;
	my ($fileName) = @_;
	use DBD::XBase;
  	my $table = new XBase $fileName or die XBase->errstr;
	my @fnames = $table->field_names();
	my @rtnAry;
	my %rtnHT;
  	for (0 .. $table->last_record) {
        my ($deleted, @ary )
                = $table->get_record($_);
        $rtnAry[$_]=\@ary;
  	}
	$rtnHT{"data"} = \@rtnAry;
	$rtnHT{"field_names"} = \@fnames;
	return \%rtnHT;	
}

sub DumpDBF { #filename, 2DarrayPtr
	use strict;
	my ($fileName,$aryPtr,$typePtr,$lenPtr,$decPtr,@dataAry,@fNames,$numFields,@fTypes,@fLengths,@fDecs);
	my ($i,$newtable,$recNum,@dataLine);
	($fileName,$aryPtr,$typePtr,$lenPtr,$decPtr) = @_;
	use DBD::Xbase;
	
	@dataAry = @{$aryPtr};
	@fNames = @{$dataAry[0]};
	
	
	$numFields = scalar @fNames;
	if($typePtr) {
		@fTypes = @{$typePtr};
	} else {
		@fTypes = split(/,/,("N,"x($numFields-1))."N");
	}
	if($lenPtr) {
		@fLengths = @{$lenPtr};
	} else {
		@fLengths = split(/,/,("25,"x($numFields-1))."25");
	}
	if($decPtr) {
		@fDecs = @{$decPtr};
	} else {
		@fDecs = split(/,/,("15,"x($numFields-1))."15");
	}

	unlink($fileName);
	my $newtable = XBase->create("name" => "$fileName",
   	             "field_names" => [ (@fNames) ],
   	             "field_types" => [ (@fTypes) ],
   	             "field_lengths" => [ (@fLengths) ],
   	             "field_decimals" => [ (@fDecs) ]) or die "Cannot create $fileName\n";

	$i=0;
	foreach $recNum (1..$#dataAry) {
	
		@dataLine = @{$dataAry[$recNum]};
                
		#	print join(",",@fNames)."\n";
		#print join(",",@dataLine)."\n";
		$newtable->set_record($i,@dataLine);
                
		$i++;
	}

undef $newtable;
}
sub log10 {
  my $n = shift;
  return log($n)/log(10);
}
