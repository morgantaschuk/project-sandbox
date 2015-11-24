#!/usr/bin/python
from __future__ import print_function

import sys,random,getopt

#
# Randomly generates words of a required number of syllables given 
# lists of consonants, second consonants, and vowels in text files
#
#
#


def usage(long_opts):
   print('random_word.py',"[","--"+" --".join(long_opts).replace("="," <val>"), "-h", "]")

def help_mes(long_opts):
   usage(long_opts)
   print('   --consonants: a text file of consonants, one per line')
   print('   --vowels: a text file of vowels, one per line')
   print('   --second-consonants: a text file of permitted second consonants')
   print('   --syl: the number of required syllables')
   print('   --count: the number of words to generate (default: 1)')
   print('   -h: to print this message')

def readfile(filename):
   f = open(filename, 'r')
   lst = map(lambda s: s.strip(), list(f))
   f.close()
   return lst 

def main(argv):
   test=False
   con=[]
   vow=[]
   scon=[]
   num=1
   length=0
   long_opts=["consonants=","vowels=","second-consonants=","syl=","count=","test"]
   #long_opts=["test","study-name=","root-sample-name=","sample-name=","sequencer-run-name=","ius-SWID=","lane-SWID="]
   try:
      opts, args = getopt.getopt(argv,"h",long_opts)
   except getopt.GetoptError:
      usage(long_opts)
      sys.exit(2)
   for opt, arg in opts:
      if opt == '-h':
         help_mes(long_opts)
         sys.exit()
      elif opt == '--test':
         test=True
      elif opt == '--consonants':
         if test: print(opt)
	 con=readfile(arg)
      elif opt == '--vowels':
         if test: print(opt)
         vow=readfile(arg)
      elif opt == '--second-consonants':
         if test: print(opt)
         scon=readfile(arg)
      elif opt == '--syl':
         if test: print(opt, arg)
         length=arg
      elif opt == '--count':
         if test: print(opt, arg)
         num=arg
      else:
	 usage(long_opts)
         sys.exit()


   if not con or not vow or not scon or length==0:
      usage(long_opts)

   #repeat for the number of desired words
   for j in xrange(int(num)):
      #repeat for the number of desired syllables
      for i in xrange(int(length)):
         if test: print("syllable ",i)

         #vowel, cons+vowel, cons+cons+vowel?
         #0.2, 0.6, 0.2
         ch=random.random()
         if ch<0.2:
            print(random.choice(vow), end="",sep="")
         elif ch<0.8:
            print(random.choice(con),random.choice(vow),end="",sep="")
         elif ch<1.0:
            print(random.choice(con),random.choice(scon),random.choice(vow),end="",sep="")
      print()

if __name__ == "__main__":
   main(sys.argv[1:])
