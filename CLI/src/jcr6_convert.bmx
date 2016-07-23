Rem
	JCR 6 convert
	An easy tool to convert archives to JCR6 resources, but it can convert archives to different archives as well. It does require the help of the "real" archives though!
	
	
	
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
Version: 16.05.03
End Rem
Strict

Framework brl.retro
Import    tricky_units.Listfile
Import    tricky_units.Dirry
Import    tricky_units.tree
Import    tricky_units.prefixsuffix
Import    tricky_units.initfile2
Import    tricky_units.MD5
'Import    "imp/ModsINeed.bmx" ' This contains just all mods all components actively looking inside a JCR6 file or writing a JCR6 require.
Import    "imp/TrueArg.bmx"
'Import    "imp/WildCard.bmx"
Import    "imp/Update.bmx"

 
MKL_Version "JCR6 - jcr6_convert.bmx","16.05.03"
MKL_Lic     "JCR6 - jcr6_convert.bmx","GNU General Public License 3"
MKL_Post

If Len(AppArgs)=1
	Print "usage: jcr6 convert <Original> <Target> [switches]"
	Print 
	'Print "-do       Delete original File"
	Print "-t<kind>  Target type (default = JCR)"
	Print "-o<kind>  Original type (normally detected though file extention, but this is not always possible)"
	Print
	Print "Please note, this utility does NOTHING by itself, it just relies on 3rd party tools installed in order to operate. If they cannot be found this utility cannot work." 
	Print
	Print "Please note this tool is yet in development, it may not work properly (if it works at all)."
	End
EndIf

Function CopyOS(i:TIni,para$)
	Local p$[] = para.split(",")
	If Len(p)<>2 Print "ERROR: CopyOS has "+Len(p)+" parameters and needs 2"; Return
	Local os$,osd,rest$
	For Local K$=EachIn MapKeys(ini.Vars)
		'DebugLog "CopyOS - Checking "+K
		osd = k.find(".")
		If osd>0
			os = Upper(k[..osd])
			rest = k[osd..]
			If os=Upper(p[0])
				MapInsert ini.Vars,Upper(p[1]+rest),ini.Vars.value(k)
			EndIf
		EndIf
	Next
End Function
Ini_RegFunc "CopyOS",CopyOS

?win32
Const pl$="windows"
Const slash$="\"
?macos
Const pl$="mac"
Const slash$="/"
?linux
Const pl$="linux"
Const slash$="/"
?

