Strict


Framework brl.retro
Import    tricky_units.Listfile
Import    tricky_units.Dirry
Import    "imp/Update.bmx"
Import    "imp/TrueArg.bmx"
Import    "imp/WildCard.bmx"


 
MKL_Version "JCR6 - jcr6_extract.bmx","16.23.12"
MKL_Lic     "JCR6 - jcr6_extract.bmx","GNU General Public License 3"
MKL_Post


If Len(AppArgs)<2 Print "usage: jcr6 delete <JCRFILE> [file/@list]~n~nThe support for wildcards is very limited, and in listfiles they may even not be used at all." End

If Len(Targ[1])<2 Print "ERROR! Command line error" End

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
