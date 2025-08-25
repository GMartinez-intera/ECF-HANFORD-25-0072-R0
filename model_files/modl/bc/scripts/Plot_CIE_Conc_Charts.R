#setwd("C:\Users\stomusiak\Desktop\ECF-HANFORD-21-0005\PostProcessing\cie_nfa_ucns|Figure_Creation\Time_series\Figures_R\Figures"
shadowtext2<-function(x, y=NULL, labels, col='white', bg='black',
        theta= seq(pi/4, 2*pi, length.out=8), r=0.1, ... ) {

        xy <- xy.coords(x,y)
        xo <- r*strwidth('A')
        yo <- r*strheight('A')

        for (i in theta) {
                text( xy$x + cos(i)*xo, xy$y + sin(i)*yo, labels, col=bg, ... )
        }
        text(xy$x, xy$y, labels, col=col, ... ) }


trim.leading <- function (x)  sub("^\\s+", "", x)
trim.trailing <- function (x) sub("\\s+$", "", x)
trim <- function (x) gsub("^\\s+|\\s+$", "", x)
cht_list<-read.table("chart_output_list.txt",header=TRUE,sep=',')
cht_num<-unique(as.character(cht_list$Chart_Num))
chart_count=length(cht_num)
sim_path<-as.character(cht_list$Path)
fil_path<-as.character(cht_list$Zone_File)
axis_title<-as.character(cht_list$Label)
unit_title<-as.character(cht_list$units)
scn_lst<-as.character(cht_list$scn)
divisor<-as.numeric(as.character(cht_list$divider))
dat_col<-as.character(cht_list$Stat)
axs_len<-as.numeric(as.character(cht_list$axs))
zon_col<-as.character(cht_list$Zone_Num)
lin_color<-as.character(cht_list$color)
lin_width<-as.numeric(as.character(cht_list$Thk))
lin_type<-as.numeric(as.character(cht_list$Type))
DWS<-as.numeric(as.character(cht_list$DWS))
dat<-list()

for (ppp in 1:length(zon_col)) {
  dat[[ppp]]<-read.table(paste(sim_path[ppp],"/","zonal_",fil_path[ppp],".out",sep=""),header = TRUE, sep=",")
}


