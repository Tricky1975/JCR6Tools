"""   -- Start License block

	(c) 2015 Jeroen Petrus Broks.
	
	This Source Code Form is subject to the terms of the 
	Mozilla Public License, v. 2.0. If a copy of the MPL was not 
	distributed with this file, You can obtain one at 
	http://mozilla.org/MPL/2.0/.


Version: 15.05.20

-- End License block   """

# Update history
# 15.02.01 - First official release
# 15.04.11 - Fixed a bug that kept older records when you read a new dir

# Debug
VarDebug = False

# Storage Classes


Storages = {}

class StoreClass:
    def STORE(self,s): return s
    def RESTORE(self,s): return s
    
Storages['Store'] = StoreClass()    



# Create
import struct


global CreateConfigDefault
CreateConfigDefault = { '__CaseSensitive':False }


class CreateClass:
   DEBUG=False
   FileTable = {}
   CommentTable = {}
   VarTable = {}
   RequireTable = []
   ImportTable = []
   Config = CreateConfigDefault
   
   def AddComment(self,TAG,COMMENT):
       self.CommentTable[TAG] = COMMENT
       
   def AddVar(self,TAG,VALUE):
       if VarDebug: print "/* AddVar */   %s = '%s'"%(TAG,VALUE) 
       self.VarTable[TAG] = VALUE
       
   def AddToTable(self,PENTRY,size,csize,offset,storage,author,notes): # ONLY TO BE USED BY JCR6 ITSELF!!!
       ENTRY = PENTRY
       if ENTRY[0]=='/': ENTRY = ENTRY.replace('/','',1)
       if self.Config['__CaseSensitive']: 
          ENAME = ENTRY 
       else: 
          ENAME = ENTRY.upper()
       self.FileTable[ENAME] = {'__Entry': ENTRY, '__Size': size, '__CSize':csize, '__Offset':offset, '__Storage':storage, '__Author':author, '__Notes':notes}
	
   
   def AddStringAsEntry(self,STR,ENTRY,storage,Author,Notes):
   	if not (storage in Storages): return "ERROR:Storage algorithm %s does not appear to be loaded!"%storage
   	storage2 = storage
        ltell = self.BT.tell()	
   	cs = Storages[storage].STORE(STR)
   	if len(cs)>len(STR):
   	   storage2 = 'Store'
   	   cs = STR   	   
   	self.BT.write(cs)
   	self.AddToTable(ENTRY,len(STR),len(cs),ltell,storage2,Author,Notes)
   	if len(STR)==0 : 
   	   ratio=0
   	else:   
   	   ratio = round(((len(cs)*1.0)/len(STR))*100)
   	if storage2=='Store': return "OK: Stored!"
   	return "OK: Down to: %d%s (%s)"%(ratio,"%",storage2)
   	
   def AddRequire(filename,signature="",allowpath=False):
       self.RequireTable.append({"File":filename,"Signature":signature,"AllowPath":allowpath})
   def AddImport(filename,signature="",allowpath=False):
       selfImportTable.append({"File":filename,"Signature":signature,"AllowPath":allowpath})
       	       
       	       
       	       
  
   def WInt(self,i):    # ONLY TO BE USED BY THE JCR ROUTINES THEMSELVES. NOT FOR CUSTOM USING!  
       format = "<i"                   # one integer
       data = struct.pack(format, i) # pack integer in a binary string
       self.BT.write(data)
   
   def WBytes(self,b): # used to be needed for Py 3, but as py 3 was ditched, I kept it in, for the unlikely event I'd need this.
       for ak in range(4): self.BT.write(chr(b[ak]))

   def WStr(self,wstring):  # ONLY YO BE USED BY THE JCR ROUTINES THEMSELVES!!!
       self.WInt(len(wstring))
       self.BT.write(wstring)

   def AddFile(self,FILE,ENTRY,storage,Author,Notes):
       try:
         s = open(FILE, 'r').read()
       except:
       	 return "ERROR: File not properly read!"
       return self.AddStringAsEntry(s,ENTRY,storage,Author,Notes)
       
   def AddAlias(self,ORI,TGT):
       if self.Config['__CaseSensitive']: 
          ENAME = ORI 
       else: 
          ENAME = ORI.upper()
       if self.Config['__CaseSensitive']: 
          ANAME = TGT 
       else: 
          ANAME = TGT.upper()
       if not ENAME in self.FileTable: return "ERROR: Original file not found!"    
       self.FileTable[ANAME] = {}
       for fld in self.FileTable[ENAME]:
       	   if fld=="__Entry": 
       	      self.FileTable[ANAME]["__Entry"] = TGT
       	   else:
       	      self.FileTable[ANAME][fld] = self.FileTable[ENAME][fld]
       return "Ok"   
       
   def Close(self,storage='Store'):
       FAT = ""	   
       FATOffset = self.BT.tell()
       for cmttag in self.CommentTable:
           FAT = '%s%s' % (FAT,chr(1))
           FAT = '%s%s' % (FAT,struct.pack('<i',len('COMMENT')))
           FAT = '%s%s' % (FAT,'COMMENT')
           FAT = '%s%s' % (FAT,struct.pack('<i',len(cmttag)))
           FAT = '%s%s' % (FAT,cmttag)
           FAT = '%s%s' % (FAT,struct.pack('<i',len(self.CommentTable[cmttag])))
           FAT = '%s%s' % (FAT,self.CommentTable[cmttag])
       for vartag in self.VarTable:
       	   if VarDebug: print "Saving var: %s (value: %s)"%(vartag,self.VarTable[vartag])
           FAT = '%s%s' % (FAT,chr(1))
           FAT = '%s%s' % (FAT,struct.pack('<i',len('VAR')))
           FAT = '%s%s' % (FAT,'VAR')
           FAT = '%s%s' % (FAT,struct.pack('<i',len(vartag)))
           FAT = '%s%s' % (FAT,vartag)
           FAT = '%s%s' % (FAT,struct.pack('<i',len(self.VarTable[vartag])))
           FAT = '%s%s' % (FAT,self.VarTable[vartag])       	   
       for enname in self.FileTable:
       	   FAT = "%s%s" % (FAT,chr(1))
       	   FAT = "%s%s" % (FAT,struct.pack('<i',4))
       	   FAT = "%sFILE" % FAT       	   
           for etag in self.FileTable[enname]:
               edata = self.FileTable[enname][etag]
               if type(edata)==str:
               	  FAT = "%s%s" % (FAT,chr(1))
               	  FAT = "%s%s" % (FAT,struct.pack('<i',len(etag)))
               	  FAT = "%s%s" % (FAT,etag)
               	  FAT = "%s%s" % (FAT,struct.pack('<i',len(edata)))
               	  FAT = "%s%s" % (FAT,edata)
               if type(edata)==bool:
               	  FAT = "%s%s" % (FAT,chr(2))
               	  FAT = "%s%s" % (FAT,struct.pack('<i',len(etag)))
               	  FAT = "%s%s" % (FAT,etag)
               	  if edata:
               	     FAT = "%s%s" %(FAT,chr(1))
               	  else:
               	     FAT = "%s%s" %(FAT,chr(0))
               if type(edata)==int:
               	  FAT = "%s%s" % (FAT,chr(3))
               	  FAT = "%s%s" % (FAT,struct.pack('<i',len(etag)))
               	  FAT = "%s%s" % (FAT,etag)
               	  FAT = "%s%s" % (FAT,struct.pack("<i",edata))
               #print ord(FAT[0])	
           FAT = "%s%s"%(FAT,chr(255))  
       for reqrec in self.RequireTable:
       	   FAT = "%s%s" % (FAT,chr(1))
       	   FAT = "%s%s" % (FAT,struct.pack('<i',7)) 
       	           #1234567
       	   FAT = "%sREQUIRE" % FAT
           for reqkey in reqrec:
       	       FAT = "%s%s" % (FAT,chr(1))               
               FAT = "%s%s" % (FAT,struct.pack('<i',len(reqkey)))
               FAT = "%s%s" % (FAT,reqkey)
               FAT = "%s%s" % (FAT,struct.pack('<i',len("%s"%reqrec[reqkey])))
               FAT = "%s%s" % (FAT,reqrec[reqkey])
           FAT = "%s%s"%(FAT,chr(255))  
       for reqrec in self.ImportTable:
       	   FAT = "%s%s" % (FAT,chr(1))
       	   FAT = "%s%s" % (FAT,struct.pack('<i',6)) 
       	           #123456
       	   FAT = "%sIMPORT" % FAT
           for reqkey in reqrec:
       	       FAT = "%s%s" % (FAT,chr(1))
               FAT = "%s%s" % (FAT,struct.pack('<i',len(reqkey)))
               FAT = "%s%s" % (FAT,reqkey)
               FAT = "%s%s" % (FAT,struct.pack('<i',len("%s"%reqrec[reqkey])))
               FAT = "%s%s" % (FAT,reqrec[reqkey])	       	       
           FAT = "%s%s"%(FAT,chr(255))  
       FAT = "%s%s"%(FAT,chr(255))
       if self.DEBUG:
       	  print("<DUMP FAT IN BYTES>")
       	  for ak in range(0,len(FAT)): print('%i>    Val %i     Char %s'%(ak,ord(FAT[ak]),FAT[ak]))
       CFAT = Storages[storage].STORE(FAT)
       self.WInt(len(FAT))
       self.WInt(len(CFAT))
       self.WStr(storage)
       self.BT.write(CFAT)
       self.BT.seek(self.OffsetForFATOffset)
       self.WInt(FATOffset)
       self.BT.close()

