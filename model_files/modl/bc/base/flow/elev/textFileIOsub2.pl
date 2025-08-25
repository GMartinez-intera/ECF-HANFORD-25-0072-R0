#functions in this subroutine
#  sub SkipLines { #filehandle,numlines
#  sub SkipUntil { #filehandle, matchstring
#  sub EchoUntil { #srcFileHandle, dstFileHandle, matchstring 
#  sub EchoLines { #srcFileHandle, dstFileHandle, numLines
#  sub ReadN { #filehandle,number of values
#  sub ReadN96 { #filehandle, number of values
#  sub ReadN2k { #checks for "CONSTANT" and "INTERNAL" and handles accordingly
#  sub ReadDelimFile {#filename (i.e. "myfile.txt"), delimiter
#  sub ReadDelimFileAoA {#filename (i.e. "myfile.txt"), delimiter
#  sub WriteN {#filehandle, floats per row, columns per row, array
#  sub WriteNint {#filehandle, floats per row, columns per row, array 
#  sub Readcbb { #filehandle, numSPs
#  sub Readhead { #filehandle, numLayers, numSPs
#  sub Readghb { #filename
#  sub Min
#  sub Max
#

  #skips n lines 
  sub SkipLines { #filehandle,numlines
    (my $filehandle,my $numLines) = @_;
    my @retAry;
    for(my $i=0;$i<$numLines;$i++) {
       $theStr = <$filehandle>;
       push @retAry,$theStr;
    } 
    return @retAry;
  }

  #skip until string is encountered
  sub SkipUntil { #srcFileHandle, matchstring 
    (my $srcFile,my $matchString,my $noWarning) = @_;
    my $theStr;
    my @retAry;
    while($theStr!~/$matchString/ && !eof($srcFile)) {
      $theStr = <$srcFile>;
       push @retAry,$theStr;
      if(eof($srcFile) && !$noWarning) {print "Warning SkipUntil: Could not find matching string\n";}
    }
    return @retAry;
  }

  #echo until string is encountered
  sub EchoUntil { #srcFileHandle, dstFileHandle, matchstring, lastLine, suppressWarning
    (my $srcFile,my $dstFile,my $matchString,my $nolastLine,my $suppressWarning) = @_;
    my $theStr;
    while($theStr!~/$matchString/ && !eof($srcFile)) {
      print $dstFile $theStr;
      $theStr = <$srcFile>;
      if(eof($srcFile) && !$suppressWarning) {print "Warning EchoUntil: Could not find matching string\n";}
    }
    if(!$nolastLine) {print $dstFile $theStr;} 
    return $theStr;
  }
   
  #echos lines from one file to the other
  sub EchoLines { #srcFileHandle, dstFileHandle, numLines
    (my $srcFile,my $dstFile,my $numLines) = @_;
    my $theStr;
    if($numLines) {
      for(my $i=0;$i<$numLines;$i++) {
         $theStr = <$srcFile>;
         print $dstFile $theStr; 
      } 
    }
    else {
      while(<$srcFile>) {
         $theStr = $_;
         print $dstFile $theStr;
      }
    }
    return $theStr;
  } 

  #reads n space delimited values from the given file and returns an array
  #of the values
  sub ReadN { #filehandle,number of values, delim
    (my $filehandle,my $numVal,my $delim) = @_;
    my @valArray;
    my @tempVal;
    my $theStr;
    if($delim eq '') {$delim='\s+';}

    while($#valArray < ($numVal-1) && !eof($filehandle)) { 
      $theStr = <$filehandle>;
      $theStr=~s/\n//;$theStr=~s/\r//;$theStr=~s/^\s+//;$theStr=~s/\s+$//;
      @tempVal = split(/$delim/,$theStr);
      push @valArray, @tempVal;
    }

    if((scalar @valArray) != $numVal) {die "Uneven number of values from $filehandle\n".
                              (scalar @valArray)." $numVal $valArray[0] $valArray[$#valArray]\n";}  
    if($debugBoo) {print "$valArray[0] $valArray[$#valArray]\n";}
    return \@valArray;
  }
  
  #

  sub ReadN96 { #filehandle,number of values, delim
    (my $filehandle,my $numVal,my $delim) = @_;
    my @valArray;
    my @tempVal;
    my $theStr;
	my $constVal;
	my $i;
	my $iunit;
#
    if($delim eq '') {$delim='\s+';}
	$theStr = <$filehandle>;
	$iunit = substr($theStr,0,10)*1.0;
#
	if($iunit == 0) {
		$constVal = substr($theStr,10,10)*1.0;
		foreach $i (1..$numVal) {
			push @valArray,$constVal;
		}
	} else {
	    while($#valArray < ($numVal-1) && !eof($filehandle)) { 
	      $theStr = <$filehandle>;
	      $theStr=~s/\n//;$theStr=~s/\r//;$theStr=~s/^\s+//;$theStr=~s/\s+$//;
	      @tempVal = split(/$delim/,$theStr);
	      push @valArray, @tempVal;
	    }
	}

    if((scalar @valArray) != $numVal) {die "Uneven number of values from $filehandle\n".
                              (scalar @valArray)." $numVal $valArray[0] $valArray[$#valArray]\n";}  
    if($debugBoo) {print "$valArray[0] $valArray[$#valArray]\n";}
    return (\@valArray,$iunit);
  }


  sub ReadN2k { #filehandle,number of values, delim
    	(my $filehandle,my $numVal,my $delim) = @_;
    	my @valArray;
    	my $theStr;
    	my $strVal;
    	my $text;
    	my $mult;
    	my $val;

        $theStr = <$filehandle>;    	
  	if($theStr=~/CONSTANT/) {
		($text,$val) = split(/\s+/,$theStr);
		$strVal = "$val,"x$numVal;
		chop($strVal);
		@valArray = split(/,/,$strVal)
	} elsif ($theStr=~/INTERNAL/) {
		($text,$mult) = split(/\s+/,$theStr);
		@valArray=ReadN($filehandle,$numVal);
		if($mult != 1) {
			foreach $i (0..$#valArray) {
				$valArray[$i]*=$mult;
			}
		}
	} else { #probably MODFLOW-96, we'll just assume it
		@valArray=ReadN($filehandle,$numVal);	
	}
    	return \@valArray;
} 

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

