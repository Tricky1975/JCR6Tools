Rem
	JCR6 - CLI - Add
	Adds/Updates new files to JCR
	
	
	
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
Import    tricky_units.tree
Import    tricky_units.MapListCopy
Import    tricky_units.ansistring
Import    "imp/ModsINeed.bmx" ' This contains just all mods all components actively looking inside a JCR6 file or writing a JCR6 require.
Import    "imp/TrueArg.bmx"
Import    "imp/WildCard.bmx"
Import    "imp/Update.bmx"


'JCRCREATECHAT = True ' -- Debugging only!
 
MKL_Version "JCR6 - jcr6_add.bmx","17.10.31"
MKL_Lic     "JCR6 - jcr6_add.bmx","GNU General Public License 3"
MKL_Post

If Len(AppArgs)=1
	Print "usage: jcr6 add <JCR-File> [<files>/@<listfile>/#<instructfile>] [switches]"
	Print 
	Print "Please note that using an instruct file will mostly override most switches"
	Print "-m        Delete original file after adding it to the JCR6 file"
	Print "-doj      Destroy original JCR file"
	Print "-cm<alg>  Use compression algorithm"
	Print "-fc<alg>  Use compression algorithm for file table (if not defined the same method as from -cm will be used)"
	Print "-mrg      Merge any file JCR6 recognizes as a supported type into the JCR as a directory"
	Print "-cd<dir>  Change dir prior to packing"
	Print "-ansi<s>  <s> may be 'yes' to use ansi, any other value will turn this off."
	?Win32
	Print "          On this platform it's turned off by default"
	?Not win32
	Print "          On this platform it's turned on by default"
	?
	Print 
	Print "Currently supported compression algorithms for -cm and -fm:"
	For Local i$=EachIn ListCompDrivers() WriteStdout i+" " Next Print
	Print 
	'Print "Wild card support is rather limited and in instruction files and list files not even allowed at all"
	End
	EndIf

If Not gotswitch("-myowndir") ChangeDir LaunchDir
	
Type TAddFile
	Field OFile$
	Field TFile$
	Field Storage$ = "Store"
	Field AllowMerge:Byte = True
	Field MergeStripExt:Byte = True
	Field DelOriginal:Byte = False
	Field Author$
	Field Notes$
	End Type
	
Type Taddcomment
	Field name$,comment$
	End Type	
	
If Len(targ)<2 Print ANSI_SCol("ERROR! Syntax error!!",A_Red) End	
	
Global AddList:TList 
Global destroyoriginal:Byte
Global Jfile$ = Targ[1]
Global fatstorage$ = "Store"
Global jconfig:configmap

Global JCRSkipPrefix:TList = New TList

Function GetProgress:TList(A:TList,dir$="")
Local AF:TAddFile
Local ret:TList = New TList
Local storage$ = "Store"
fatstorage = ""
'ChangeDir dir
For Local s$=EachIn switches
	If Prefixed(s,"-cm")   storage    = Right(s,Len(s)-3)
	If Prefixed(s,"-fc")   fatstorage = Right(s,Len(s)-3)
	If Prefixed(s,"-cd")   ChangeDir    Right(s,Len(s)-3)
	If Prefixed(s,"-ansi") ANSI_Use   = Right(s,Len(s)-5)="yes"
	Next
If Not fatstorage = storage fatstorage=storage
SortList A
For Local f$=EachIn A
	AF = New TaddFile	
	AF.OFile = f
	AF.TFile = f
	AF.storage = storage
	AF.AllowMerge = GotSwitch("-mrg")
	AF.deloriginal = gotswitch("-m")	
	If dir af.ofile = dir+"/"+f
	ListAddLast ret,AF
	Next
destroyoriginal = gotswitch("-doj") Or (Not FileType(Jfile$))
Return ret
End Function

Type talias
	Field original$,target$	
	End Type

