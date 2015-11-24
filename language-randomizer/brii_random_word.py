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
   print('   --count: the number of words to generate (default: 1)')
   print('   -h: to print this message')

def readfile(filename):
   f = open(filename, 'r')
   lst = map(lambda s: s.strip(), list(f))
   f.close()
   return lst 

def get_con(con, scon):
   ch=random.random()
   if ch<0.25:
      c=random.choice(scon)
   else:
      c=random.choice(con)
   return c

def main(argv):
   test=False
   con=[]
   vow=[]
   scon=[]
   num=1
   length=0
   long_opts=["consonants=","vowels=","second-consonants=","count=","syl=" "test"]
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
      elif opt == '--count':
         if test: print(opt, arg)
         num=arg
      elif opt == '--syl':
         length=arg
      else:
	 usage(long_opts)
         sys.exit()


   if not con or not vow or not scon:
      usage(long_opts)

   #repeat for the number of desired words
   for j in xrange(int(num)):
      st=make_word(length,con,scon,vow)
      print("".join(st).lower(),sep="")

def make_word(length,con,scon,vow):
   st=[]
   #can't have two dim (scon) letters in a row
   was_dim=0

   #if a length was specified, use it
   #otherwise pick a length
   if length==0:
      l=random.randint(1,5)
   else:
      l=length

   #chance of starting a word with a double consonant
   #this is outside the loop so that there's no risk 
   #of 4 consonants in a row
   ch=random.random()
   if ch<0.05: 
      let=get_con(con,scon)
      if let in scon:
        was_dim=1
      st.append(let)

   #start generating syllables
   for i in xrange(int(l)):

      #start with a consonant
      #checks if the previous (outside loop) was a scon
      #otherwise normal applies
      ch=random.random()
      if ch<0.2:
         if was_dim:
            st.append(random.choice(con))
         else:
            st.append(get_con(con,scon))

      #reset dim counter
      was_dim=0

      #add required vowel
      st.append(random.choice(vow))

      #end with one or two consonants
      ch=random.random()
      if ch<0.2:
         let=get_con(con,scon)
         if let in scon:
            was_dim=1
         st.append(let)
      if ch<0.1:
         if was_dim:
            st.append(random.choice(con))
         else:
            st.append(get_con(con,scon))

      #reset dim counter before starting loop again
      was_dim=0

   #BRUTE FORCE CHECKS
   #make sure the word isn't all vowels
   #make sure that no more than 2 vowels occur in a row
   #make sure the letter is no more than 8 letters long
   good=0
   max_vow=0
   cur_vow=0
   for item in st:
      if item in vow:
         cur_vow=cur_vow+1
      else:
         good=1
         if cur_vow>max_vow:
            max_vow=cur_vow
         cur_vow=0
   if cur_vow>max_vow:
      max_vow=cur_vow
   if not good or max_vow>=3 or len(st)>8:
      #otherwise try again :)
      st=make_word(length,con,scon,vow)
   return st

if __name__ == "__main__":
   main(sys.argv[1:])
