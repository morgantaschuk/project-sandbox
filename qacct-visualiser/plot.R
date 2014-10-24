#!/usr/bin/env Rscript
#mydf <- read.table('qacct.info.txt', header=TRUE, sep="\t")

#plot(as.Date(mydf$ge_start_time, "%Y-%m-%d %H:%M:%S"), mydf$ge_job_number)
#text(as.Date(mydf$ge_start_time, "%Y-%m-%d %H:%M:%S"), mydf$ge_job_number, mydf$ge_job_name)

#startdates<-as.POSIXct(mydf$ge_start_time, format="%Y-%m-%d %H:%M:%S")
#enddates<-as.POSIXct(mydf$ge_end_time, format="%Y-%m-%d %H:%M:%S")
#ids<-mydf$ge_job_number
#jobnames<-mydf$ge_job_name

#mydata<-data.frame(ids,jobnames,startdates,enddates)

#massaging the data to be more like the example from http://stackoverflow.com/questions/7852235/best-technique-for-timelines
#allnames<-c(as.character(jobnames),as.character(jobnames))
#alldates<-c(startdates,enddates)
#allids<-c(ids,ids)
#allframe<-data.frame(allnames,alldates,allids)

#There were some NA's there when the dates were wrong
#allframe.clean<-subset(allframe, !is.na(alldates))

#ggplot(allframe.clean, aes(x=alldates,y=allids))+geom_line() + geom_point() + geom_text(aes(label=allnames), hjust=0, vjust=0)


#all right, that didn't work. Let's try something else
#install.packages("timeline")


#mydata<-data.frame(ids,jobnames,startdates,enddates)
#mydata.clean<-subset(mydata, !is.na(startdates) & !is.na(enddates))

#timeline(mydata.clean, group.col="ids", label.col="jobnames", start.col="startdates", end.col="enddates")

#okay, that works, but it looks like the data are actually in two groups. I'm going to filter them a bit

#mydata.clean.sub<-subset(mydata.clean, ids<6151959)
#timeline(mydata.clean.sub,group.col="ids", label.col="jobnames", start.col="startdates", end.col="enddates")
#Interesting! you can definitely see the chromosome size differentials there
#mydata.clean.sub2<-subset(mydata.clean, ids>6151980)
#timeline(mydata.clean.sub2,group.col="ids", label.col="jobnames", start.col="startdates", end.col="enddates")
#that was the other end of the timelines

#Now I'm going to pick only the jobs with the longest enddates
#through some R voodoo that I don't fully understand
#(http://nsaunders.wordpress.com/2013/02/13/basic-r-rows-that-contain-the-maximum-value-of-a-variable/)
#mydata.agg<-aggregate(enddates ~ names, mydata.clean, max)
#mydata.max<-merge(mydata.agg,mydata.clean)
#timeline(mydata.max,group.col="ids", label.col="jobnames", start.col="startdates", end.col="enddates")
#Okay, that looks suitably neat!

#sort by starttime
#mydata.sort<-mydata.max[ with(mydata.max,order(startdates)), ]
#timeline(mydata.sort,group.col="jobnames", label.col="jobnames", start.col="startdates", end.col="enddates")

#look at the subset
#mydata.sort.sub2<-subset(mydata.sort, ids>6151980)


#NEW PACKAGE
#install.packages('googleVis')
#library("googleVis")


#plot(gvisTimeline(mydata.sort,rowlabel="jobnames",barlabel="jobnames",start="startdates",end="enddates",options=list(width=1000, height=1000)))
#Looks good, AND it opens in a html page
#plot(gvisTimeline(mydata.clean,rowlabel="jobnames",barlabel="jobnames",start="startdates",end="enddates",options=list(width=1500, height=1000)))


#jobids<-as.character(mydata.clean$ids)
#mydata.char<-data.frame(jobids,mydata.clean$jobnames,mydata.clean$startdates,mydata.clean$enddates)
#plot(gvisTimeline(mydata.char,rowlabel="mydata.clean.jobnames",barlabel="jobids",start="mydata.clean.startdates",end="mydata.clean.enddates",options=list(width=1500, height=1000)))



