"""   -- Start License block
        Tree.py
	(c) 2016 Jeroen Petrus Broks.
	
	This Source Code Form is subject to the terms of the 
	Mozilla Public License, v. 2.0. If a copy of the MPL was not 
	distributed with this file, You can obtain one at 
	http://mozilla.org/MPL/2.0/.
        Version: 16.03.12
       -- End License block   """
from glob import *
import os


def glob2list(t):
    global filelist
    global dirlist
    global dirsfound 
    dirsfound = 0
    filelist = []
    #dirlist = []
    for f in glob(t):
    	if os.path.isdir(f): 
    	   dirsfound = dirsfound + 1
    	   dirlist.append("%s/*"%f)
    	elif os.path.isfile(f):
    	   filelist.append(f)
    	else:
    	   raise "Cound not determine the nature of file: %s"%f

def Tree(folder,pure=False):
    global filelist
    global dirlist
    global dirsfound
    filelist = []
    dirlist = []
    
    dirsfound = 1
    ret = []
    cd = os.getcwd()
    if pure:
       dirlist.append("%s/*"%folder)
    else:
       os.chdir(folder)
       dirlist.append("*")
    while dirsfound>0:
    	  tempdirlist = dirlist
    	  for dle in tempdirlist:
    	      glob2list(dle)
    	      for dlef in filelist:
    	      	  ret.append(dlef)
    os.chdir(cd)    	      	  
    return ret
    
