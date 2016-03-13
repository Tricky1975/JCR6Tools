Rem
	JCR6 - CLI - Script
	Scripting utility for JCR6
	
	
	
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
Version: 16.03.13
End Rem

Strict
Framework brl.retro
Import    tricky_units.Listfile
Import    tricky_units.ListDir
Import    tricky_units.tree
Import    tricky_units.Dirry
Import    tricky_units.advdatetime
Import    gale.mcon
Import    gale.mathemethics
Import    gale.jcr6api
Import    "imp/Version.bmx"
Import    "script/incbinscripts.bmx"
'Import    "imp/Update.bmx"
'Import    "imp/TrueArg.bmx"
'Import    "imp/WildCard.bmx"


 
MKL_Version "JCR6 - jcr6_script.bmx","16.03.13"
MKL_Lic     "JCR6 - jcr6_script.bmx","GNU General Public License 3"
MKL_Post




If Len(AppArgs)=1
	Print "usage: jcr6 script <LUA script> [parameters]"
	Print 
	Print "This will allow you to create JCR files by means of scripting. The scripting goes through Lua."
	End
	EndIf
	

Function LuaSafeString$(s$)
Local ret$ = s$
ret = Replace(ret,"~n","\n")
ret = Replace(ret,"\","\\")
ret = Replace(ret,"~q","\~q")
ret = Replace(ret,"~r","\r")
ret = Replace(ret,"~t","\t")
Return ret
End Function

Function List2LuaTable:String(L:TList)
Local ret$
For Local s$=EachIn L
	If ret ret:+", ~n~t"
	ret:+"~q"+LuaSafeString(s)+"~q"
	Next
Return "return {~t"+ret+"~n}"	
End Function

Global outputlist:TList = New TList
ListAddLast outputlist, "# JCR6 instruction file"
ListAddLast outputlist, "# Generated by JCR6 scripter on "+PNow()+"~n"
ListAddLast outputlist, "DESTROYORIGINALJCR:Yeah, from scripting we'll always destroy the old. Things will be much too complicated otherwise!"

Global CreateJCR6File$

Type	MyAPI

	Method GetListDir$(path$)
	Local L:TList = ListDir(path$)
	SortList L
	Return list2luatable(L)
	End Method
	
	Method GetTree$(path$)
	Local L:TList = CreateTree(path$)
	SortList L
	Return list2luatable(L)
	End Method
	
	Method Output(s$)
	ListAddLast outputlist,s
	End Method
	
	Method GetOutput$()
	Return list2luatable(outputlist)
	End Method
	
	Method GetAppArgs$()
	Return list2luatable(ListFromArray(AppArgs))
	End Method
	
	Method GetScriptArgs$()
	Local T:TList = New TList
	Local i
	For i=1 Until Len AppArgs
		ListAddLast T,AppArgs[i]
		Next
	Return list2luatable(T)
	End Method
	
	Method SetJCR6OutputFile(f$)
	CreateJCR6File = f
	End Method
	
	Method FType(F$)
	Return FileType(F)
	End Method
	
	End Type

GALE_Register New MyAPI,"JLS"  ' JLS = JCR Lua Script


If LaunchDir="/Volumes/Irravonia/BlitzMAX/v1.51/Mac" LaunchDir=AppDir; Print "Launched from the IDE! I do Not want that!"
ChangeDir LaunchDir
Global Script$ = AppArgs[1]; If Upper(ExtractExt(script))<>"LUA" script:+".lua"
Global LuaScript:TLua
Global SavedVars$,SVFile$ = StripExt(Script)+".SavedVars.lua"
CreateJCR6File$ = StripExt(script)+".jcr"
If FileType(SVFIle) SavedVars=LoadString(SVFile)
Print "Work dir:   "+LaunchDir
Print "Script:     "+script
Print "Saved vars: "+SVFile
If Not FileType(script) Print "ERROR! Scriptfile not found!" End
'Print "                   1         2         3         4         5         6         7" ' debug
'Print "12345678901234567890123456789012345678901234567890123456789012345678901234567890" ' debug
SetUpIncbin Script
LuaScript = GALE_LoadScript(luamap,script,SavedVars)
SaveString luascript.save("SAVE"),svfile

Print "Writing: "+StripExt(script)+".JCR6_Instructions"
List2File StripExt(script)+".JCR6_Instructions",outputlist

Print "And let's now get ready to rumble!"
?Win32
' Yeah, Windows is just a nasty piece of shit.
system_ Replace(AppDir,"/","\")+"\jcr6_add.exe ~q"+createJCR6file+"~q ~q"+StripExt(script)+".JCR6_Instructions~q"
?Not Win32
system_ Replace(AppDir,"\","/")+"/jcr6_add ~q"+createJCR6file+"~q ~q#"+StripExt(script)+".JCR6_Instructions~q"
?