#So what Larry wants to do is look for jobs that have failed and how they fit in the hierarchy
#timeline and gvisTimeline don't have the ability to a) set the color of specific bars or b) set the size of the bars
#back to ggplot2

#ggplot(mydata.clean, aes(colour=jobnames)) + 
#    geom_segment(aes(x=startdates, xend=enddates, y=ids, yend=ids), size=3) +
#    xlab("Duration")

mydf <- read.table('qacct.info.txt', header=TRUE, sep="\t")
library("ggplot2")
#including fail/non-fail statuses
statuses<-as.character(mydf$ge_failed)
startdates<-as.POSIXct(mydf$ge_start_time, format="%Y-%m-%d %H:%M:%S")
enddates<-as.POSIXct(mydf$ge_end_time, format="%Y-%m-%d %H:%M:%S")
ids<-mydf$ge_job_number
jobnames<-mydf$ge_job_name
#hogginess is the difference between the requested amount of memory (h_vmem) and the max memory used (maxvmem)
hogginess<-apply(mydf[,c("ge_category","ge_maxvmem")], 1, function(row) {
	re <- regexpr("h_vmem=(\\d+)([\\w]{1})",row[1],perl=TRUE)
	hvmem<-mapply(start=attr(re,"capture.start"),len=attr(re,"capture.length"),function(start,len){
		 substr(row[1],start,start+len-1)
	})
	#convert GB to MB
	if (hvmem[2]=='G') {
		hvmem[1]=as.numeric(hvmem[1])*1000
	}
	#if there is no entry, set to 2G
	if (hvmem[1]=='') {
		hvmem[1]=2000
	}
	#convert to mb
	maxvmem<-as.numeric(row[2])/1000000
	#c(hvmem[1], maxvmem, as.integer(hvmem[1])-maxvmem)
	as.numeric(hvmem[1])-maxvmem
})

statuses[54]="1"

timeline<-data.frame(jobnames,startdates,enddates,statuses,ids,hogginess)
timeline<-subset(timeline, !is.na(startdates) & !is.na(enddates))
#timeline<-timeline[ with(timeline,order(enddates)), ]

#labels if the status is non-zero

labels<-apply(timeline[,c("statuses","ids")], 1, function(row) {
	if (row[1]==0){
	""
	} else {
	row[2]
	}
})

#timeline<-subset(timeline, startdates<"2014-02-16")
labtab<-data.frame(timeline$ids,labels)
names(labtab)[names(labtab)=="timeline.ids"] <- "ids"
timeline<-merge(timeline,labtab,by="ids")
pdf("timeline.pdf")
#Yatta!
#This plot shows a timeline sorted by id, with job names along the y axis and dates along the x axis
#colors highlight the status ids. Non-zero statuses have their ids printed
ggplot(timeline, aes(colour=statuses, y=enddates, ymin=startdates, ymax=enddates, x=reorder(jobnames,ids), group=row.names(timeline))) + geom_linerange(position=position_dodge(0.5), size=1) + coord_flip()+geom_text(aes(label=labels,hjust=0,vjust=0), position=position_dodge(0.5))
dev.off()
#Now I'm going to pick only the jobs with the longest enddates
#through some R voodoo that I don't fully understand
#(http://nsaunders.wordpress.com/2013/02/13/basic-r-rows-that-contain-the-maximum-value-of-a-variable/)
timeline.hog<-aggregate(hogginess ~ jobnames, timeline,sum)
timeline.max<-aggregate(enddates ~ jobnames, timeline,max)

sizes<-merge(timeline.hog,timeline.max)
pdf("hogginess.pdf")
ggplot(sizes, aes(x=enddates,y=reorder(jobnames,enddates)))+geom_point(aes(size=hogginess)) + labs(title="Sum of hogginess (wasted MB) by job name")
ggplot(sizes, aes(x=reorder(jobnames,hogginess),y=hogginess))+geom_bar(stat="identity")+coord_flip()+labs(title="Sum of hogginess (wasted MB) by job name")
dev.off()
















