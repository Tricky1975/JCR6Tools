Rem
	JCR6 - List
	Lists the contents of a JCR6 resource
	
	
	
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
Version: 17.10.31
End Rem
Strict

Framework brl.retro
Import    "imp/ModsINeed.bmx" ' This contains just all mods all components actively looking inside a JCR6 file or writing a JCR6 require.


MKL_Version "JCR6 - jcr6_list.bmx","17.10.31"
MKL_Lic     "JCR6 - jcr6_list.bmx","GNU General Public License 3"
MKL_Post

If Len(AppArgs)=1
	Print "usage: jcr6 list <JCR FILE>"
	End
	EndIf
	
ChangeDir LaunchDir	
	
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


Function Outp(SZ$="Real Size",CS$="Comp. Size",RT$="Ratio",OS$="Offset",ST$="Storage",FN$="Entry",Col=A_Cyan)
Local chs$[] = [" ","="]
Local uc = SZ="="
Local C$=chs[uc]
Print ANSI_SCol(JR(SZ,10,c)+" "+JR(CS,10,c)+" "+JR(RT,5,c)+" "+JR(OS,8,c)+" "+JR(ST,10,c)+" "+FN,col)
End Function

Function Outp2(SZ$="Real Size",SZC,CS$="Comp. Size",CSC,RT$="Ratio",RTC,OS$="Offset",OSC,ST$="Storage",STC,FN$="Entry",FNC)
Local chs$[] = [" ","="]
Local uc = SZ="="
Local C$=chs[uc]
Print ANSI_SCol(JR(SZ,10,c),SZC)+" "+ANSI_SCol(JR(CS,10,c),CSC)+" "+ANSI_SCol(JR(RT,5,c),RTC)+" "+ANSI_SCol(JR(OS,8,c),OSC)+" "+ANSI_SCol(JR(ST,10,c),STC)+" "+ANSI_SCol(FN,FNC)
End Function

Function Head()
Outp
outp "=","=","=","=","=","=====",A_Yellow
End Function

Print "Reading JCR: "+AppArgs[1]+"~n"

ChangeDir LaunchDir
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
		'outp ANSI_SCol(e.size,1),ANSI_SCol(e.compressedsize,2),ANSI_SCol(ratio+"%",3),ANSI_SCol(Hex(e.offset),4),ANSI_SCol(e.storage,5),ANSI_SCol(e.filename,6)
		outp2 e.size,1,e.compressedsize,2,ratio+"%",3,Hex(e.offset),4,e.storage,5,e.filename,6
		total:+1
		grandtotal:+1
		Next
	If total=1 Print ANSI_SCOl("~t1 entry in this file",A_Cyan) Else Print ANSI_SCol("~t"+total+" entries in this file",A_Cyan)
	Next
	
Print "~n~n"
If grandtotal=1 Print ANSI_SCol("~t1 entry in this entire resource collection",A_Cyan) Else Print ANSI_SCol("~t"+grandtotal+" entries in this entire resource collection"	,A_Cyan)