sub ReadDelimFileAoAGrep {#filename (i.e. "myfile.txt"), delimiter
      (my $fileName, my $delim, my @texts) = @_;
      my @refArray;
      my $theStr;

      open(INFIL,$fileName) or print "ReadDelimFileAoA Warning: $fileName not found.\n";
      if($skipOneBoo) {
	      <INFIL>;
      }
      while(<INFIL>) {
        $theStr = $_;
	$flag = 0;
	foreach $matchText (@texts) {	
		if($theStr=~/$matchText/) {
			$flag = 1;
		}
	}
	if($flag) {
        	$theStr=~s/\n//;$theStr=~s/\r//;$theStr=~s/^\s+//;$theStr=~s/\s+$//;
        	my @tmpArray = split(/$delim/,$theStr);
        	push @refArray,\@tmpArray;
	}
      } 
      return @refArray;
  }


  #writes the array as space delimited floats to the given file
  sub WriteN {#filehandle, floats per row, columns per row, array
     (my $filehandle, my $fperRow, my $cperRow, my $valArrayPtr) = @_;
     my $leftOver = $cperRow % $fperRow;
     my @valArray = @{$valArrayPtr};
     $scalVal = (scalar @valArray);

     if($scalVal % $cperRow) {die "WriteN: $scalVal $cperRow Array dimension error\n";}
     my $totalRows = $scalVal / $cperRow;
     if($leftOver==0) {$leftOver=$fperRow;}
     $fstr = "%15.7e"x$fperRow;
     $fstr = "$fstr\015\012"x(($cperRow-$leftOver)/$fperRow);
     $fstr = "$fstr".("%15.7e"x$leftOver)."\015\012";
     $fstr = "$fstr"x$totalRows;
     print $filehandle sprintf($fstr,@valArray);   
 
  }

  #wrapper for 96 
  sub WriteN96 {
     	(my $filehandle, my $fperRow, my $cperRow, my $valArrayPtr, my $text, my $iunit) = @_;
	my @valArray = @{$valArrayPtr};
	my $i;
	$fperRow = 10;
	foreach $i (1..$#valArray) {
		if($valArray[$i] != $valArray[0]) {
			$outText = sprintf("%10u",$iunit)."     1.000(10E15.7)                   -1";
			$whiteSpc = " "x(56-length($outText));
			print $filehandle $outText.$whiteSpc.$text."\015\012";
			WriteN($filehandle,$fperRow,$cperRow,$valArrayPtr);
			return;
		}
	}
	$outText = sprintf("%10u%10.3e",0,$valArray[0])." (10E10.3)                  -1"; 
	$whiteSpc = " "x(56-length($outText));
	print $filehandle $outText.$whiteSpc.$text."\015\012"; 
	return;
  }

  #wrapper for 96 
  sub WriteNint96 {
     	(my $filehandle, my $fperRow, my $cperRow, my $valArrayPtr, my $text, my $iunit) = @_;
	my @valArray = @{$valArrayPtr};
	my $i;
	$fperRow = 25;
	foreach $i (1..$#valArray) {
		if($valArray[$i] != $valArray[0]) {
			$outText = sprintf("%10u",$iunit)."         1(25I3)                      -1";
			$whiteSpc = " "x(56-length($outText));
			print $filehandle $outText.$whiteSpc.$text."\015\012";
			WriteNint($filehandle,$fperRow,$cperRow,$valArrayPtr);
			return;
		}
	}
	$outText = sprintf("%10u%10u",0,$valArray[0])."(10I3)                      -1"; 
	$whiteSpc = " "x(56-length($outText));
	print $filehandle $outText.$whiteSpc.$text."\015\012"; 
	return;
  }

  #wrapper for mf2k
  sub WriteN2k {
     	(my $filehandle, my $fperRow, my $cperRow, my $arySize, my $valArrayPtr, my $text) = @_;
	my @valArray = @{$valArrayPtr};
	my $i;

	foreach $i (1..$#valArray) {
		if($valArray[$i] != $valArray[0]) {
			$outText = "INTERNAL 1.0 (free) 0";
			$whiteSpc = " "x(56-length($outText));
			print $filehandle $outText.$whiteSpc.$text."\015\012";
			WriteN($filehandle,$fperRow,$cperRow,$valArrayPtr);
			return;
		}
	}
	$outText = "CONSTANT $valArray[0]"; 
	$whiteSpc = " "x(56-length($outText));
	print $filehandle $outText.$whiteSpc.$text."\015\012"; 
	return;
  }

  sub WriteNint2k {
     	(my $filehandle, my $fperRow, my $cperRow, my $arySize, my $valArrayPtr, my $text) = @_;
	my $i;
	my @valArray = @{$valArrayPtr};

	foreach $i (1..$#valArray) {
		if($valArray[$i] != $valArray[0]) {
			$outText =  "INTERNAL 1 (free) 0";
			$whiteSpc = " "x(56-length($outText));
			print $filehandle $outText.$whiteSpc.$text."\015\012";
			WriteNint($filehandle,$fperRow,$cperRow,$valArrayPtr);
			return;
		}
	}
	$outText = "CONSTANT $valArray[0]"; 
	$whiteSpc = " "x(56-length($outText));
	print $filehandle $outText.$whiteSpc.$text."\015\012";
	return;
  }

  #writes the array as space delimited floats to the given file
  sub WriteNSpec {#filehandle, floats per row, columns per row, array
     (my $filehandle, my $fperRow, my $cperRow, my $spec, my @valArray) = @_;
     my $leftOver = $cperRow % $fperRow;
     $scalVal = (scalar @valArray);

     if($scalVal % $cperRow) {die "WriteN: $scalVal $cperRow Array dimension error\n";}
     my $totalRows = $scalVal / $cperRow;
     if($leftOver==0) {$leftOver=$fperRow;}
     $fstr = "$spec"x$fperRow;
     $fstr = "$fstr\n"x(($cperRow-$leftOver)/$fperRow);
     $fstr = "$fstr".("$spec"x$leftOver)."\n";
     $fstr = "$fstr"x$totalRows;
     print $filehandle sprintf($fstr,@valArray);   
 
  }

  #writes the array as space delimited ints to the given file
  sub WriteNint {#filehandle, floats per row, columns per row, array
     (my $filehandle, my $fperRow, my $cperRow, my $valArrayPtr) = @_;
     my $leftOver = $cperRow % $fperRow;
     my @valArray = @{$valArrayPtr};
     $scalVal = (scalar @valArray);

     if($scalVal % $cperRow) {die "WriteNint: $scalVal $cperRow Array dimension error\n";}
     my $totalRows = $scalVal / $cperRow;
     if($leftOver==0) {$leftOver=$fperRow;}
     $fstr = "%3d"x$fperRow;
     $fstr = "$fstr\015\012"x(($cperRow-$leftOver)/$fperRow);
     $fstr = "$fstr".("%3d"x$leftOver)."\015\012";
     $fstr = "$fstr"x$totalRows;
     print $filehandle sprintf($fstr,@valArray);   
 
  }


