Rem
	JCR6 - Command Line utilities
	Version display
	
	
	
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
Framework brl.retro


Import    tricky_units.ListDir
Import    tricky_units.prefixsuffix
Import    "imp/Version.bmx"

Rem
?win32
Print "Version output not supported on Windows"
End
?
End Rem

MKL_Version "JCR6 - jcr6_version.bmx","16.05.03"
MKL_Lic     "JCR6 - jcr6_version.bmx","GNU General Public License 3"
MKL_Post

Global p$ = "*VERSION*"
?win32
p = "-VERSION-"
?
Global myextention$ = ExtractExt(AppFile)

If Len(AppArgs)>1 
	If Upper(AppArgs[1])="FULL"
		p = "*FULLVERSION*"
		Print "Showing full version information of all components"
	Else
		Print "Showing version numbers of the components. Add the parameter 'full' for full information"
		EndIf
	EndIf
?win32
'Print AppDir+"\jcr6.exe "+p
system_ "jcr6.exe "+p
?Not win32
system_ AppDir+"/jcr6 "+p
?
For Local u$=EachIn ListDir(AppDir,LISTDIR_FILEONLY)		
		If Prefixed(u,"jcr6_") And myextention=ExtractExt(u) 
			Local ex$ = AppDir+"/"+u+" "+p
			?win32
			ex = Replace(ex,"/","\")
			'Print ex
			?
			system_ ex 'AppDir+"/"+u+" "+p
			EndIf
		Next

