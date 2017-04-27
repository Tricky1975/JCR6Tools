Rem
	JCR6 Type
	
	
	
	
	(c) Jeroen P. Broks, 2016, 2017, All rights reserved
	
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
Version: 17.04.21
End Rem
Strict

Framework brl.retro
Import    "imp/ModsINeed.bmx" ' This contains just all mods all components actively looking inside a JCR6 file or writing a JCR6 require.


MKL_Version "JCR6 - jcr6_type.bmx","17.04.21"
MKL_Lic     "JCR6 - jcr6_type.bmx","GNU General Public License 3"
MKL_Post

If Len(AppArgs)<3
	Print "usage: jcr6 type <JCR FILE> <entry>"
	End
	EndIf
	
ChangeDir LaunchDir	

Rem	
Function JR$(S$,L,ch$=" ")  ' Justify/align right	
Local ret$ = S
While Len(ret)<L 
	ret = ch+ret
	Wend
Return ret	
End Function



Global MainFiles:TMap = New TMap

Function MF:TList(A$)
If Not MapContains(MainFiles,A) MapInsert MainFiles,A,New TList
Return TList(MapValueForKey(mainfiles,A))
End Function


Function Outp(SZ$="Real Size",CS$="Comp. Size",RT$="Ratio",OS$="Offset",ST$="Storage",FN$="Entry")
Local chs$[] = [" ","="]
Local uc = SZ="="
Local C$=chs[uc]
Print JR(SZ,10,c)+" "+JR(CS,10,c)+" "+JR(RT,5,c)+" "+JR(OS,8,c)+" "+JR(ST,10,c)+" "+FN
End Function

Function Head()
Outp
outp "=","=","=","=","=","====="
End Function

Print "Reading JCR: "+AppArgs[1]+"~n"

Global JCR:TJCRDir = JCR_Dir(AppArgs[1])
If Not JCR Print "ERROR! No JCR file could be read!" End
Global E:TJCREntry
Global TP$

For E=EachIn MapValues(JCR.Entries)
	ListAddLast MF(e.mainfile),e
	Next

Print "This JCR calls for the next JCR files (including itself)"
For Local k$=EachIn(MapKeys(MaiNFiles))
	WriteStdout "- "+k
	tp$=JCR_Type(k)
	If tp Print ";  type: "+tp Else Print
	Next

Print 

Global ratio
Global total,grandtotal
For Local k$=EachIn(MapKeys(MaiNFiles))
	Print "~nShowing: "+k
	tp$=JCR_Type(k)
	If tp Print "File type: "+tp
	Print 
	Head()
	total=0
	For e=EachIn MF(k)
		If e.size ratio = Int((Double(e.compressedsize)/Double(e.size))*Double(100)) Else ratio=0
		outp e.size,e.compressedsize,ratio+"%",Hex(e.offset),e.storage,e.filename
		total:+1
		grandtotal:+1
		Next
	If total=1 Print "~t1 entry in this file" Else Print "~t"+total+" entries in this file"	
	Next
	
Print "~n~n"
If grandtotal=1 Print "~t1 entry in this entire resource collection" Else Print "~t"+grandtotal+" entries in this entire resource collection"	
EndRem


Print LoadString(JCR_B(AppArgs[1],AppArgs[2]))
