args <-commandArgs(trailingOnly=TRUE)
print(args)
json_file<-args[1]

library("rjson")
json_data<-fromJSON(file=json_file)

sapply(json_data$issues, function(issue) {
	components <- sapply(issue$fields$components, function(component) {
		name=component$name
	})
	if( is.null(issue$fields$resolutiondate)) { resolutiondate=Sys.Date() }
	else {resolutiondate=as.Date(issue$fields$resolutiondate)}

	c(
		project=issue$fields$project$name,
		summary=issue$fields$summary,
		enddate=resolutiondate,
		startdate=as.Date(issue$fields$created),
		duration=resolutiondate-as.Date(issue$fields$created),
		labels=paste(issue$fields$labels, collapse=','),
		components=paste(components, collapse=',')
	)
})


