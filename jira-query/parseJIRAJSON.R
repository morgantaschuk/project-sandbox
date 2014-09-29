args <-commandArgs(trailingOnly=TRUE)
print(args)
library("rjson")
library("beeswarm")
title=args[1]
restargs=args[2:length(args)]
durations<-lapply(restargs, function(arg) {
	json_file<-arg
	json_data<-fromJSON(file=json_file)
	issues<-lapply(json_data$issues, function(issue) {
		if( is.null(issue$fields$resolutiondate)) { resolutiondate=Sys.Date() }
		else {resolutiondate=as.Date(issue$fields$resolutiondate)}
		duration=strtoi(resolutiondate-as.Date(issue$fields$created))
	})
	return(issues)
})

pdf(file=paste(title,".pdf",sep=""))
par(mai=c(2,1,1,1))
beeswarm(durations, col=rainbow(12),main=title, xaxt='n', yaxt='n')
boxplot(durations,   ylab="days", las = 2, add=TRUE,names=restargs)#,ylim=c(0,365))

medians<-sapply(durations, function(duration) {

	median=median(duration)
})

barplot(medians, names=restargs, ylab="median days", las = 2, col=rainbow(12), main=title)#,ylim=c(0,250) )
dev.off()