sub Readcbb { #filehandle, numSPs, unpackBoo, binType, matchStr
	use strict;
#	use warnings;
	(my $fileHandle, my $numSPs, my $unpackBoo, my $binType, my $matchStr) = @_; #binType == 3 is SURFACT
	my ($sp,$laheyBoo,$testLH,$data,$ts,$dims);
	our ($nr,$nc,$nl,$nrnc,$nrncnl,$headerText);
	my ($numBytes,$garbage);
	my @head=();
	my @allData=();
	my @dims=();
	my @testSUR=();
	my @floats=();

	if(eof($fileHandle)) {die "Readcbb: End of file encountered\n";}
	if($numSPs eq "") {$numSPs = 1;}
	if($unpackBoo eq "") {$unpackBoo = 1;}
	for($sp=1;$sp<=$numSPs;$sp++) {
		$laheyBoo = 0;
		read($fileHandle, $data, 4);
		$testLH = unpack("i1", $data);
		if($testLH == 44 || $testLH == 36) {
		  $laheyBoo = 1;
		}
		if($laheyBoo) {
		  read($fileHandle, $data, 4);
		  $ts = unpack("i1", $data);
		}
		else {
		  $ts = $testLH;
		}
		
		read($fileHandle, $data, 4); 
		$sp = unpack("i1", $data);
		#print "$ts $sp\n";

		if($binType == 3) {
			read($fileHandle, $data, 8); #SURFACT
			#@testSUR = unpack("f2",$data);
			#print join(",",@testSUR)."\n";
		}

		read($fileHandle, $data, 16);
		$headerText = unpack("a16", $data);
		#		print $headerText."\n";

		@dims=();
		
		read($fileHandle, $data, 12);
		@dims = unpack("i3", $data);
		#print join(",",@dims)."\n";

		if($laheyBoo) {
		  read($fileHandle, $garbage, 8); #lahey has some more cruft here
		}
		#now for the floats
		@floats=();
		
		$nc = $dims[0];
		$nr = $dims[1];
		$nl = $dims[2];

		$nrnc = $nr*$nc;
		$nrncnl = $nr*$nc*$nl;
		$numBytes = $nrncnl*4;
		read($fileHandle, $data, $numBytes);
		if($laheyBoo) {
		  read($fileHandle, $garbage, 4); #lahey has 4 footer bytes
		}
		
		if($matchStr) {
				if($headerText=~/$matchStr/) {
					@head = unpack("f$nrncnl", $data);
				}
		} elsif($unpackBoo) {
			@head = unpack("f$nrncnl", $data);
		}
		push @allData,@head
	} #sp
	return @allData;
}


