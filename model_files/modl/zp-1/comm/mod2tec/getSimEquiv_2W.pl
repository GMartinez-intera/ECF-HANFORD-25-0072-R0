#!/bin/perl
#

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
  
  
  


$nr = 244;
$nc = 232;
$nl = 7;
$nrc = $nr*$nc;

my @elev;
push @elev, [(0.0) x $nrc] for 1 .. ($nl+2);


my @kh;
push @kh, [(0.0) x $nrc] for 1 .. ($nl+1);

my @ibnd;
push @ibnd, [(0) x $nrc] for 1 .. ($nl+1);

@tmpE = ReadDelimFile("../model_top.ref",'\s+');
for ($j=1;$j<=$nc;$j++) {
  for ($i=1;$i<=$nr;$i++) {
    $lnode = (((($i-1)*$nc)+$j)-1);
    $elev[0][$lnode] = $tmpE[$lnode];
  }
}

for ($k=1;$k<=$nl;$k++) {
  @tmpK = ReadDelimFile("../hk_Layer_${k}.ref",'\s+');
  @tmpI = ReadDelimFile("../ibound_layer_${k}.ref",'\s+');
  @tmpE = ReadDelimFile("../botm_layer_${k}.ref",'\s+');
  for ($j=1;$j<=$nc;$j++) {
    for ($i=1;$i<=$nr;$i++) {
      $lnode = (((($i-1)*$nc)+$j)-1);
      $ibnd[$k][$lnode] = $tmpI[$lnode];
      $kh[$k][$lnode] = $tmpK[$lnode];
      $elev[$k][$lnode] = $tmpE[$lnode];
    }
  }
}


  
$blnFirst = 1;  
#read well screen information
@aRefs = ReadDelimFileAoA("Extraction_WELL_Screen_Info.txt",'\s+');

$numWell=0;
foreach $aRef (@aRefs[0..$#aRefs]) {
  if ($blnFirst == 0) {
    ($wellnum,$tmpWellID,$tmpX,$tmpY,$tmp_TOP, $tmp_BOT,$tmpTWEL, $tmpBWEL, $tmpI, $tmpJ) = @{$aRef};
    $numWell++;
    $wellID[$numWell] = $tmpWellID;
    $well_name{$tmpWellID} = $wellnum;
    $scr_top{$tmpWellID} = $tmp_TOP;
    $scr_bot{$tmpWellID} = $tmp_BOT;
    $well_row{$tmpWellID} = $tmpI;
    $well_col{$tmpWellID} = $tmpJ;
  }
  $blnFirst = 0;
}


#  find transmissivity for screen intervals
for ($iii=1;$iii<=$numWell;$iii++) {
  $lnode = (((($well_row{$wellID[$iii]}-1)*$nc)+$well_col{$wellID[$iii]})-1);
  $tmpWellID = $wellID[$iii];
  $tScr = $scr_top{$tmpWellID};
  $bScr = $scr_bot{$tmpWellID};
 
  
    print "$tmpWellID  $tScr $bScr $lnode $well_col{$wellID[$iii]} $well_row{$wellID[$iii]}  \n";

  for ($kkk=1;$kkk<=$nl;$kkk++) {
    $tCel = $elev[$kkk-1][$lnode]; 
    $bCel = $elev[$kkk][$lnode]; 
    if ($tScr <= $tCel && $bScr >= $bCel) {
      $tran{$tmpWellID}[$kkk] = ($tScr - $bScr) * $kh[$kkk][$lnode]; 
    } elsif ($tScr >= $tCel && $bScr <= $bCel) {
      $tran{$tmpWellID}[$kkk] = ($tCel - $bCel) * $kh[$kkk][$lnode]; 
    } elsif (($tScr <= $tCel && $tScr >= $bCel) && ($bScr <= $bCel)) {  #' top of screen is within cell
      $tran{$tmpWellID}[$kkk] = ($tScr - $bCel) * $kh[$kkk][$lnode];
    } elsif (($bScr <= $tCel && $bScr >= $bCel) && ($tScr >= $tCel)) {  #' bot of screen is within cell
      $tran{$tmpWellID}[$kkk] = ($tCel - $bScr) * $kh[$kkk][$lnode];
    } elsif (($bScr >= $tCel && $tScr >= $tCel)) {  #' everything above
      $tran{$tmpWellID}[$kkk] = 0.0;
    } elsif (($bScr <= $bCel && $tScr <= $bCel)) {  #' everything below
      $tran{$tmpWellID}[$kkk] = 0.0;
      if ($kkk == $nl) {
        $tran{$tmpWellID}[$kkk] = 1.0;
      }
    }   
   # print "$tmpWellID  $kkk $tran{$tmpWellID}[$kkk] $tCel $bCel Elevs Here \n";
  }
}



#read model results
@aRefs = ReadDelimFileAoA("P2R_InjExt_hds.out",'\s+');

$i=0;
foreach $aRef (@aRefs[0..$#aRefs]) {
  ($wellnum,$date,$time,$head_obs) = @{$aRef};
  $tmpWellID = uc(substr($wellnum,0,length($wellnum)-2));
  $tmpLayer = substr($wellnum,length($wellnum)-1,length($wellnum)) + 0;
  $num_date = $date+0.0;
  $form_date = sprintf("%.5f", $num_date);
  # print "$wellnum  $tmpWellID   $tmpLayer    $head_obs\n";
  
  if (($head_obs != "dry_or_inactive") && ($head_obs != "not_in_grid") && ($head_obs < 1e+25)) {
    $head{$tmpWellID}{$form_date}[$tmpLayer] = $head_obs;
  } else {
    $head{$tmpWellID}{$form_date}[$tmpLayer] = -99999.00;
  }
  $i++;
}


open(OUTFIL,">P2R_hds_2W.smp");
$aCount=0;
@aRefs = ReadDelimFileAoA("P2R_InjExt_tpl.smp",'\s+');
foreach $aRef (@aRefs[0..$#aRefs]) {
  $aCount++;
  if ($aCount == 1) {
    printf OUTFIL "@{$aRef} \n";
  } else { 
  ($wellnum,$date,$time) = @{$aRef};
  $num_date = $date+0.0;
  $form_date = sprintf("%.5f", $num_date);

  $tmpAvg = 0;
  $tmpTran = 0;
  $totTran = 0;
  for ($kkk=1;$kkk<=$nl;$kkk++) {
    if ($head{$wellnum}{$form_date}[$kkk] != -99999.0) {
      if ($tran{$wellnum}[$kkk] > 0.0) {
        print "$wellnum $form_date $kkk   $head{$wellnum}{$form_date}[$kkk]    $tran{$wellnum}[$kkk]  \n";
        
        $tmpTran = $tran{$wellnum}[$kkk];
        $totTran += $tmpTran; 
        $tmpAvg += $head{$wellnum}{$form_date}[$kkk] * $tmpTran; 
      }
    }
  }

  if ($totTran > 0) {
    $tmpAvg = $tmpAvg/$totTran;
  } else {
    $tmpAvg = 0.0;
  }
  
  printf OUTFIL "$wellnum     $form_date   $time    %14.9f\n", $tmpAvg; 
  }
}
close(OUTFIL);
print "Finished\n";

