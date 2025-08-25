
# get base raster size
library(raster)
base_size = 50

spc_name = "P2RBC.spc"
source("readRefArray.R")

nr=236
nc= 304
cutoff = 24

breakpoints=c(0, 450,900,1800,3600,1E20)
#colpatt=colorRampPalette(c("white", "lightblue1", "steelblue1","lemonchiffon","khaki3"))(5)

colpatt=colorRampPalette(c(rgb(255,255,255,255,maxColorValue = 255),
                         rgb(185,206,231,255,maxColorValue = 255),
                         rgb(109,163,199,255,maxColorValue = 255),
                         rgb(227,201,94,255,maxColorValue = 255),
                         rgb(252,240,164,255,maxColorValue = 255),
                         rgb(252,240,164,255,maxColorValue = 255)))






# read grid specification file
spc<-readLines(spc_name)
linenum=1
tmpline<-unlist(strsplit(trim(as.character(spc[linenum])),"\\s+"))
nr=as.numeric(as.character(tmpline[1]))
nc=as.numeric(as.character(tmpline[2]))
delc<-rep(-999,1,nc)
delr<-rep(-999,1,nr)
linenum=2
tmpline<-unlist(strsplit(trim(as.character(spc[linenum])),"\\s+"))
minx=as.numeric(as.character(tmpline[1]))
maxy=as.numeric(as.character(tmpline[2]))
theta=as.numeric(as.character(tmpline[3]))
tmpr = 1
tmpc = 1
for (linenum in 3:length(spc)) {
  tmpline<-unlist(strsplit(trim(as.character(spc[linenum])),"\\s+"))
  if (tmpc <= nc) {
    for (j in 1:length(tmpline)) {
      delc[tmpc]=as.numeric(tmpline[j])
      tmpc = tmpc+1
    }
  } else {
    for (j in 1:length(tmpline)) {
      delr[tmpr]=as.numeric(tmpline[j])
      tmpr = tmpr+1
    }
  }
}
# determine dimensions for base raster size
######## ASSUMPTION IS ALL LENGTHS ARE DIVISIBLE BY BASE SIZE #############
nr_ras=0
row_total = 0
for (i in (1:nr)) {
  nr_ras = nr_ras + (delr[i]/base_size)
  row_total = row_total + delr[i]
}
nc_ras=0
col_total = 0
for (i in (1:nc)) {
  nc_ras = nc_ras + (delc[i]/base_size)
  col_total = col_total + delc[i]
}

# determine row and cols from translation from modflow to simple raster


row_map<-rep(0,1,nr_ras)
col_map<-rep(0,1,nc_ras)
tmpr=0
for (i in (1:nr)) {
  for (n in (1:(as.numeric(delr[i]/base_size)))) {
    tmpr = tmpr + 1
    row_map[tmpr] = i
  }
}
tmpc=0
for (i in (1:nc)) {
  for (n in (1:(as.numeric(delc[i]/base_size)))) {
    tmpc = tmpc + 1
    col_map[tmpc] = i
  }
}
#create new raster object

pic_raster<-raster(ncol = nc_ras, nrow = nr_ras, xmn = minx, 
                   xmx = (minx+col_total), ymn = (maxy - row_total), 
                   ymx = maxy)
refs<-read.table("concentration_output_list_ctet.txt",sep=",",header=TRUE)
ref_list<-as.character(refs[,1])
break_list<-as.character(refs[,2])

for (d in 1:length(ref_list)) {
  dir.create(file.path(ref_list[d], "png2"))
  tmpline<-unlist(strsplit(trim(as.character(break_list[d])),","))
  breakpoints<-as.numeric(tmpline)

  for (p in list.files(paste(ref_list[d],"/refyr",sep=""))) {
    p2d<-readREFArray(nr,nc,paste(ref_list[d],"/refyr/",p,sep=""),7)
    p2d<-p2d/1000000


    cnt=1
    rasval<-rep(0.0001,1,nr_ras*nc_ras)
    for (i in (1:nr_ras)) {
      for (j in (1:nc_ras)) {
        rasval[cnt]=p2d[row_map[i],col_map[j]]
        cnt = cnt + 1
      }
    }
  #  rasval[1]=as.numeric(breakpoints[1])*1.01
    rasval[1]=0
    rasval[2]=as.numeric(breakpoints[2])*1.01
    rasval[3]=as.numeric(breakpoints[3])*1.01
    rasval[4]=as.numeric(breakpoints[4])*1.01
    rasval[5]=as.numeric(breakpoints[5])*1.01
    rasval[6]=as.numeric(breakpoints[6])*1.01
    values(pic_raster)<-rasval
    op<-par("mar")
    par(mar=c(0,0,0,0))

    png(filename=as.character(paste(ref_list[d],"/png2/",substr(p,1,nchar(p)-4),".png",sep="")),width=nc_ras,height=nr_ras,res=1)
    plot(pic_raster,xaxs='i', yaxs='i',yaxt="n",xaxt="n",legend=FALSE, breaks=breakpoints, col=colpatt(6))
    dev.off()
    par(mar=c(op[1],op[2],op[3],op[4]))


    cat(base_size ,sep="\n",file=as.character(paste(ref_list[d],"/png2/",substr(p,1,nchar(p)-4),".pgw",sep="")),append=FALSE)
    cat(0.0 ,sep="\n",file=as.character(paste(ref_list[d],"/png2/",substr(p,1,nchar(p)-4),".pgw",sep="")),append=TRUE)
    cat(0.0 ,sep="\n",file=as.character(paste(ref_list[d],"/png2/",substr(p,1,nchar(p)-4),".pgw",sep="")),append=TRUE)
    cat(-base_size ,sep="\n",file=as.character(paste(ref_list[d],"/png2/",substr(p,1,nchar(p)-4),".pgw",sep="")),append=TRUE)
    cat((minx + (base_size/2)) ,sep="\n",file=as.character(paste(ref_list[d],"/png2/",substr(p,1,nchar(p)-4),".pgw",sep="")),append=TRUE)
    cat((maxy- (base_size/2)) ,sep="\n",file=as.character(paste(ref_list[d],"/png2/",substr(p,1,nchar(p)-4),".pgw",sep="")),append=TRUE)

  }
}


