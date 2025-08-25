#library(nortest)
#library(outliers)
#library(date)
#library(NADA)
library(raster)

conv_date<-function(thedate) {
  year<-substr(thedate,7,10)
  month<-substr(thedate,1,2)
  day<-substr(thedate,4,5)
  return((as.numeric(year)+(as.numeric(month)/12)+(as.numeric(day)/365.25)))
}

#prd<-read.table("CPM_Plot_Data.txt",header=TRUE,sep=",")

#prd_eq_hd<-as.numeric(as.character(prd$H_HEAD))
#prd_eq_yr<-as.numeric(as.character(prd$YEAR))
#prd_eq_id<-as.character(prd$WELL_ID)

# Read In Obseved Data and Caculate Residuals
obs_mas<-read.table("well_by_well_observed.csv",header=TRUE,sep=",")
obs_hds<-read.table("head.smp",header=FALSE,sep="")
obs_cnc<-read.table("cnex.smp",header=FALSE,sep="")
obs_mas_time<-conv_date(obs_mas[,1])
obs_cnc_time<-conv_date(obs_cnc[,2])
obs_hds_time<-conv_date(obs_hds[,2])
ext_info<-read.table("Extraction_WELL_Screen_Info.txt",header=TRUE,sep="")

# Read In Simulated Results
prd_flw<-read.table("../flow_bymonth_bywell.txt",header=TRUE,sep=",")
prd_mas<-read.table("../mass_bymonth_bywell.txt",header=TRUE,sep=",")
prd_m83<-read.table("v8.3.2_massextract_2015_onward.txt",header=TRUE,sep=",")
prd_hds<-read.table("../head_bymonth_bywell.txt",header=TRUE,sep=",")
prd_flw_time<-((((prd_flw$full_time)))/365.25)+2012.0
prd_mas_time<-((((prd_mas$full_time)))/365.25)+2012.0
prd_hds_time<-((((prd_hds$full_time)))/365.25)+2012.0
prd_m83_time<-((((prd_m83$TIME)))/365.25)+2015.0

wid<-as.character(ext_info$WELL_ID)
wel_lst<-unique(ext_info$WELL_NAME)
wel_name<-ext_info$WELL_NAME[match(wid,ext_info$WELL_ID)]

pShp<-shapefile("bdjurdsv.shp")


