Rem
/*
	JCR6 - GJCR - error
	
	
	
	
	(c) Jeroen P. Broks, 2015, All rights reserved
	
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
*/


Version: 15.05.20

End Rem
Strict
Import tricky_units.MKL_Version
Import jcr6.jcr6main

Function FatalError(err$)
Notify "*FATAL ERROR*~n~n"+err
End
End Function

Function Error(err$)
Notify "*ERROR*~n~n"+Err
End Function

Function JError(err$)
Local E$=Err
If JCR_Error
	E$:+"~n~n~nJCR Reported:~n"+JCR_Error.ErrorMessage+"~nIn JCR File: "+JCR_Error.File+", Entry: "+JCR_Error.Entry
	EndIf
error E
End Function	

MKL_Version "JCR6 - BlitzMax/Apps/GJCR/imp/error.bmx","15.05.20"
MKL_Lic     "JCR6 - BlitzMax/Apps/GJCR/imp/error.bmx","GNU - General Public License ver3"
