"""   -- Start License block

	(c) 2015 Jeroen Petrus Broks.
	
	This Source Code Form is subject to the terms of the 
	Mozilla Public License, v. 2.0. If a copy of the MPL was not 
	distributed with this file, You can obtain one at 
	http://mozilla.org/MPL/2.0/.


Version: 15.05.20

-- End License block   """
import JCR6
cando = False
try:
  import pylzma
  cando = True
except:
  print("WARNING! The lzma algorithm requires pylzma'nIt does not appear to exist, or could otherwise not be loaded!\nTherefore lzma will not be supported")	



class jcrlzma:
      def STORE(self,s): return pylzma.compress(s)
      def RESTORE(self,s): return pylzma.decompress(s)
	
if cando: JCR6.Storages['lzma'] = jcrlzma()	