def Create(File,Config=CreateConfigDefault):
    ret = CreateClass()
    ret.BT = open(File,'w')
    ret.BT.write('JCR6%s'%chr(26))
    ret.OffsetForFATOffset = ret.BT.tell()
    ret.WInt(0) # This number holds the offset of the File Table. Very very important. Right now 0, as we don't know the location yet. The system will come back for this to put in the final number.
    for ctag in Config:
    	if type(Config[ctag])==str:    
    	   ret.BT.write(chr(1))
    	   ret.WStr(ctag)
    	   ret.WStr(Config[ctag])
    	elif type(Config[ctag])==bool:
    	   ret.BT.write(chr(2))
    	   ret.WStr(ctag)
    	   if Config[ctag]:
    	      ret.BT.write(chr(1))
    	   else:
    	      ret.BT.write(chr(0))
    	elif type(Config[ctag])==int:
    	   ret.BT.write(chr(3))
    	   ret.WStr(ctag)
    	   ret.WInt(Config[ctag])
    ret.BT.write(chr(255))
    ret.Config = Config
    return ret
   

# A few needed features
def RInt(bt):
    return struct.unpack('<i', bt.read(4))[0]

def RStr(bt):
    ln = RInt(bt)
    if ln==0: return ''
    return bt.read(ln)
    


  
