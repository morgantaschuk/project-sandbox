#Authors: Morgan Taschuk, Jochen Weile was very very helpful. 

#The command line arguments should be the title of the graph/pdf followed by a list of filenames for parsing
args <-commandArgs(trailingOnly=TRUE)
print(args)
library("rjson")

#pull out the title of the chart
title=args[1]
#pull out the JSON filenames for parsing
restargs=args[2:length(args)]

#iterate through each input file, load it into JSON
durations<-lapply(restargs, function(arg) {
	json_file<-arg
	json_data<-fromJSON(file=json_file)
	#for each issue in the JSON file, calculate the duration
	durations <- do.call(c,lapply(json_data$issues, function(issue) {
		resolutiondate <- if (is.null(issue$fields$resolutiondate)) 
			Sys.Date() 
		else 
			as.Date(issue$fields$resolutiondate)
		strtoi(resolutiondate-as.Date(issue$fields$created))
	}))
	#replace all null elements in the list with NA
	durations[is.null(durations)] <- NA
	durations
})

counts<-lapply(durations, function(dur) {
	length(!is.na(dur))
})


####Create the diagrams
library("beeswarm")
pdf(file=paste(title,".pdf",sep=""))

#extend the bottom margin to 2"
par(mai=c(2,1,1,1))

#plot the beeswarm under the boxplot
beeswarm(durations, col=rainbow(12),main=title, xaxt='n', yaxt='n')
boxplot(durations,   ylab="days", las = 2, add=TRUE,names=restargs)#,ylim=c(0,365))
#put the sample size on each bar
columns<-length(restargs)
text(seq(1, columns, by=1),  y=rep(-30, times=columns), labels = counts)

#calculate the median for each set of issues
medians<-sapply(durations, function(duration) {
	median(duration)
})

#plot the median
barplot(medians, names=restargs, ylab="median days", las = 2, col=rainbow(12), main=title)#,ylim=c(0,250) )
dev.off()
