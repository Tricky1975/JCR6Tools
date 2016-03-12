Strict

Framework brl.retro
Import    tricky_units.Listfile
Import    tricky_units.Dirry
Import    tricky_units.tree
Import    "imp/ModsINeed.bmx" ' This contains just all mods all components actively looking inside a JCR6 file or writing a JCR6 require.
Import    "imp/TrueArg.bmx"
Import    "imp/WildCard.bmx"
Import    "imp/Update.bmx"

 
MKL_Version "JCR6 - jcr6_extract.bmx","16.23.12"
MKL_Lic     "JCR6 - jcr6_extract.bmx","GNU General Public License 3"
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
	
If Len(targ)<2 Print "ERROR! Syntax error!" End	
	
Global AddList:TList 
Global destroyoriginal:Byte
Global Jfile$ = Targ[1]
Global fatstorage$ = "Store"

Function GetProgress:TList(A:TList,dir$="")
Local AF:TAddFile
Local ret:TList = New TList
Local storage$ = "Store"
fatstorage = ""
For Local s$=EachIn switches
	If Prefixed(s,"-cm") storage    = dir+"/"+Right(s,Len(s)-3)
	If Prefixed(s,"-fc") fatstorage = Right(s,Len(s)-3)
	If Prefixed(s,"-cd") ChangeDir    Right(s,Len(s)-3)
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
	ListAddLast ret,A
	Next
destroyoriginal = gotswitch("-doj") Or (Not FileType(Jfile$))
Return ret
End Function

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
addlist = New TList
Function er(error$) Print "ERROR! "+error+" in line #"+linenumber End Function
Print "Instruction file: "+file
If Not FileType(file) Print "ERROR! Instruction file not found" End
Print
destroyoriginal = gotswitch("-doj") Or (Not FileType(Jfile$))
For Local trueline$=EachIn Listfile(file)
	linenumber:+1
	WriteStdout "  Compiling instructions, line #"+linenumber+"~r"
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
			Default
				er "Unknown command: "+linecmd
			End Select
		EndIf
	Next
Print "  Compiling instructions ... completed"	
Print
Return ret
End Function


Global files$ = "."
If Len(targ)>2 files = Replace(targ[2],"\","/")
Print "Process JCR:      "+jfile
Print "Files:            "+Files
Print "Launched from:    "+LaunchDir

Global processlist:TList
If Left(files,1)="@" 
	addlist = getprogress(Listfile(Right(files,Len(files)-1)))
ElseIf Left(files,1)="#"
	addlist = loadprogress(Right(files,Len(files)-1))
Else
	'addlist = getprogress(WildCard(CreateTree(),files))
	Select FileType(files)
		Case 0	
			Print "ERROR! I cannot found input file/dir: "+files
		Case 1
			addlist = New TList
			ListAddLast addlist,files
			addlist = getprogress(addlist)
		Case 2
			addlist = getprogress(CreateTree(files),files)
		End Select	
	EndIf

Global CJ:TJCRCreate
Global tfiles:TList 
If destroyoriginal
	Print "Creating JCR: "+jfile
	cj = JCR_Create(jfile)
Else
	Print "Updating JCR: "+jfile
	tfiles = New TList
	For Local af:Taddfile = EachIn addlist ListAddLast tfiles,af.tfile Next
	cj = UpdateJCR(jfile,tfiles)
	EndIf	
If Not cj Print "ERROR! Could not access or create JCR file" End	
	
Function bck$(a$)
Local b$ = A
For Local i=1 To Len a b:+Chr(8) Next
Return b
End Function	

Global added,merged,failed
Global act$[] = ["added","updated"]

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
Print "Freezing requested raw files:"
For Local af:taddfile=EachIn addlist
	pos:+1
	WriteStdout "- "+af.ofile+" ... "+bck(pos+"/"+tot)
	If JCR_Type(af.ofile) And af.allowmerge
		Print "merging "+JCR_Type(af.ofile)
		mj = JCR_Dir(af.ofile)
		tdir = af.tfile
		If af.mergestripext tdir = StripExt(tdir)
		If tdir tdir:+"/"
		For Local entry:TJCREntry = EachIn MapValues(mj.entries)
			WriteStdout "  = "+entry.filename+" ... "
			JCR_Error = Null
			bank = JCR_B(mj,entry.filename)
			If bank e = cj.addentry(bank,tdir+entry.filename,af.storage,af.author,af.notes)
			If JCR_Error Or (Not e) Or (Not bank)
				WriteStdout "failed -- "; failed :+ 1
				If JCR_Error Print JCR_Error.errormessage Else Print "Unknown error"
			Else	
				added:+1		
				If e.storage="Store"
					WriteStdout "stored"
				Else
					WriteStdout e.storage+":reduced to "+Int((Double(e.compressedsize)/Double(e.size))*100)+"%"
					EndIf
				Print " ... "+act[ListContains(updateremoved,Upper(af.tfile))]
				ListAddLast addedfiles,af.ofile
				EndIf
			
			Next
	Else
		JCR_Error = Null
		e = cj.addentry(af.ofile,af.tfile,af.storage,af.author,af.notes)
		If JCR_Error Or (Not e)
			WriteStdout "failed -- "; failed :+ 1
			If JCR_Error Print JCR_Error.errormessage Else Print "Unknown error"
		Else	
			added:+1		
			If e.storage="Store"
			WriteStdout "stored"
			Else
				WriteStdout e.storage+":reduced to "+Int((Double(e.compressedsize)/Double(e.size))*100)+"%"
				EndIf
			Print " ... "+act[ListContains(updateremoved,Upper(af.tfile))]
			ListAddLast addedfiles,af.ofile
			EndIf
		EndIf				
	Next
For Local ac:taddcomment = EachIn addlist
	Print "- "+ac.name+" ... added comment"
	MapInsert cj.comments,ac.name,ac.comment
	Next	
	
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

If destroyoriginal
	cj.close fatstorage
Else
	closeupdatejcr cj,fatstorage
	EndIf
	