# Dir
import cStringIO
import os
DirDrivers = []

class DirClass:
      
      Entries = {}
      Comments = {}
      Defs = {}
      FType = '?'
      FATOffset = None
      Config = {}
      Vars = {}
      
class JCR6DirDriver:
      Name='JCR6'
      DEBUG=False   
      def Recognize(self,filename):
          bt = open(filename,'rb')
          headermustbe = "JCR6%s"%chr(26)
          head = bt.read(5)
          bt.close()
          #print "head = %s and it must be: %s"%(head,headermustbe) #Just a debugline
          return head==headermustbe
      def Read(self,filename):
      	  ret = DirClass()
      	  ret.Entries = {}
      	  ret.Comments = {}
      	  ret.FType = "?"
      	  ret.FATOffset = None
      	  ret.Config = {}
      	  ret.Vars = {}
          bt = open(filename,'rb')
          ret.FType='JCR6'
          headermustbe = "JCR6%s"%chr(26)
          head = bt.read(5)
          if headermustbe!=head: 
             print("FALSE FILE ALERT!!!!")
             quit()             
          ret.FATOffset = RInt(bt)
          ttype=ord(bt.read(1))
          while ttype!=255:
          	tag = RStr(bt)  
                if ttype == 1:
                   ret.Config[tag] = RStr(bt)	
                elif ttype == 2:
                   ret.Config[tag] = ord(bt.read(1))>0
                elif ttype == 3:
                   ret.Config[tag] = RInt(bt)
                else:
                   print('HEY! Unknown tag in JCR6 config! (%s)'%tag)
                   quit()
                ttype=ord(bt.read(1))   
          bt.seek(ret.FATOffset)
          FATSize = RInt(bt)
          FATCSize = RInt(bt)
          FATCAlg = RStr(bt)
          ret.FATCompAlg = FATCAlg
          FATCPURE = bt.read(FATCSize)
          if self.DEBUG: 
             print('FAT COMPRESSION ALGORITHM: %s'%FATCAlg)
             print('FAT REAL SIZE: %s'%FATSize)
             print('FAT REAL SIZE: %s'%FATCSize)
             print('FAT OFFSET:    %s'%ret.FATOffset)
             #print('FAT CHECKBYTE: %i'%ord(FATSTR[0]))
             #print('\n\n<DUMP FAT>\n%s\n</DUMP FAT>'%str(FATSTR))
          if (not FATCAlg in Storages):
             print('Cannot expand the FAT data\nCompression algorithm "%s" is unknown'%FATCAlg)
             quit()
          FATSTR = Storages[FATCAlg].RESTORE(FATCPURE)   
          btd = cStringIO.StringIO(FATSTR)
          theend=False
          while not theend:
          	mtag = ord(btd.read(1))
          	if self.DEBUG: print "Found Main Tag: %i"%mtag
          	if mtag==255:
          	   theend=True
          	elif mtag==1:
          	   tag = RStr(btd) 
                   if self.DEBUG: print('Read tag: %s'%tag)         	   
          	   if tag=='FILE':
          	      Entry = {}	
          	      Entry['__Main'] = filename
          	      fttag = ord(btd.read(1))          	      
          	      while fttag!=255:
          	      	    if self.DEBUG: print('Read File Type Tag: %s'%fttag)  
          	      	    ftag = RStr(btd)
          	      	    if self.DEBUG: print('Read File Tag: %s'%ftag)
          	      	    if fttag==1:
          	      	       Entry[ftag] = RStr(btd)
          	      	       if self.DEBUG: print('Read String: "%s"'%Entry[ftag])
          	      	    elif fttag==2:
          	      	       Entry[ftag] = ord(btd.read(1))>1
          	      	    elif fttag==3:
          	      	       Entry[ftag] = RInt(btd)
          	      	       if self.DEBUG: print('Read Integer: "%i"'%Entry[ftag])
          	      	    elif fttag==255:
          	      	       pass
          	            else:
          	               print("Unknown type in directory (%i)"%fttag)
          	            fttag = ord(btd.read(1))   
          	      if ret.Config["__CaseSensitive"]:
          	      	 ret.Entries[Entry['__Entry']] = Entry
          	      else:
          	      	 ret.Entries[Entry['__Entry'].upper()] = Entry  
          	   elif tag=='COMMENT':
          	   	ctag = RStr(btd)
          	   	ccmt = RStr(btd)
          	   	ret.Comments[ctag] = ccmt
          	   elif tag=='VAR':
          	   	vtag = RStr(btd)
          	   	vval = RStr(btd)
          	   	ret.Vars[vtag] = vval
          	   elif tag=='REQUIRE' or tag=='IMPORT':
          	   	imptag = ord(btd.read(1))
          	   	newq = {}
          	   	#newq["REQUIRE"] = tag=='REQUIRE'
          	   	while imptag!=255:
          	   	      impkey = RStr(btd)
          	   	      impval = RStr(btd)
          	   	      newq[impkey] = impval
          	   	      imptag = ord(btd.read(1))
          	   	      print "%s = %s"%(impkey,impval)
          	   	if not "File" in newq: print('Incorrect JCR6 dependency call. File to call not specified!'); quit()    
          	   	if self.DEBUG: print "Request to import %s"%newq["File"]
          	   	if newq["File"][0]!="/": #.find("/")==-1:
          	   	   callfile = None	
          	   	   paths = [os.path.dirname(filename)]          	   	  
          	   	   for p in paths:
          	   	       checkfile = "%s/%s"%(p,newq["File"])
          	   	       if os.path.exists(checkfile): callfile = checkfile
          	   	elif os.path.exists(newq["File"][0]):
          	   	   callfile = newq["File"]
          	   	if callfile:
          	   	   sig = None
          	   	   if 'Singature' in newq: sig = newq["Signature"]
          	   	   if not AddPatchFile(ret,callfile,sig):
          	   	      print "Importing %s failed!"%callfile
          	   	      return
          	   	elif tag=="REQUIRE":
          	   	   print "The required dependency JCR6 file '%s' does not exist and therefore we cannot continue!"%newq["File"]
          	   	   return          	   	      
          	   else:
          	      print('Unknown entry tag (%s). Either this file is currupted or created with a later version of JCR6'%tag)
          	      print(struct.pack('<i',len(tag)))
          	      quit()
                else:
                   print('Unknown Main Tag. (%i) Either this file is currupted or created with a later version of JCR6'%mtag)
                   
                   quit()
                #mtag = ord(btd.read(1)	)    
          btd.close()   
          bt.close()
          return ret