#reads a single layer of heads from a modflow binary file
sub Readhead { #filehandle, numLayers, numSPs, unpackBoo
	use strict;
	#binType = 0 -- Vistas or "pure" binary
	#binType = 1 -- old PMWin, 1 byte of cruft at the start
	#binType = 2 -- Lahey, 4 bytes of cruft at the start

	(my $fileHandle,my $numLayers,my $numSPs, my $unpackBoo) = @_;
	my ($sp, $thesp, $binType,$binType,$binHex,$twoBits,$data,$ts,$dims,$headerText);
	my ($numBytes,$garbage,$layer);
	our ($nr,$nc,$nl,$nrnc,$nrncnl,$l);
	my @head = ();
	my @allData = ();
	my @dims = ();
	my @floats = ();
	if(eof($fileHandle)) {die "Readhead: End of file encountered\n";}
	if($unpackBoo eq "") {$unpackBoo = 1;}
	if(!$numSPs) {$numSPs = 1;}
	for($sp=1;$sp<=$numSPs;$sp++) {
		for($layer=1;$layer<=$numLayers;$layer++) {
			read($fileHandle, $twoBits, 2);
			$binHex = unpack("h4",$twoBits);
			if($binHex eq "c200") {
				$binType = 2; #lahey
			}
		        elsif(substr($binHex,2,2) eq "0b") {
				$binType = 1; #we think old pmwin	
			}	
			else {
				$binType = 0;
			}

			if($binType == 2) {
			  	read($fileHandle, $data, 2);
			  	read($fileHandle, $data, 4);
			  	$ts = unpack("i1", $data);
			}
			elsif($binType == 1) {
			  	read($fileHandle, $data, 4);
			  	$ts = unpack("i1", $data);
			}
			else {
			  	read($fileHandle, $data, 2);
			  	$data = $twoBits.$data;
			  	$ts = unpack("i1", $data);
			}
			
			read($fileHandle, $data, 4); 
			$thesp = unpack("i1", $data);
			read($fileHandle, $garbage, 8);
			
			#	print "$ts $thesp\n";
			
			read($fileHandle, $data, 16);
			$headerText = unpack("a16", $data);
#			print $headerText."\n";
			
			# dims contains the number of cols, then rows, then layer
			
			read($fileHandle, $data, 12);
			
			@dims = unpack("i3", $data);
			
#			print $dims[0]." ".$dims[1]." ".$dims[2]."\n";
			
			if($binType == 2) {
			  	read($fileHandle, $garbage, 8);
			}
			elsif ($binType == 1) {
			  	read($fileHandle, $garbage, 5);
				print unpack("h10",$garbage)."\n";
			}
			
			#now for the floats
			@floats=();
			$l = $dims[2];
			$nc = $dims[0];
			$nr = $dims[1];
			$nrnc = $nr*$nc;
			$numBytes = $nrnc*4;
			
			read($fileHandle, $data, $numBytes);
			
			if($binType == 2) {
			   read($fileHandle, $garbage, 4); #footer bytes
			}
			elsif($binType == 1) {
			   read($fileHandle, $garbage, 2); #footer bytes
			}
			
			if($unpackBoo) {
				@head = unpack("f$nrnc", $data);
			}
#			print "$head[0] $head[$#head]"."\n";

			push @allData,@head;
		} #layers
	} #sp
	return @allData;
 }

