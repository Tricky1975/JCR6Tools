Strict
Import jcr6.jcr6main
Import tricky_units.prefixsuffix

MKL_Version "JCR6 - jcr6.bmx","16.03.12"
MKL_Lic     "JCR6 - jcr6.bmx","GNU General Public License 3"

 
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