DirDrivers.append(JCR6DirDriver())

def Recognize(filename,driver=""):
    ret = False
    for Driver in DirDrivers:
    	if driver=="" or Driver.Name==driver: ret = ret or Driver.Recognize(filename)
    	#print "After testing %s, ret = %s"%(Driver.Name,ret)
    return ret

def Dir(JCRFile):
    for Driver in DirDrivers:
    	#print "Checking Driver: %s"%Driver.Name    
    	if Driver.Recognize(JCRFile): return Driver.Read(JCRFile)
    print "ERROR! None of the loaded drivers recognized this file!"
    quit()


# Read
global readerror
def Read(JCR,Entry):
    readerror = "OK!"
    if type(JCR)==str:
       J = Dir(JCR)
    else :
       J = JCR
    if J.Config["__CaseSensitive"]:
       E = Entry
    else:
       E = Entry.upper()
    if E not in J.Entries:
       readerror = "ERROR! Cannot find entry '%s' (CS=%s)!"%(E,J.Config["__CaseSensitive"])
       print readerror
       #for TE in J.Entries: print TE
       return "This data is taken from a JCR file, but as something went wrong it was not possible to retrieve the correct data!"
    FE = J.Entries[E]
    bt = open(FE['__Main'],'rb')
    bt.seek(FE['__Offset'])
    COMPBUF = bt.read(FE['__CSize'])
    bt.close()
    alg = FE['__Storage']
    if not Storages[alg]: 
       readerror = "ERROR! Compression algorithm '%s' is unknown!"
       return "This is data taken from a JCR file, but as the driver for algorithm %s was not loaded at the time, it was not possible to retreive the correct data. Please make sure the driver is loaded and try it again!"
    return Storages[alg].RESTORE(COMPBUF)
    
def GetLines(JCR,Entry):    
    return Read(JCR,Entry).split('\n')  
    
def AddPatch(JCR,PatchJCR,sig=None):
    if sig and PatchJCR.Config['__Signature']!=sig:
       print('Signature mismatch')
       return false
    for k in PatchJCR.Entries:
    	tk = k
    	if not JCR.Config["__CaseSensitive"]: tk=k.upper()
    	JCR.Entries[tk] = PatchJCR.Entries[k]
    for k in PatchJCR.Comments:
    	JCR.Comments[k] = PatchJCR.Comments[k]
    for k in PatchJCR.Vars:
    	JCR.Vars[k] = PatchJCR.Vars[k]
    return True

def AddPatchFile(JCR,PatchFile,sig=None):
    J = Dir(PatchFile)
    return AddPatch(JCR,J,sig)
    
