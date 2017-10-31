Rem
	JCR6
	Data Dump
	
	
	
	(c) Jeroen P. Broks, 2017, All rights reserved
	
		This program is free software: you can redistribute it and/or modify
		it under the terms of the GNU General Public License as published by
		the Free Software Foundation, either version 3 of the License, or
		(at your option) any later version.
		
		This program is distributed in the hope that it will be useful,
		but WITHOUT ANY WARRANTY; without even the implied warranty of
		MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
		GNU General Public License for more details.
		You should have received a copy of the GNU General Public License
		along with this program.  If not, see <http://www.gnu.org/licenses/>.
		
	Exceptions to the standard GNU license are available with Jeroen's written permission given prior 
	to the project the exceptions are needed for.
Version: 17.04.27
End Rem
Strict

Framework brl.retro
Import    "imp/ModsINeed.bmx" ' This contains just all mods all components actively looking inside a JCR6 file or writing a JCR6 require.


MKL_Version "JCR6 - jcr6_ddump.bmx","17.04.27"
MKL_Lic     "JCR6 - jcr6_ddump.bmx","GNU General Public License 3"
MKL_Post

If Len(AppArgs)=1
	Print "usage: jcr6 ddump <JCR FILE>"
	Print 
	Print "This utility will show all data about a JCR file (except for its entry content). This data can be great for debugging purposes"
	End
	EndIf

ChangeDir LaunchDir
Print "Reading: "+AppArgs[1]
Global JCR:TJCRDir = JCR_Dir(AppArgs[1])
If Not jcr End

Print "Main files:"
For Local K$=EachIn MapKeys(JCR.MainFiles)
	Print "*~t"+K
Next

Print
Print "Config"
For Local k$=EachIn MapKeys(jcr.config)
	Print "~t"+k+"~t=~t"+String(MapValueForKey(jcr.config,k))
Next

Print
Print "Comments"
For Local k$=EachIn MapKeys(JCR.comments)
	Print ">> "+k+" <<"
	Print jcr.comments.value(k)
	Print "<< "+k+" >>~n~n"
Next

Print
Print "Allocation table data"
Print "~tSize            = "+jcr.FATSize
Print "~tCompressed size = "+jcr.FATCSize
Print "~tOffset          = "+Hex(jcr.FATOffset)
Print "~tAlgorithm       = "+jcr.FATAlg
Print "~n~n"


Print "Entries"
For Local K$=EachIn MapKeys(jcr.entries)
	Print "-~t"+K
	Local e:TJCREntry = TJCREntry(MapValueForKey(jcr.entries,k))
	Print "FileName:        "+e.Filename
	Print "MainFile:        "+e.MainFile
	Print "Size:            "+e.Size
	Print "Compressed Size: "+e.CompressedSize
	Print "Offset:          "+Hex(e.offset)
	WriteStdout "Unix File Mode:  "+e.UnixPermissions+" ... "
	If e.Unixpermissions>-1 Then Print permissions(e.unixpermissions) Else Print "Not set"
	For Local K2$=EachIn MapKeys(e.pvars)
		Print "~tpv:~t"+k2+"~t= "+e.pvars.value(k2)	
	Next
	For Local K2$=EachIn MapKeys(e.mv)
		Print "~tmv:~t"+k2+"~t= "+String(MapValueForKey(e.mv,k2))
	Next
Next