for (ccht in cht_num) {
  y_max = 0
  sim_indx<-which(cht_list$Chart_Num == ccht)
  IA<-dat[[sim_indx[1]]]
  IA<-IA[order(IA$LAYER,IA$TIME),]

  SMPTIME<-as.numeric(IA$TIME)
  SMPYEARS<-SMPTIME/365.25
  theDates<-unique(SMPYEARS)
  tmpcnc<-theDates

  for (indx in sim_indx) {
    IA<-dat[[indx]]
    IA<-IA[order(IA$LAYER,IA$TIME),]
    tmpIndex = ((as.numeric(zon_col[indx])-1)*5)
    tmpCol = ((as.numeric(dat_col[indx])))
    IA[which(IA[,(tmpCol+tmpIndex)]>1E+25),(tmpCol+tmpIndex)]<-NA
    IA[,(tmpCol+tmpIndex)]<-IA[,(tmpCol+tmpIndex)]/divisor[indx]
    indices<-which(trim.leading(as.character(IA$LAYER))== "MAX")
    tmpMax=ceiling(max(IA[indices,(tmpCol+tmpIndex)],na.rm=TRUE))
    y_max=max(y_max,tmpMax)
  }
  y_max = round(y_max+(10^trunc(log10(y_max))/2),-(trunc(log10(y_max))))
  y_min = 0
  #######################PEAK CONCENTRATION ######################################
  #Create a plot for the main aquifer
  png(paste(sim_path[sim_indx],"/","stat",dat_col[sim_indx[1]],"_",fil_path[sim_indx[1]],"_zon",zon_col[sim_indx[1]],"_axs",axs_len[sim_indx[1]],".png",sep=""),width=3294,height=2580,res=300)
  #Build plot

  layout(matrix(c(1,2), 2, 1, byrow=TRUE),heights=c(0.90,0.1), respect=TRUE)

  #par(ylog=TRUE)
  #plot(theDates,tmpcnc,xlab=" ",ylab=" ",type="l",xaxt="n",log="y",yaxt="n",xlim=c(0,axs_len[sim_indx[1]]),ylim=c(y_min,y_max),lwd=3,col="white")
  par(ylog=FALSE)
  plot(theDates,tmpcnc,xlab=" ",ylab=" ",xaxt="n",yaxt="n",xlim=c(0,axs_len[sim_indx[1]]),ylim=c(y_min,y_max),col="white")

  #draw axis
  x_major<-seq(0,axs_len[sim_indx[1]],(axs_len[sim_indx[1]]/5))
  x_minor<-seq(0,axs_len[sim_indx[1]],(axs_len[sim_indx[1]]/10))
#  y_major<-c(0.01,0.1,1.0,10,100,1000,10000,100000,1000000,10000000)
#  y_minor<-c(seq(0.1,1,0.1),seq(1,10,1),seq(10,100,10),seq(100,1000,100),seq(1000,10000,1000),seq(10000,100000,10000),seq(100000,1000000,100000),seq(1.0E+5,1.0E+6,1.0E+5),seq(1.0E+6,1.0E+7,1.0E+6))
  y_major<-seq(0,y_max,(y_max/5))
  y_minor<-seq(0,y_max,(y_max/10))
  axis(2,at=y_major,cex.axis=1.4)
  axis(1,at=x_major,cex.axis=1.4)

  #draw gridlines

  abline(h=y_minor,col="lightgray")
  abline(h=y_major,col="gray60")
  abline(v=x_minor,col="lightgray")
  abline(v=x_major,col="gray60")

  ##########################################  DRAW THE LINES FOR THE CURRENT SIMULATIONS  

  #  DRAW LINE FOR THE PEAK CONCENTRATION
  for (indx in sim_indx) {
    IA<-dat[[indx]]
    IA<-IA[order(IA$LAYER,IA$TIME),]
    tmpIndex = ((as.numeric(zon_col[indx])-1)*5)
    tmpCol = ((as.numeric(dat_col[indx])))
    IA[which(IA[,(tmpCol+tmpIndex)]>1E+25),(tmpCol+tmpIndex)]<-NA
    IA[,(tmpCol+tmpIndex)]<-IA[,(tmpCol+tmpIndex)]/divisor[indx]
    indices<-which(trim.leading(as.character(IA$LAYER))== "MAX")
    lines(IA$TIME[indices]/365.25,IA[indices,(tmpCol+tmpIndex)],col=lin_color[indx],lwd=lin_width[indx],lty=lin_type[indx])
  }
  
  abline(h=DWS[indx],col="darkgreen",lwd=4)
  shadowtext2(x=axs_len[sim_indx[1]],y=DWS[indx],"DWS",pos=1,r=0.2,offset=0.5,cex=1.2,col="black",bg="white")

  ##add annotation
  #add the axis labels
  mtext(text="Simulation Time in Years",side=1,font=2,cex=1.4,line=2.5)
  #mtext(text=paste("Summary Statistics for ",areas[iii],"\n",sim_title,sep=""),side=3,font=2,cex=1.5,line=1)
  
  
  if (dat_col[sim_indx[1]] == 3) {
    mtext(text=paste("Mean Concentration Comparison\n",sep=""),side=3,font=2,cex=1.5,line=1)
  }
  if (dat_col[sim_indx[1]] == 4) {
    mtext(text=paste("Peak Concentration Comparison\n",sep=""),side=3,font=2,cex=1.5,line=1)
  }
  if (dat_col[sim_indx[1]] == 7) {
    mtext(text=paste("90th Percentile Concentration Comparison\n",sep=""),side=3,font=2,cex=1.5,line=1)
  }
  #
  if (unit_title[indx]=="ug") {
    mtext(text=bquote(paste(.(axis_title[indx]),", ",mu,"g/L")),side=2,font=2,cex=1.4,line=3)
  } else {
    mtext(text=paste(axis_title[indx],", pCi/L"),side=2,font=2,cex=1.4,line=3)
  } 
  #

  op<-par("mar")  # Record the current margins
  par(mar=c(0.5,op[2],0.5,op[4]))  # Set up new margins
  # Create the legend
  legX<-c(0,1)
  legY<-c(0,1)
  plot(legX,legY,,xlab=" ",ylab=" ",type="l",xaxt="n",yaxt="n",col="white")


  x_start = 0.1
  y_start = 0.25
  for (indx in sim_indx) {
    text(x_start,y_start,scn_lst[indx],pos=4,cex=1.3)
    lines(x=c((x_start-0.08),(x_start-0.03)),y=c(y_start,y_start),col=lin_color[indx],lwd=lin_width[indx],lty=lin_type[indx])
    x_start = x_start + 0.3
    if (x_start > 0.9) {
      y_start = y_start + 0.4
      x_start = 0.1
    }
  }

  par(mar=c(op[1],op[2],op[3],op[4]))
  dev.off()
}