Function OSF(file$ Var)
	?Win32
	file = Replace(file,"/","\")
	If Chr(file[0])<>"\" Or Chr(file[1])<>":") file = LaunchDir+"\"+file
	?Not Win32
	file = Replace(file,"\","/")
	If Chr(file[0])<>"/" file = LaunchDir+"/"+file
	?
End Function

Function substag(cmd$ Var,file$)
cmd = Replace(cmd,"<lauch>",LaunchDir)
cmd = Replace(cmd,"<me>",AppDir)
cmd = Replace(cmd,"<pack>","~q"+file+"~q")
End Function

Function spc$(a)
Local ret$
For Local i=0 Until a ret:+" " Next
Return ret
End Function

Global Ini:TIni
If Not FileType("jcr6_convert.ini") Print "ERROR! I don't have jcr6_convert.ini with me, and I cannot do my business without it!" End
LoadIni "jcr6_convert.ini",ini
Rem
?debug
Print "Debug keys:"
For Local k$=EachIn MapKeys(ini.Vars) Print k+" = "+ini.Vars.value(k) Next
?
End Rem
If Len(targ)<1 Print "ERROR: Command line syntax error!" End
Global File$ = targ[1]
OSF File

Global orit$ = ExtractExt(file).toupper()
Global tgtt$ = "JCR"

For Local s$=EachIn switches
	If Prefixed(s,"-t") tgtt = s[2..]
	If Prefixed(s,"-o") orit = s[2..]
Next

Global OutFile$ = StripExt(file)+"."+tgtt.tolower()

Global Work$ = Dirry("$AppSupport$/$LinuxDot$JCR6CONVERT/")
Global Temp$
Repeat
	Temp = Work+"JCR6C"+Hex(Rand(0,Abs MilliSecs()))
Until Not FileType(Temp)


Print
Print "Original Packed File: "+file
Print "Target Packed File:   "+outfile
Print "System:               "+pl
Print "Original packer:      "+orit
Print "Target packer:        "+tgtt
Print "Launched from:        "+LaunchDir
Print "JCR6 converter dir:   "+AppDir
Print "Swap dir:             "+temp
Print

If FileType(outfile)
	Print "Output file exists! Replace?"
	Select Input("R = replace~nM = merge (if possible)~nQ = quit~n:").toupper()
		Case "R","Y"
			If Not DeleteFile(outfile) Print "ERROR! Could not kill the output file!"
		Case "U","M"
		Default
			End
	End Select
EndIf

Global xcmd$ = ini.c(pl+"."+orit+".unpack")
Global pcmd$ = ini.c(pl+"."+tgtt+".pack")
Global vcmd$ = ini.c(pl+"."+tgtt+".unpack")

If Not xcmd Print "ERROR! Unpack type for that file type unknown: "+orit; End
If Not pcmd Print "ERROR!   Pack type for thar file type unknown: "+tgtt; End
If Not vcmd Print "ERROR! Unpack type for that file type unknown: "+tgtt; End

If Not CreateDir(temp,1) Print "ERROR! Swap dir could not be created"; End
ChangeDir temp
substag xcmd,file
Print "Unpacking the original packed file: "+file
system_ xcmd
Print
Print
Print "Scanning files for verification"
Print "= Analysing tree"
Global Tree:TList = CreateTree("."); SortList tree
Global ol=0
Global bt:TStream,content$
Global hashmap:StringMap = New StringMap
For Local f$=EachIn tree
	WriteStdout Chr(13)+"= Hashing: "+f+" ... "+spc(Len(f)-ol)
	bt = ReadFile(f)
	If Not bt 
		Print "ERROR! I could not open this file for hashing!"
		Ol=0
	Else
		content = ReadString(bt,StreamSize(bt))
		MapInsert hashmap,f,MD5(content)
		CloseFile bt
		ol = Len f
	EndIf
Next
Print "= All files analyzed for hashing!"+spc(ol)
Print "Packing all files to the new system"
substag pcmd,outfile
system_ pcmd
Print
Print
Print "Cleaning up workdir for verification!"
Function clean()
	For Local f$=EachIn tree
		If Not DeleteFile(f) Print "ERROR! Could not delete "+f+"!~n~nWARNING!~nThis error can leave you a lot of swap space wasted you'll never use again. You may need to remove the folder "+temp+" manually in order not to have some space wasted!" End
	Next	
	ChangeDir AppDir	
	If Not DeleteDir(temp,1) Print "ERROR! Swap dir could not be destroyed. The files inside should be deleted already, so no wasted space, but still you may want to delete "+temp+" manually." End	
End Function
clean
If Not CreateDir(temp,1) Print "ERROR! Swap dir could not be created"; End
ChangeDir temp

'If Not DeleteDir(temp,1) Print "ERROR! Could not destroy work folder "+temp+". All files inside should be removed now, so no waste of space, but still you may want to remove it manually.";End	
Print "Unpacking new packed file for verification"
substag vcmd,outfile
system_ vcmd
Print
Print
Print "Verifiying all files"
Global verifyok,verifyfail
For Local f$=EachIn tree
	WriteStdout "Verifying: "+f+" ... "
	bt = ReadFile(f)
	If Not bt 
		Print "ERROR! I could not open this file for verification!"
		verifyfail:+1
		Ol=0
	Else
		content = ReadString(bt,StreamSize(bt))
		If MD5(content)=hashmap.value(f) 
			Print "Ok "+hashmap.value(f)
			verifyok:+1
		Else
			Print "Failed ("+MD5(content)+" != "+hashmap.value(f)+")"
			verifyfail:+1
		EndIf						
		CloseFile bt
		ol = Len f
	EndIf
Next
Print "Destroying swap"
clean
Print

Print "= Old size:       "+FileSize(file)
Print "= New size:       "+FileSize(outfile)
Print "= Verify success: "+verifyok
Print "= Verify fail:    "+verifyfail
If verifyfail 
	Print "Please note the verification was not 100% succesful, so the new packed file is not entirely reliable!"
EndIf


Print "Operation complete"
Print

	
	

