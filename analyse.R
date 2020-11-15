#!/usr/bin/env Rscript

library("optparse")
 
option_list = list(
  make_option(c("-i", "--file"), type="character", default=NULL, 
              help="dataset file name", metavar="character"),
  make_option(c("-o", "--out"), type="character", default=NULL, 
              help="output directory", metavar="character"),
  make_option(c("-H", "--host"), type="character", default=NULL, 
              help="Hostname", metavar="character")
); 
 
opt_parser = OptionParser(option_list=option_list);
opt = parse_args(opt_parser);

if (is.null(opt$file)){
  print_help(opt_parser)
  stop("At least one argument must be supplied (dataset file name).n", call.=FALSE)
}

rm(iostat)
rm(iostat_aggregates_rs)
rm(iostat_aggregates_ws)
rm(iostat_aggregates_krs)
rm(iostat_aggregates_kws)
    
iostat_filename = opt$file
iostat_hostname = opt$host
output_directory = opt$out


iostat <- read.csv(iostat_filename)

iostat$rsize=iostat$krs/iostat$rs
iostat$wsize=iostat$kws/iostat$ws

iostat[is.na(iostat)] <- 0

columnnames=colnames(iostat)
raw_devicenames=unique(iostat$device)
devicenames=subset(raw_devicenames,raw_devicenames!="")

iostat_aggregates_rs=aggregate(iostat$rs, by=list(iostat$timestamp), FUN=sum , na.rm=TRUE)
iostat_aggregates_ws=aggregate(iostat$ws, by=list(iostat$timestamp), FUN=sum , na.rm=TRUE)
iostat_aggregates_krs=aggregate(iostat$krs, by=list(iostat$timestamp), FUN=sum , na.rm=TRUE)
iostat_aggregates_kws=aggregate(iostat$kws, by=list(iostat$timestamp), FUN=sum , na.rm=TRUE)

jpeg(paste(output_directory,"/",iostat_hostname,".summary.jpg",sep=""),width = 3840, height = 2160, units = "px");
par(mfrow=c(1,4))
plot(iostat_aggregates_rs$x,main="Sum of rs",pch=1,col="red");
plot(iostat_aggregates_ws$x,main="Sum of ws",pch=1,col="red");
plot(iostat_aggregates_krs$x,main="Sum of krs",pch=1,col="red");
plot(iostat_aggregates_kws$x,main="Sum of kws",pch=1,col="red");
dev.off()

for (i in devicenames) {
    print(i)
    jpeg(paste(output_directory,"/density_",iostat_hostname,".",i,".jpg",sep=""),width = 3840, height = 2160, units = "px");
    par(mfrow=c(2,6))
    iostat_device_subset=subset(iostat,iostat$device==i)
    for (j in columnnames) {
        print(j)
        title_of_plot=paste("Density plot from ", j, " of ",i,sep="")
        iostat_column_of_device_subset=iostat_device_subset[,j]
        if (j == "rs" || j == "ws" || j == "rsize" || j == "wsize" || j == "asvct" || j=="actv") {
          plot(iostat_column_of_device_subset,pch=1,col="red")
          d<-density(iostat_column_of_device_subset)
          plot(d) 
        } 
    }
    dev.off()
}

for (i in devicenames) {
    print(i)
    jpeg(paste(output_directory,"/",iostat_hostname,".",i,".jpg",sep=""),width = 3840, height = 2160, units = "px");
    par(mfrow=c(3,5))
    iostat_device_subset=subset(iostat,iostat$device==i)
    for (j in columnnames) {
        if (j == "device") {
         next
        }
        if (j == "tot") {
         next
        }
        if (j == "timestamp") {
         next
        }
        if (j == "us") {
         next
        }
        if (j == "wt") {
         next
        }
        if (j == "sy") {
         next
        }
        if (j == "id") {
         next
        }
        print(j)
        title_of_plot=paste(j, " of ",i,sep="")
        iostat_column_of_device_subset=iostat_device_subset[,j]
        plot(iostat_column_of_device_subset,main=title_of_plot,pch=1,col="red");   
    }
    dev.off()
}

