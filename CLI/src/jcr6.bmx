Rem
	JCR6 - Command Line utilities
	Central manager
	
	
	
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
'Import    tricky_units.Dirry
Import    tricky_units.ListDir
Import    tricky_units.prefixsuffix
Import    "imp/Version.bmx"

MKL_Version "JCR6 - jcr6.bmx","16.03.13"
MKL_Lic     "JCR6 - jcr6.bmx","GNU General Public License 3"
MKL_Post


Global myextention$ = ExtractExt(AppFile) ' In windows this will always be .exe on Mac or Linux sometimes an "unofficial" extention will be used in order to indicate with binary is for Mac and which for Linux, as both have none by default.

Print "JCR6 - Command line utilities"
Print "Coded by: Tricky"
Print "(c) Jeroen Petrus Broks 2016"
Print

If Len(AppArgs)<2
	Print "Usage: jcr6 <command> [parameters]"
	Print "~nAvailable commands:"
	For Local u$=EachIn ListDir(AppDir,LISTDIR_FILEONLY)
		If Prefixed(u,"jcr6_") And myextention=ExtractExt(u) Print StripExt(Replace(u,"jcr6_","- "))
		Next
	Print "~nThe JCR6 modules have been licenced under the terms of the MPL 2.0"
	Print "These command line utilities have been licenced under the termso of the GNU GPL 3"
	End
	EndIf
	

Global cmd$ = AppDir+"/jcr6_"+AppArgs[1]
?win32
cmd:+".exe"
?

If Not FileType(cmd) 
	Print "ERROR! Unknown command: "+AppArgs[1]
	End
	EndIf

For Local i=2 Until Len AppArgs
	cmd:+" ~q"+AppArgs[i]+"~q"
	Next

system_ cmd
