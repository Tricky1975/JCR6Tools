Rem
	JCR6 - Extract
	Extract all files
	
	
	
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
Import    tricky_units.Listfile
Import    tricky_units.Dirry
Import    "imp/ModsINeed.bmx" ' This contains just all mods all components actively looking inside a JCR6 file or writing a JCR6 require.
Import    "imp/TrueArg.bmx"
Import    "imp/WildCard.bmx"

 
MKL_Version "JCR6 - jcr6_extract.bmx","17.10.31"
MKL_Lic     "JCR6 - jcr6_extract.bmx","GNU General Public License 3"
MKL_Post

If Len(AppArgs)=1
	Print "~nusage: jcr6 extract <JCR FILE> [files/@list] [targetdir] [switches]"
	Print
	Print "Allowed switches:"
	Print "-d             Remove extracted files from JCR6 (only possible in JCR6 format)"
	Print "-y             Answer all yes/no questions with yes"
	Print "-n             Answer all yes/no questions with no"
	Print "-ansi<yes/no>  Allow ANSI usage. Default is ~qno~q on Windows and ~qyes~q on Mac and Linux"
	Print
	Print "NOTE: Wildcard support is very limited, and in listfiles even non-existent!"
	End
	EndIf


'GetTrueArgs


'Print Len(targ) For Local i$=EachIn targ Print i Next
If Len(targ)<=1 Print ANSI_SCol("ERROR! I don't know which file I should read! TELL ME!",A_red) End
If gotswitch("-n") And gotswitch("-y") Print ANSI_SCol("ERROR! Oh, come on, always yes or always no. Please make up your mind, will ya!",A_red) End

Global JCRFile$ = targ[1]

ChangeDir LaunchDir

If Not gotswitch("-d")
   Print "Reading JCR:      "+JCRFile
Else
   Print "Updating JCR:     "+JCRFile
   EndIf

If gotswitch("-ansiyes")
	ANSI_Use = True
ElseIf gotswitch("-ansino")
	ANSI_Use = False
EndIf


Global JCR:TJCRDir = JCR_Dir(JCRFile)
If Not JCR Print "ERROR! Reading JCR file's contents failed!" End

Print "Resource Type:    "+JCR_Type(JCRFile)

If gotswitch("-d")
	If JCR_Type(JCRFile)<>"JCR6" Print ANSI_SCol("ERROR! Deleting cannot be performed on non-JCR6 resources",A_red) End
	If JCR.MultiFile Print ANSI_SCol("ERROR! Deleting cannot be performed on a multi-file resource",A_Red) End
	?Win32
	If Not FileType("jcr6_delete.exe")
	?Not Win32
	If Not FileType("jcr6_delete")
	?
		Print ANSI_SCol("ERROR! I need the assistance of jcr6_delete, and that tool cannot be found!",A_red) End
		EndIf
	End If		

Global Outputdir$ = LaunchDir
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
Return Upper(Chr(Trim(Input(ANSI_SCol(question,A_Yellow)+ANSI_SCol(" ? ",A_Cyan,A_blink)+ANSI_SCol("(Y/N) ",A_Blue)))[0]))="Y"
End Function



Print ANSI_SCol("- Extracting required files:",A_cyan)
Global fd$,d$
Global allow,skipreason$
Global extracted,skipped,failed
Global listsuccess:TList = New TList
For Local f$=EachIn processlist
	fd = ExtractDir(f); d = outputdir+"/"+fd
	allow = True
	If FileType(d)=1 skipreason:+ANSI_SCol("= There is a file named "+d+" and thus it cannot be used as output directory!",A_red,A_Blink) allow=False
	If allow And FileType(d)=0
		If yes("In order to extract ~q"+f+"~q;~nShall I create the directory ~q"+d+"~q") 
			If Not CreateDir(d,2)
				allow=False
				skipreason = ANSI_SCol("= I could not create directory "+d,A_red,A_blink)
				EndIf
		Else
			allow=False
			skipreason = ANSI_SCol("= The operating system did not allow me to create directory ~q"+d+"~q",A_red,A_blink)
			EndIf
		EndIf
	If FileType(d+"/"+f)=2
		allow = False
		skipreason = ANSI_SCol("= There is a directory with the same name",A_Red,A_Blink)
	ElseIf FileType(d+"/"+f)
		If Not yes("Overwrite ~q"+d+"/"+f+"~q")
			allow = False
			skipreason = ANSI_SCol("= File already exists and I may not overwrite",A_Red,A_Dark)
			EndIf
		EndIf
	WriteStdout ANSI_SCol("  = ",A_Red)+ANSI_SCol(f,A_yellow)+ANSI_SCol(" ... ",A_Magenta)
	If allow
		JCR_Error = Null
		JCR_Extract jcr,f,outputdir 'd+"/"+f,True
		If JCR_Error
			Print ANSI_SCol("failed",A_Red,A_blink)
			failed:+1
		Else
			Print ANSI_SCol("extracted",A_Green)
			extracted:+1
			ListAddLast listsuccess,f
			EndIf
	Else
		Print ANSI_SCol("skipped ",A_red,A_Dark)+skipreason
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
				
				

