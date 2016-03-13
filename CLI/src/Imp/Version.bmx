Rem
	JCR6 - Command Line utilities
	Version Import File - All components of JCR6 CLI need this
	
	
	
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
Import tricky_units.MKL_Version
MKL_Version "JCR6 - Version.bmx","16.03.13"
MKL_Lic     "JCR6 - Version.bmx","GNU General Public License 3"


Function MKL_Post()
If Len(AppArgs)>1
      ?Win32
	If AppArgs[1]="-VERSION-" Or AppArgs[1]="-FULLVERSION-"
      ?Not win32
	If AppArgs[1]="*VERSION*" Or AppArgs[1]="*FULLVERSION*"
	?
		Print StripAll(AppFile)+"~t"+"v"+MKL_NewestVersion()
		?win32
		If AppArgs[1]="-FULLVERSION-"
		?Not win32
		If AppArgs[1]="*FULLVERSION*"
		?
			Print MKL_GetAllversions()
			EndIf
		End
		EndIf	
	EndIf
End Function	

'For i$=EachIn AppArgs Print "Got Arg: "+i Next
