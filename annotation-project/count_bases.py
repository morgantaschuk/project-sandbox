#!/usr/bin/python
from __future__ import print_function

import sys,getopt,time
from subprocess import call
import csv,zipfile,re

def usage(long_opts):
   print('count_bases.py',"[","--"+" --".join(long_opts).replace("="," <val>"),"]")
   print('   use -h to print this message')

def do_count(att_string, bases):
   length=None
   total=None 
   for atts in att_string.split(";"):
      

      if len(atts.rstrip())>0:
         #print(atts)
         match = re.match("file.Sequence_length=([\d]*)",str(atts).rstrip())
	 if match:
            length = int(match.group(1))
         match = re.match("file.Total_Sequences=([\d]*)",str(atts).rstrip())
         if match:
            total = int(match.group(1))
   if length is not None and total is not None:
      bases = bases + (length*total)
   #      if len(keyval) > 1:
   #         if len(keyval[0].rstrip())>0:
   #            print(keyval[0], " -> ", keyval[1])
   return bases

def main(argv):
   bases=0
   reportarg = []
   title="basecount"
   test=False
   long_opts=["after-date","test","study-name=","root-sample-name=","sample-name=","sequencer-run-name=","ius-SWID=","lane-SWID="]
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
      elif opt == '--after-date':
         print("After-date:",arg)
      else:
         reportarg.append(opt)
	 reportarg.append(arg)
         title="_".join([title,arg])
   #generate the report
   title = title.replace(" ","_")+".sh" 
   mycall = ["seqware", "files", "report", "--out", title+".tsv"];
   mycall.extend(reportarg)
   call(mycall)
  
   #anno_file = open(title,'w')

   #open the file provenance report
   with open(title+".tsv") as tsv:
      #parse the report into a map
      for line in csv.DictReader(tsv, delimiter="\t"):
         annos=None
	 #find the FastQC workflow reports and pull out the annotation lines
         if line['Workflow Name'] == 'FastQC' and line['File Meta-Type'] == 'application/zip-report-bundle':
            bases = do_count(line['File Attributes'], bases)
   print("total bases:",bases)

if __name__ == "__main__":
   main(sys.argv[1:])