Global linenumber
Function LoadProgress:TList(file$)
Local ret:TList = New TList
linenumber = 0
Local line$
Local linecmd$
Local linepar$
Local spl
Local AF:taddfile
Local globalstorage$ = "Store"
Local aliasname$
addlist = New TList
Function er(error$) Print "ERROR! "+error+" in line #"+linenumber End Function
Print "Instruction file: "+file
If Not FileType(file) Print "ERROR! Instruction file not found" End
Print
destroyoriginal = gotswitch("-doj") Or (Not FileType(Jfile$))
For Local trueline$=EachIn Listfile(file)
	linenumber:+1
	WriteStdout ANSI_SCol("  Compiling instructions, line #"+linenumber+"~r",A_Cyan)
	line = Trim(trueline)
	If line And (Not Prefixed(line,"#"))
		spl = line.find(":")
		linecmd = Upper(line[..spl])
		linepar = line[spl+1..]
		'DebugLog linecmd+" <> "+linepar
		Select linecmd
			Case "FILE"
				AF = New TAddfile
				af.ofile = linepar
				af.tfile = linepar
				af.storage = globalstorage
				ListAddLast ret,af
				DebugLog "#INST: Added: "+af.ofile
			Case "JCRSKIPPREFIX"
				ListAddLast JCRSkipPrefix,linepar	
			Case "TARGET"
				If Not af er "ERROR! "+linecmd+" not possible with defining a FILE first" Else af.tfile = linepar
			Case "STORAGE"
				If Not af er "ERROR! "+linecmd+" not possible with defining a FILE first" Else af.storage = linepar
			Case "MERGE"
				If Not af er "ERROR! "+linecmd+" not possible with defining a FILE first" Else af.allowmerge = Upper(linepar)="Y" Or Upper(linepar)="YES" Or Upper(linepar)="T" Or Upper(linepar)="TRUE" 
			Case "MERGESTRIPEXT"
				If Not af er "ERROR! "+linecmd+" not possible with defining a FILE first" Else af.mergestripext = Upper(linepar)="Y" Or Upper(linepar)="YES" Or Upper(linepar)="T" Or Upper(linepar)="TRUE" 
			Case "MOVE","DELORIGINAL","DELETEORIGINAL"
				If Not af er "ERROR! "+linecmd+" not possible with defining a FILE first" Else af.deloriginal = Upper(linepar)="Y" Or Upper(linepar)="YES" Or Upper(linepar)="T" Or Upper(linepar)="TRUE" 
			Case "AUTHOR"
				If Not af er "ERROR! "+linecmd+" not possible with defining a FILE first" Else af.author = linepar
			Case "NOTES"
				If Not af er "ERROR! "+linecmd+" not possible with defining a FILE first" Else af.notes = linepar
			Case "GLOBALSTORAGE"
				globalstorage = linepar
			Case "CD"
				ChangeDir linepar
			Case "FATSTORAGE","INDEXSTORAGE"
				fatstorage = linepar	
			Case "DESTROYORIGINALJCR"
				destroyoriginal = True	
			Case "COMMENT"
				spl = linepar.find(",")
				Local tc$ = linepar[spl+1..]
				tc = Replace(tc,"\n","~n")
				tc = Replace(tc,"\r","~r")				
				tc = Replace(tc,"\bslash\","\")
				Local ac:taddcomment = New taddcomment
				ac.name    = linepar[..spl]
				ac.comment = tc
				ListAddLast ret,ac	
				DebugLog "Comment>>  "+ac.name+" = "+ac.comment
			Case "CONFIG"
				'jconfig = JCR_GetDefaultCreateConfig()
				spl = linepar.find(",")
				Local tc$ = linepar[spl+1..]
				tc = Replace(tc,"\n","~n")
				tc = Replace(tc,"\r","~r")				
				tc = Replace(tc,"\bslash\","\")
				If Not jconfig jconfig = New configmap
				jconfig.def linepar[..spl],tc			
			Case "ALIAS"
				aliasname = linepar
			Case "AS"
				If aliasname
					Local al:talias = New talias
					al.original = aliasname
					al.target = linepar
					ListAddLast ret,al
				Else
					Print ANSI_SCol("ERROR! The 'AS' command can only be used when a file was set up for aliassing",A_Red)
					EndIf									
			Default
				er ANSI_SCol("Unknown command: "+linecmd,A_Red)
			End Select
		EndIf
	Next
Print "  Compiling instructions ... completed"	
Print
Return ret
End Function


Global files$ = LaunchDir
If Len(targ)>2 files = Replace(targ[2],"\","/")
Print "Process JCR:      "+jfile
Print "Files:            "+Files
Print "Launched from:    "+LaunchDir; ChangeDir LaunchDir

Global processlist:TList
If Left(files,1)="@" 
	addlist = getprogress(Listfile(Right(files,Len(files)-1)))
ElseIf Left(files,1)="#"
	addlist = loadprogress(Right(files,Len(files)-1))
Else
	'addlist = getprogress(WildCard(CreateTree(),files))
	'Print "Filetype("+files+") = "+FileType(files)
	Select FileType(files)
		Case 0	
			Print ANSI_SCol("ERROR! I cannot found input file/dir: "+files,A_Red)
		Case 1
			addlist = New TList
			ListAddLast addlist,files
			addlist = getprogress(addlist)
		Case 2
			Print ANSI_SCol("Analysing directory tree",A_Cyan)
			addlist = getprogress(CreateTree(files),files)
		End Select	
	EndIf

Global CJ:TJCRCreate
Global tfiles:TList 
Global alc
For Local a:TAddfile=EachIn addlist alc:+1 Next
If Not alc Print "No files to process! Ignoring request!" End Else Print "Files to process: "+alc
If destroyoriginal
	Print ANSI_SCol("Creating JCR: "+jfile,A_Cyan)
	'If jconfig Then Print "we got config!"
	cj = JCR_Create(jfile,jconfig)
Else
	Print ANSI_SCol("Updating JCR: "+jfile,A_Cyan,A_Bright)
	tfiles = New TList
	For Local af:Taddfile = EachIn addlist ListAddLast tfiles,af.tfile Next
	cj = UpdateJCR(jfile,tfiles)
	EndIf	
If Not cj Print ANSI_SCol("ERROR! Could not access or create JCR file",A_Red) End	
	
Function bck$(a$)
Local b$ = A
For Local i=1 To Len a b:+Chr(8) Next
Return b
End Function	

Global added,merged,failed
Global act$[] = [ANSI_SCol("added",A_Green),ANSI_SCol("updated",A_Green,A_Bright)]

Print
Global pos = 0
Global tot = CountList(addlist)
Global e:TJCREntry
Global addedfiles:TList = New TList
Global mj:TJCRDir
Global tdir$
Global bank:TBank
JCR6CrashError = False
JCR6DumpError = False
DebugLog "Addlist has "+CountList(addlist)+" items"
Print ANSI_SCol("Freezing requested raw files:",A_Cyan)
Global Jskip:Byte
For Local af:taddfile=EachIn addlist
	pos:+1
	WriteStdout ANSI_SCol("- ",A_red)+ANSI_SCol(af.ofile,A_Yellow)+ANSI_SCol(" ... ",A_Magenta)+ANSI_SCol(bck(pos+"/"+tot),A_Cyan)
	If JCR_Type(af.ofile) And af.allowmerge
		Print ANSI_SCol("merging "+JCR_Type(af.ofile),A_Cyan)
		mj = JCR_Dir(af.ofile)
		tdir = af.tfile
		If af.mergestripext tdir = StripExt(tdir)
		If tdir tdir:+"/"
		For Local entry:TJCREntry = EachIn MapValues(mj.entries)
			WriteStdout ANSI_SCol("  = ",A_Red,A_Bright)+ANSI_SCol(entry.filename,A_Yellow,A_Bright)+ANSI_SCol(" ... ",A_magenta)
			jskip = False
			For Local pre$=EachIn JCRSkipPrefix
				jskip = jskip Or Prefixed(StripDir(Upper(entry.filename)),Upper(pre))
			Next
			If jskip 
				Print ANSI_SCol(" skipped",A_red,A_Dark)
			Else	
				JCR_Error = Null
				bank = JCR_B(mj,entry.filename)
				If bank e = cj.addentry(bank,tdir+entry.filename,af.storage,af.author,af.notes)
				If JCR_Error Or (Not e) Or (Not bank)
					WriteStdout ANSI_SCol("failed -- ",A_Red); failed :+ 1
					If JCR_Error Print ANSI_SCol(JCR_Error.errormessage,A_Red,A_Bright) Else Print ANSI_SCol("Unknown error",A_Red,A_blink)
				Else	
					added:+1		
					If e.storage="Store"
						WriteStdout ANSI_SCol("stored",A_Green)
					Else
						WriteStdout ANSI_SCol(e.storage+":reduced to "+Int((Double(e.compressedsize)/Double(e.size))*100)+"%",A_Green)
					EndIf
					Print ANSI_SCol(" ... ",A_magenta)+act[ListContains(updateremoved,Upper(af.tfile))]
					ListAddLast addedfiles,af.ofile
				EndIf
			EndIf
		Next
	Else
		JCR_Error = Null
		e = cj.addentry(af.ofile,af.tfile,af.storage,af.author,af.notes)
		If JCR_Error Or (Not e)
			WriteStdout ANSI_SCol("failed -- ",A_Red); failed :+ 1
			If JCR_Error Print ANSI_SCol(JCR_Error.errormessage,A_Red,A_Bright) Else Print ANSI_SCol("Unknown error",A_Red,A_blink)
		Else	
			added:+1		
			If e.storage="Store"
			WriteStdout "stored"
			Else
				WriteStdout ANSI_SCol(e.storage+":reduced to "+Int((Double(e.compressedsize)/Double(e.size))*100)+"%",A_Green)
				EndIf
			Print ANSI_SCol(" ... ",A_magenta)+act[ListContains(updateremoved,Upper(af.tfile))]
			ListAddLast addedfiles,af.ofile
			EndIf
		EndIf				
	Next
Print ANSI_SCol("Handling comments (if set)"	,A_Cyan)
For Local ac:taddcomment = EachIn addlist
	Print ANSI_SCol("- ",A_Red)+ANSI_SCol(ac.name,A_Yellow,A_Bright)+ANSI_SCol(" ... ",A_Magenta)+ANSI_SCol("added comment",A_Green)
	MapInsert cj.comments,ac.name,ac.comment
	Next	
Print ANSI_SCol("Handling aliases (if set)"	,A_Cyan)
Global aliased,e2:TJCREntry
For Local al:talias = EachIn addlist
	WriteStdout ANSI_SCol("- ",A_Red)+ANSI_SCol(al.original,A_Yellow)+ANSI_SCol(" ... ",A_Magenta)
	e = TJCREntry(MapValueForKey(cj.entries,Upper(al.original)))
	If Not e e = TJCREntry(MapValueForKey(cj.entries,al.original))
	If MapContains(cj.entries,Upper(al.target))
		Print ANSI_SCol("failed -- Alias request with already existing target: "+al.target,A_Red)
		failed:+1		
	ElseIf e
		e2 = New TJCREntry
		e2.filename = al.target
		e2.mv = CopyMapContent(e.mv)
		MapInsert e2.mv,"$__Entry",e2.FileName
		MapInsert cj.entries,Upper(al.target),e2			
		Print ANSI_SCol("aliassed as: ",A_Green)+ANSI_SCol(al.target,A_Green,A_Underline)
		aliased:+1
	Else
		Print ANSI_SCol("failed -- Alias request from non-existing original: "+al.original,A_Red)
		failed:+1
		EndIf
	Next	
	
Select aliased
	Case 0
	Case 1	Print "~t1 file aliased"
	Default	Print "~t"+aliased+" files aliased"
	End Select		
	
Select added
	Case 0
	Case 1	Print "~t1 file added/updated"
	Default	Print "~t"+added+" files added/updated"
	End Select		
Select failed
	Case 0
	Case 1	Print "~t1 file failed"
	Default	Print "~t"+failed+" files failed"
	End Select		


If Not fatstorage fatstorage = "Store"
If destroyoriginal
	Print ANSI_SCol("Finalizing JCR creation",A_Cyan)
	cj.close fatstorage
Else
	Print ANSI_SCol("Finalizing JCR update",A_Cyan)
	closeupdatejcr cj,fatstorage
	EndIf
	
