#!/usr/bin/python

import sys,getopt,time
from subprocess import call
import csv,zipfile,re

def usage(long_opts):
   print 'annotate_reads.py',"[","--"+" --".join(long_opts).replace("="," <val>"),"]"
   print '   use -h to print this message'

def open_fastqc(fastqc_zip,match_strings):
   """ 
   Open the fastqc zip, find the fastqc_data.txt and pull out the matches as specified in match_strings.
   Return a dict with the keys and values for annotation on the object
   """
   annotations={}
   #open the fastqc zip
   try:
      with zipfile.ZipFile(fastqc_zip,'r') as myzip:
         #since the fastqc_data.txt file is in a directory with a custom name
         #find the path in the zip of the file so we can open it
         matching = filter(lambda element: "fastqc_data.txt" in element, myzip.namelist())
         #open the fastqc_data.txt file and find the relevant data
         for line in myzip.read(matching[0],'rU').split("\n"):
   	    #stop parsing if all of the matches have been made
            if len(annotations.keys()) == len(match_strings):
               break
            else:
               #test each line against the list of potential matches
	       #add it to the dict if it matches
               for match_str in match_strings:
                  match = re.match(match_str,line)
                  if match:
                     annotations[match.group(1)]=match.group(2).rstrip()
   except zipfile.BadZipfile as e:
      print " : ".join([time.strftime("%x %X"), "ERROR: BadZipfile", str(e), fastqc_zip])
   return annotations

def main(argv):
   reportarg = []
   test=False
   long_opts=["test","study-name=","root-sample-name=","sample-name=","sequencer-run-name=","ius-SWID=","lane-SWID="]
   try:
      opts, args = getopt.getopt(argv,"h",long_opts)
   except getopt.GetoptError:
      usage(long_opts)
      sys.exit(2)
   for opt, arg in opts:
      if opt == '-h':
         usage(long_opts)
         sys.exit()
      elif opt == '--test':
         test=True
      else:
         reportarg.append(opt)
	 reportarg.append(arg)
   #generate the report
   mycall = ["seqware", "files", "report", "--out", "tmp.tsv"];
   mycall.extend(reportarg)
   call(mycall)

   anno_file = open("annotations.csv",'w')

   #The strings to match for the FastQC reports
   match_strings=["^(Encoding)[\s]*(.*)","^(Total Sequences)[\s]*(.*)","^(Sequence length)[\s]*(.*)","^(%GC)[\s]*(.*)"]

   #open the file provenance report
   with open("tmp.tsv") as tsv:
      #parse the report into a map
      for line in csv.DictReader(tsv, delimiter="\t"):
         annos=None
	 #find the FastQC workflow reports and pull out the annotation lines
         if line['Workflow Name'] == 'FastQC' and line['File Meta-Type'] == 'application/zip-report-bundle':
            annos = open_fastqc(line['File Path'],match_strings)

	 #annotate the file with information pulled out of the FastQC report
         if annos is not None:
            for key in annos.keys():
               s = ",".join([line['File SWID'], key.replace(" ", "_"), annos[key].replace(" ", "_").replace("_/_","/"),"\n"])
               anno_file.write(s);
            
   anno_file.close()
   mycall = ["seqware", "annotate", "file", "--csv", "annotations.csv"] 
   if not test:
      call(mycall)
   else:
      print "Test mode enabled:",str(mycall)


if __name__ == "__main__":
   main(sys.argv[1:])



