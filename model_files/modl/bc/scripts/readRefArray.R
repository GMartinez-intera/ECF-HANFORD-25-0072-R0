readREFArray<-function(nr,nc,filename,format_num) {
  ## Trevor Budge 06/29/2020
  ## This function reads in real arrays used in MODFLOW and MT3D
  ## The assumption is that the values are space delimited
  ## even though this is not required by MODFLOW and MT3D
  ## It could be used for integer arrays as well. 
  ## However, they are converted to real values in the returned array.
#  nrc=nr*nc

#  tmpStr = ""
#  tmpVal = 0

#  refarray<-array(1,dim=c(nr,nc)) # initialize the array
#  tmp3<-read.delim(filename,header=FALSE,sep="") # read in file

#    for (irow in 1:nr) { 
#      for (icol in 1:nc) {
#      tmpMod = icol%%format_num
#      if (tmpMod == 0) {
#        tmpMod = format_num
#      }
#      refarray[irow,icol] = as.numeric(tmp3[((irow-1)*ceiling(nc/format_num))+ceiling(icol/format_num) , tmpMod])
#    }
#  }
#  
#  
#    nrc=nr*nc
  
    refarray<-array(1,dim=c(nr,nc)) # initialize the array
    ref<-readLines(filename)
    irow=1
    icol=1
    for (linenum in 1:length(ref)) {
      tmpline<-unlist(strsplit(trim(as.character(ref[linenum])),"\\s+"))
      for (j in 1:length(tmpline)) {
        refarray[irow,icol]=as.numeric(tmpline[j])
        icol = icol + 1
        if (icol > nc) {
          irow=irow+1
          icol = 1
        }
      }
    }
  return(refarray)
}

