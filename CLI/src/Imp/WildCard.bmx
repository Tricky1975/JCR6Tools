Rem
	JCR6 - CLI - WildCard
	Wild Card Manager (limited support)
	
	
	
	(c) Jeroen P. Broks, 2016, All rights reserved
	
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
Version: 16.03.12
End Rem
Strict
Import jcr6.jcr6main
Import tricky_units.prefixsuffix

MKL_Version "JCR6 - WildCard.bmx","16.03.12"
MKL_Lic     "JCR6 - WildCard.bmx","GNU General Public License 3"

 
Function wccheck(f$,w$)
If w$="*" Return True
If Left(w,1)="*" And Right(w,1)="*" Print "ERROR! Unsupported wild card input" End
For Local i=1 Until Len(w)-1
	If Chr(w[i])="*" Print "ERROR! Unsupported wild card input" End
	Next
If Left(w,1)="*"  Return Suffixed(Upper(f),Upper(Right(w,Len(w)-1)))
If Right(w,1)="*" Return Prefixed(Upper(f),Upper( Left(w,Len(w)-1)))
End Function

Function WildCard:TList(dir:Object,WCard$)
Local ret:TList = New TList
If TMap(dir)
	For Local Q$=EachIn MapKeys(TMap(dir))
		If wccheck(q,WCard) ListAddLast ret,q
		Next
	EndIf
If TJCRDir(dir)
	For Local Q$=EachIn MapKeys(TJCRDir(dir).entries)
		If wccheck(q,WCard) ListAddLast ret,TJCREntry(MapValueForKey(TJCRDir(dir).entries,q)).filename
		Next
	EndIf
If TList(dir)	
	For Local Q$=EachIn TList(dir)
		If wccheck(q,WCard) ListAddLast ret,q
		Next
	EndIf		
If String(dir) ret = WildCard(JCR_Dir(String(dir)),WCard)
Return ret
End Function