sub Readconc { #filehandle, numSPs, unpackBoo, matchStr
	use strict;
#	use warnings;
	(my $fileHandle, my $numSPs, my $unpackBoo, my $matchStr) = @_;
	my ($sp,$laheyBoo,$testLH,$data,$ts,$dims,$ntrans,$totTime);
	our ($nr,$nc,$nl,$nrnc,$nrncnl,$headerText);
	my ($numBytes,$garbage);
	my @head=();
	my @allData=();
	my @dims=();
	my @floats=();

	if(eof($fileHandle)) {die "Readcbb: End of file encountered\n";}
	if($numSPs eq "") {$numSPs = 1;}
	if($unpackBoo eq "") {$unpackBoo = 1;}
	for($sp=1;$sp<=$numSPs;$sp++) {
		$laheyBoo = 0;
		read($fileHandle, $data, 4);
		$testLH = unpack("i1", $data);
		if($testLH == 44 || $testLH == 36) {
		  $laheyBoo = 1;
		}
		if($laheyBoo) {
		  read($fileHandle, $data, 4);
		  $ntrans = unpack("i1", $data);
		}
		else {
		  $ntrans = $testLH;
		}

		read($fileHandle, $data, 4); 
		$ts = unpack("i1", $data);

		read($fileHandle, $data, 4); 
		$sp = unpack("i1", $data);

		read($fileHandle, $data, 4); 
		$totTime = unpack("f1", $data);
		#print "$ntrans $ts $sp $totTime\n";
		
		read($fileHandle, $data, 16);
		$headerText = unpack("a16", $data);
		#print $headerText."\n";

		@dims=();
		
		read($fileHandle, $data, 12);
		@dims = unpack("i3", $data);
		#print join(",",@dims)."\n";
		
		if($laheyBoo) {
		  read($fileHandle, $garbage, 8); #lahey has some more cruft here
		}
		#now for the floats
		@floats=();
		
		$nc = $dims[0];
		$nr = $dims[1];
		$nl = $dims[2];

		$nrnc = $nr*$nc;
		$numBytes = $nrnc*4;
		read($fileHandle, $data, $numBytes);
		if($laheyBoo) {
		  read($fileHandle, $garbage, 4); #lahey has 4 footer bytes
		}
		
		if($unpackBoo) {
			if($matchStr) {
				if($headerText=~/$matchStr/) {
					@head = unpack("f$nrnc", $data);
				}
			} else {
				@head = unpack("f$nrnc", $data);
			}
		}
		push @allData,@head
	} #sp
	return @allData;
}

