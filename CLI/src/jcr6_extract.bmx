Rem
	JCR6 - Extract
	Extract all files
	
	
	
	(c) Jeroen P. Broks, 2016, All rights reserved
	
		This program is free software: you can redistribute it And/Or modify
		it under the terms of the GNU General Public License as published by
		the Free Software Foundation, either version 3 of the License, Or
		(at your option) any later version.
		
		This program is distributed in the hope that it will be useful,
		but WITHOUT ANY WARRANTY; without even the implied warranty of
		MERCHANTABILITY Or FITNESS For A PARTICULAR PURPOSE.  See the
		GNU General Public License For more details.
		You should have received a copy of the GNU General Public License
		along with this program.  If Not, see <http://www.gnu.org/licenses/>.
		
	Exceptions To the standard GNU license are available with Jeroen's written permission given prior 
	To the project the exceptions are needed For.
Version: 16.03.12
End Rem
Strict


Framework brl.retro
Import    tricky_units.Listfile
Import    tricky_units.Dirry
Import    "imp/ModsINeed.bmx" ' This contains just all mods all components actively looking inside a JCR6 file or writing a JCR6 require.
Import    "imp/TrueArg.bmx"
Import    "imp/WildCard.bmx"

 
MKL_Version "JCR6 - jcr6_extract.bmx","16.23.12"
MKL_Lic     "JCR6 - jcr6_extract.bmx","GNU General Public License 3"
MKL_Post

If Len(AppArgs)=1
	Print "~nusage: jcr6 extract <JCR FILE> [files/@list] [targetdir] [switches]"
	Print
	Print "Allowed switches:"
	Print "-d Remove extracted files from JCR6 (only possible in JCR6 format)"
	Print "-y Answer all yes/no questions with yes"
	Print "-n Answer all yes/no questions with no"
	Print
	Print "NOTE: Wildcard support is very limited, and in listfiles even non-existent!"
	End
	EndIf


'GetTrueArgs


'Print Len(targ) For Local i$=EachIn targ Print i Next
If Len(targ)<=1 Print "ERROR! I don't know which file I should read! TELL ME!" End
If gotswitch("-n") And gotswitch("-y") Print "ERROR! Oh, come on, always yes or always no. Please make up your mind, will ya!" End

Global JCRFile$ = targ[1]

If gotswitch("-d")
   Print "Reading JCR:      "+JCRFile
Else
   Print "Updating JCR:     "+JCRFile
   EndIf

Global JCR:TJCRDir = JCR_Dir(JCRFile)
If Not JCR Print "ERROR! Reading JCR file's contents failed!" End

Print "Resource Type:    "+JCR_Type(JCRFile)

If gotswitch("-d")
	If JCR_Type(JCRFile)<>"JCR6" Print "ERROR! Deleting cannot be performed on non-JCR6 resources" End
	If JCR.MultiFile Print "ERROR! Deleting cannot be performed on a multi-file resource" End
	?Win32
	If Not FileType("jcr6_delete.exe")
	?Not Win32
	If Not FileType("jcr6_delete")
	?
		Print "ERROR! I need the assistance of jcr6_delete, and that tool cannot be found!" End
		EndIf
	End If		

Global Outputdir$ = "."
If Len(targ)>2 Outputdir = targ[2]
outputdir = Replace(outputdir,"\","/")
If Suffixed(outputdir,"/") outputdir = Left(outputdir,Len(outputdir)-1)
Print "Output directory: "+Outputdir


Global files$ = "*"
If Len(targ)>3 files = Replace(targ[3],"\","/")
Print "Files:            "+Files

Global processlist:TList
If Left(files,1)="@" 
	processlist = Listfile(Right(files,Len(files)-1))
Else
	processlist = WildCard(JCR,files)
	EndIf


Function Yes(Question$)
If gotswitch("-y") Return True
If gotswitch("-n") Return False
Return Upper(Chr(Trim(Input(question+" ? (Y/N) "))[0]))="Y"
End Function



Print "- Extracting required files:"
Global fd$,d$
Global allow,skipreason$
Global extracted,skipped,failed
Global listsuccess:TList = New TList
For Local f$=EachIn processlist
	fd = ExtractDir(f); d = outputdir+"/"+fd
	allow = True
	If FileType(d)=1 skipreason:+"= There is a file named "+d+" and thus it cannot be used as output directory " allow=False
	If allow And FileType(d)=0
		If yes("In order to extract ~q"+f+"~q;~nShall I create the directory ~q"+d+"~q") 
			If Not CreateDir(d,2)
				allow=False
				skipreason = "= I could not create directory "+d
				EndIf
		Else
			allow=False
			skipreason = "= The used did not allow me to create directory ~q"+d+"~q"
			EndIf
		EndIf
	If FileType(d+"/"+f)=2
		allow = False
		skipreason = "= There is a directory with the same name"
	ElseIf FileType(d+"/"+f)
		If Not yes("Overwrite ~q"+d+"/"+f+"~q")
			allow = False
			skipreason = "= File already exists and I may not overwrite"
			EndIf
		EndIf
	WriteStdout "  = "+f+" ... "
	If allow
		JCR_Error = Null
		JCR_Extract jcr,f,outputdir 'd+"/"+f,True
		If JCR_Error
			Print "failed"
			failed:+1
		Else
			Print "extracted"
			extracted:+1
			ListAddLast listsuccess,f
			EndIf
	Else
		Print "skipped "+skipreason
		skipped:+1
		EndIf
	Next
	
If gotswitch("-d")
	CreateDir(Dirry("$AppSupport$/$LinuxDot$JCR6"))
	List2File Dirry("$AppSupport$/$LinuxDot$JCR6/DelList"),listsuccess
	system_ "jcr6_delete ~q"+targ[1]+"~q ~q@"+Dirry("$AppSupport$/$LinuxDot$JCR6/DelList")+"~q -nh"
	EndIf

Select extracted
	Case 0
	Case 1	Print "~t1 file extracted"
	Default	Print "~t"+extracted+" files extracted"
	End Select		
Select skipped
	Case 0
	Case 1	Print "~t1 file skipped"
	Default	Print "~t"+skipped+" files skipped"
	End Select		
Select failed
	Case 0
	Case 1	Print "~t1 file failed"
	Default	Print "~t"+failed+" files failed"
	End Select		
				
				

