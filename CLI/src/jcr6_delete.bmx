Rem
	JCR6 - CLI - Delete
	Delets files inside JCR6 file
	
	
	
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
Import    tricky_units.Listfile
Import    tricky_units.Dirry
Import    "imp/Update.bmx"
Import    "imp/TrueArg.bmx"
Import    "imp/WildCard.bmx"


 
MKL_Version "JCR6 - jcr6_delete.bmx","17.04.21"
MKL_Lic     "JCR6 - jcr6_delete.bmx","GNU General Public License 3"
MKL_Post


If Len(AppArgs)<2 Print "usage: jcr6 delete <JCRFILE> [file/@list]~n~nThe support for wildcards is very limited, and in listfiles they may even not be used at all." End

If Len(Targ[1])<2 Print "ERROR! Command line error" End

ChangeDir launchdir
Global j$ = targ[1]
Global files$ = "*"

'Print gotswitch("-nh")
If (Not gotswitch("-nh"))
	Print "Updating JCR: "+J
	EndIf

If Len(TArg)>2 files = targ[2]

Global processlist:TList
If Left(files,1)="@" 
	processlist = Listfile(Right(files,Len(files)-1))
Else
	processlist = WildCard(JCR_Dir(J),files)
	EndIf



Global JU:TJCRCreate = updateJCR(J,processlist,True)
CloseUpdateJCR JU

Select deleted
	Case 0
	Case 1	Print "~t1 file deleted"
	Default	Print "~t"+deleted+" files deleted"
	End Select		
