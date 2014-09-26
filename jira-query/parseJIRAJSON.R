args <-commandArgs(trailingOnly=TRUE)
print(args)
library("rjson")
library("beeswarm")
title=args[1]
restargs=args[2:length(args)]
durations<-lapply(restargs, function(arg) {
json_file<-arg
json_data<-fromJSON(file=json_file)
issues<-sapply(json_data$issues, function(issue) {
	#components <- sapply(issue$fields$components, function(component) {
#		name=component$name
#	})
	if( is.null(issue$fields$resolutiondate)) { resolutiondate=Sys.Date() }
	else {resolutiondate=as.Date(issue$fields$resolutiondate)}

#	c(
		#project=issue$fields$project$name,
		#summary=issue$fields$summary,
		#enddate=resolutiondate,
		#startdate=as.Date(issue$fields$created),
		duration=strtoi(resolutiondate-as.Date(issue$fields$created))#,
		#labels=paste(issue$fields$labels, collapse=','),
		#components=paste(components, collapse=',')
#	)
})

#list(
#	duration=strtoi(issues[5,1:ncol(issues)])
#)
return(issues)
})
png(filename=paste(title,".png",sep=""))
boxplot(ylab="days", durations, names=restargs)

beeswarm(durations, add=TRUE, col=rainbow(8) )
dev.off()
