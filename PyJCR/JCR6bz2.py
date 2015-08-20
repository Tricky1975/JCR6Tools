"""   -- Start License block

	(c) 2015 Jeroen Petrus Broks.
	
	This Source Code Form is subject to the terms of the 
	Mozilla Public License, v. 2.0. If a copy of the MPL was not 
	distributed with this file, You can obtain one at 
	http://mozilla.org/MPL/2.0/.


Version: 15.05.20

-- End License block   """
import JCR6
import bz2

class jcrbz2:
      def STORE(self,s): return bz2.compress(s)
      def RESTORE(self,s): return bz2.decompress(s)
	
JCR6.Storages['bz2'] = jcrbz2()	