sub Readchd {
	(my $fileHandle) = @_;
	my @lrcs = ();
	my @elevs = ();
	my @conds = ();
	$theStr = <$fileHandle>;
	$numCHDs = substr($theStr,0,10);
	foreach $aCHD (1..$numCHDs) {
		$theStr = <$fileHandle>;
		$l = substr($theStr,0,10);
		$r = substr($theStr,10,10);
		$c = substr($theStr,20,10);
		$l=~s/\s+//g;$r=~s/\s+//g;$c=~s/\s+//g;
		$elev1= substr($theStr,30,10);
		$elev2 = substr($theStr,40,10);
		push @lrcs,"$l $r $c";
		push @elevs1,$elev1;
		push @elevs2,$elev2;
	}
	return (\@lrcs,\@elevs,\@conds);
}

sub Readghb {
	(my $fileHandle) = @_;
	my @lrcs = ();
	my @elevs = ();
	my @conds = ();
	$theStr = <$fileHandle>;
	$numGHBs = substr($theStr,0,10);
	foreach $aGHB (1..$numGHBs) {
		$theStr = <$fileHandle>;
		$l = substr($theStr,0,10);
		$r = substr($theStr,10,10);
		$c = substr($theStr,20,10);
		$l=~s/\s+//g;$r=~s/\s+//g;$c=~s/\s+//g;
		$elev = substr($theStr,30,10);
		$cond = substr($theStr,40,10);
		push @lrcs,"$l $r $c";
		push @elevs,$elev;
		push @conds,$cond;
	}
	return (\@lrcs,\@elevs,\@conds);
}

sub Readcw5 { #filehandle, numSPs, unpackBoo
	use strict;
##	use warnings;
	(my $fileHandle, my $numSPs, my $unpackBoo) = @_;
	my ($sp,$laheyBoo,$testLH,$data,$ts,$dims,$i);
	our ($nr,$nc,$nl,$nrnc,$nrncnl,$headerText);
	my ($numBytes,$garbage);
	my @head=();
	my @allData=();
	my @dims=();
	my @testSUR=();
	my @floats=();
#	
	if(eof($fileHandle)) {die "Readcw5: End of file encountered\n";}
	if($numSPs eq "") {$numSPs = 1;}
	if($unpackBoo eq "") {$unpackBoo = 1;}
	for($sp=1;$sp<=$numSPs;$sp++) {
		$laheyBoo = 0;
		read($fileHandle, $data, 4);
		$testLH = unpack("i1", $data);
		if($testLH == 44 || $testLH == 36) {
		  $laheyBoo = 1;
		}
		if($laheyBoo) {
		  read($fileHandle, $data, 4);
		  $ts = unpack("i1", $data);
		}
		else {
		  $ts = $testLH;
		}
		
		read($fileHandle, $data, 4); 
		$sp = unpack("i1", $data);
		#print "$ts $sp\n";

		read($fileHandle, $data, 8); #SURFACT
		#@testSUR = unpack("f2",$data);
		#print join(",",@testSUR)."\n";

		read($fileHandle, $data, 16);
		$headerText = unpack("a16", $data);
		#		print $headerText."\n";

		@dims=();
		
		read($fileHandle, $data, 12);
		@dims = unpack("i3", $data);
		#print join(",",@dims)."\n";

		if($laheyBoo) {
		  read($fileHandle, $garbage, 8); #lahey has some more cruft here
		}
		#now for the floats
		@floats=();
		
		$nl = $dims[0];
		$nc = $dims[1];
		$nr = $dims[2];

		$nrnc = $nr*$nc;
		$nrncnl = $nrnc*$nl;
		$numBytes = $nrncnl*4;
		read($fileHandle, $data, $numBytes);
		if($laheyBoo) {
		  read($fileHandle, $garbage, 4); #lahey has 4 footer bytes
		}
		
		if($unpackBoo) {
			@head = unpack("f$nrncnl", $data);
			push @allData,@head;
		}
	} #sp
	return @allData;
}

sub Min {
	(my $num1,my $num2) = @_;
	if($num1 < $num2) {
		return $num1;
	} else {
		return $num2;
	}
}

sub Max {
	(my $num1,my $num2) = @_;
	if($num1 > $num2) {
		return $num1;
	} else {
		return $num2;
	}
}
