Rem
/*
	GJCR (or GUI - JCR) for JCR6
	A GUI based program for easily handing JCR6 files
	
	
	
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
Framework maxgui.drivers
Import tricky_units.MKL_Version
Import jcr6.jcr6main
Import jcr6.realdir
Import jcr6.wad
Import jcr6.zlibdriver
Import jcr6.jcr5driver
Import jcr6.quakepak
Import brl.pngloader
Import brl.jpgloader
Import brl.oggloader



' Main Window
Import "imp/window.bmx"

' Tabs
Import "imp/about.bmx"
Import "imp/create.bmx"
Import "imp/list.bmx"
Import "imp/comments.bmx"
Import "imp/view.bmx"

' Run this shit
Import "imp/run.bmx"

' Icon for the Windows version
?Win32
Import "WinIcon/JCR.o"
?

' Version information
MKL_Version "JCR6 - BlitzMax/Apps/GJCR/GJCR.bmx","15.05.20"
MKL_Lic     "JCR6 - BlitzMax/Apps/GJCR/GJCR.bmx","GNU - General Public License ver3"

' Everything set, let's get ready to rumble
Run