wel_lst2 = wel_lst
# Histogram
for (i in 1:length(wel_lst2)) {

#  Get all datasets
   # P2R 7.1 Predicted
     ext_x<-ext_info$X[which(as.character(ext_info$WELL_NAME) == as.character(wel_name[i]))]
     ext_y<-ext_info$Y[which(as.character(ext_info$WELL_NAME) == as.character(wel_name[i]))]
     p_prd_hds<-prd_hds$hcell[which(as.character(prd_hds$WELLID) == as.character(wel_name[i]))]
     p_prd_hds[is.infinite(p_prd_hds)]<-NA
     p_prd_hdt<-prd_hds_time[which(as.character(prd_hds$WELLID) == as.character(wel_name[i]))]
     p_prd_m83<-prd_m83$MASS_KG[which(as.character(prd_m83$WELL_NAME) == as.character(wel_name[i]))]
     p_prd_m83[is.infinite(p_prd_m83)]<-NA
     p_prd_m8t<-prd_m83_time[which(as.character(prd_m83$WELL_NAME) == as.character(wel_name[i]))]
     p_prd_mas<-prd_mas$Mass_kg[which(as.character(prd_mas$WELLID) == as.character(wel_name[i]))]
     p_prd_mas[is.infinite(p_prd_mas)]<-NA
     p_prd_mat<-prd_mas_time[which(as.character(prd_mas$WELLID) == as.character(wel_name[i]))]
     p_prd_flw<-prd_flw$Q.node[which(as.character(prd_flw$WELLID) == as.character(wel_name[i]))]
     p_prd_flw[is.infinite(p_prd_flw)]<-NA
     p_prd_flt<-prd_flw_time[which(as.character(prd_flw$WELLID) == as.character(wel_name[i]))]
     p_prd_cnc<-(p_prd_mas/abs(p_prd_flw))*1e6/30
     p_prd_cnc[is.infinite(p_prd_cnc)]<-NA
     p_prd_cnt<-p_prd_mat
     p_prd_flw<-abs(p_prd_flw/5.451)

   # P2R Observed
     p_obs_mas<-obs_mas$MASS_KG[which(as.character(obs_mas[,2]) == as.character(wel_name[i]))]
     p_obs_mas[is.infinite(p_obs_mas)]<-NA
     p_obs_mat<-obs_mas_time[which(as.character(obs_mas[,2]) == as.character(wel_name[i]))]
     p_obs_hds<-obs_hds[which(as.character(obs_hds[,1]) == as.character(wid[i])),4]
     p_obs_hds[is.infinite(p_obs_hds)]<-NA
     p_obs_hdt<-obs_hds_time[which(as.character(obs_hds[,1]) == as.character(wid[i]))]
     p_obs_cnc<-obs_cnc[which(as.character(obs_cnc[,1]) == as.character(wid[i])),4]
     p_obs_cnc[is.infinite(p_obs_cnc)]<-NA
     p_obs_cnt<-obs_cnc_time[which(as.character(obs_cnc[,1]) == as.character(wid[i]))]
   
   if (sum(p_prd_mas) > 4 ) {
    png(as.character(paste("./hydro/ext_",as.character(wel_name[i]),".png",sep="")),width=2580,height=2580,res=300)


   layout(matrix(c(1,1,2,2,3,3,4,4,5,6),nrow=5,ncol=2, byrow=TRUE),widths=c(0.67, 0.33),heights=c(0.2,0.2,0.2,0.2,0.2), respect=TRUE)

   op<-par("mar")  # Record the current margins
   #par(mar=c(6.1,5.1,6.1,op[4]))
   par(mar=c(0.05,op[2],0.05,op[4]))  # Set up new margins
    
       
   y_max=0
   y_max=max(y_max,p_prd_mas, na.rm=TRUE)
   y_max=max(y_max,p_prd_m83, na.rm=TRUE)
   y_max=max(y_max,p_obs_mas, na.rm=TRUE)
   y_min=5000000.0
   y_min=min(y_min,p_prd_mas, na.rm=TRUE)
   y_min=min(y_min,p_prd_m83, na.rm=TRUE)
   y_min=min(y_min,p_obs_mas, na.rm=TRUE)
       
   y_min=floor(y_min)
   y_max=ceiling(y_max)
       
       
       
   plot(p_prd_mat,p_prd_mas,pch=22,cex=0.5,bg="white",col="white",xlab="Year",ylab="Mass Extraction, kg/month "
 #      ,xlim=c(1940,2015),ylim=c(y_min,y_max),cex.axis=1.0,cex.lab=1.0)
 #      ,xlim=c(2010,2030),ylim=c(y_min,y_max),cex.axis=2.0,cex.lab=2.0)
       ,xlim=c(2010,2030),ylim=c(y_min,y_max))
   x_minor<-seq(1940,2090,1)
   x_major<-seq(1940,2090,10)
   y_minor<-seq(90,160,1)
   y_major<-seq(90,160,10)
   #abline(h=y_minor,col="lightgray")
   #abline(h=y_major,col="gray60")
   abline(v=x_minor,col="lightgray")
   abline(v=x_major,col="gray60")


   # Mass Extracted
     points(p_obs_mat,p_obs_mas,pch=21,cex=1.0,bg="white",col="black")
     lines(p_prd_mat,p_prd_mas,lty=1,lwd=2,col="black")
     lines(p_prd_m8t,p_prd_m83,lty=3,lwd=2,col="orange")
   
   # Concentration
   y_max=0
   y_max=max(y_max,p_prd_cnc, na.rm=TRUE)
   y_max=max(y_max,p_obs_cnc, na.rm=TRUE)
   y_min=5000000.0
   y_min=min(y_min,p_prd_cnc, na.rm=TRUE)
   y_min=min(y_min,p_obs_cnc, na.rm=TRUE)
       
   y_min=floor(y_min)
   y_max=ceiling(y_max)
       
     if (length(p_obs_cnc) > 0) {
       plot(p_obs_cnt,p_obs_cnc,xlim=c(2010,2030),ylim=c(y_min,y_max),cex=0.5,bg="white",col="white",ylab="Concentration, ug/L",xlab="")
     } else {
       plot(p_prd_cnt,p_prd_cnc,xlim=c(2010,2030),ylim=c(y_min,y_max),cex=0.5,bg="white",col="white",ylab="Concentration, ug/L",xlab="")
     }
     #axis(at=pretty(p_obs_cnc),side=4,line=1,col="blue")
     points(p_obs_cnt,p_obs_cnc,pch=21,cex=1.0,bg="white",col="blue")
     lines(p_prd_cnt,p_prd_cnc,lty=1,lwd=2,col="blue")
   abline(v=x_minor,col="lightgray")
   abline(v=x_major,col="gray60")
     
   # Heads
   y_max=0
   y_max=max(y_max,p_prd_hds, na.rm=TRUE)
   y_max=max(y_max,p_obs_hds, na.rm=TRUE)
   y_min=5000000.0
   y_min=min(y_min,p_prd_hds, na.rm=TRUE)
   y_min=min(y_min,p_obs_hds, na.rm=TRUE)
       
   y_min=floor(y_min)
   y_max=ceiling(y_max)
       
     plot(p_prd_hdt,p_prd_hds,xlim=c(2010,2030),ylim=c(y_min,y_max),cex=0.5,bg="white",col="white",ylab="Head, m",xlab="")
     axis(at=pretty(p_prd_hds),side=4,line=5,col="green")
     points(p_obs_hdt,p_obs_hds,pch=21,cex=1.0,bg="white",col="green")
     lines(p_prd_hdt,p_prd_hds,lty=1,lwd=2,col="green")
   abline(v=x_minor,col="lightgray")
   abline(v=x_major,col="gray60")

   # Extraction Rate
   y_max=0
   y_max=max(y_max,p_prd_flw, na.rm=TRUE)
   y_min=5000000.0
   y_min=min(y_min,p_prd_flw, na.rm=TRUE)
       
   y_min=floor(y_min)
   y_max=ceiling(y_max)
       
     plot(p_prd_flt,p_prd_flw,xlim=c(2010,2030),ylim=c(y_min,y_max),cex=0.5,bg="white",col="white",ylab="Extraction Rate, gpm",xlab="")
     axis(at=pretty(p_prd_flw),side=4,line=3,col="red")
     lines(p_prd_flt,p_prd_flw,lty=1,lwd=2,col="red")
   abline(v=x_minor,col="lightgray")
   abline(v=x_major,col="gray60")

   op<-par("mar")  # Record the current margins
   par(mar=c(0.5,op[2],0.5,op[4]))  # Set up new margins
   # Create the legend
   legX<-c(0,1)
   legY<-c(0,1)
   plot(legX,legY,,xlab=" ",ylab=" ",type="l",axes=FALSE,xaxt="n",yaxt="n",col="white")
   par(mar=c(op[1],op[2],op[3],op[4]))
#   rect(0.0,0.25,0.99,0.9,col="white",border="black")
   ####add the legend
      text((0.02),0.5,"Observed",pos=4,cex=1.50)
      points(x=c(0.01),y=c(0.5),pch=21,bg="white",col="black",cex=1.0)
      text(0.80,0.5,"Simulated",pos=4,cex=1.5)
      lines(x=c(0.75,0.77),y=c(0.5,0.5),col="black",lwd=3,lty=1)
      text(0.50,0.25,"Simulated Version 8.3",pos=4,cex=1.5)
      lines(x=c(0.4,0.47),y=c(0.25,0.25),lty=3,lwd=2,col="orange")
      #text(0.50,0.5,"CPGW v8.4.5",pos=4,cex=1.5)
      #lines(x=c(0.45,0.50),y=c(0.5,0.5),col="darkgreen",lwd=3,lty=2)
      #text(0.45,0.5,"P2R v8.3",pos=4,cex=1.5)
      #lines(x=c(0.42,0.45),y=c(0.5,0.5),col="red",lwd=3,lty=4)
      text(0.30,0.7,paste("Well ", wel_name[i],sep=""),pos=4,cex=2.0)
  
#     text(0,0.5,paste("Statistical Summary : ",as.character(wel_name[i]),sep=""),pos=4,cex=1.0)
#     text(0,0.45, paste("RMS : ", round(rms,2), " m",sep=""),pos=4,cex=1.0)
#     text(0.2,0.45, paste("AE : ", round(ae,2), " m",sep=""),pos=4,cex=1.0)
#     text(0.4,0.45, paste("ME : ", round(bs,2), " m",sep=""),pos=4,cex=1.0)
#     text(0.6,0.45, paste("St_Dev : ", round(res_hd_sd,2),sep=""),pos=4,cex=1.0)
#     text(0.8,0.45, paste("COR : ", round(cor_res_hd,2),sep=""),pos=4,cex=1.0)
   plot(ext_info$X,ext_info$Y,xlab=" ",ylab=" ",type="l",asp=1.0,xaxt="n",yaxt="n",col="white")
     points(ext_info$X,ext_info$Y,pch=21,cex=0.7,bg="black",col="black")
     plot(pShp,add=TRUE)
     points(ext_x,ext_y,pch=21,cex=1.3,bg="red",col="red")
  
   par(mar=c(op[1],op[2],op[3],op[4]))
   
  dev.off()
   }

}








