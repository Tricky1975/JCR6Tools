Rem
	JCR6 - GJCR - viewassoc
	
	
	
	
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
Version: 15.09.02
End Rem
Rem
/*
	JCR6 - GJCR - viewassoc
	
	
	
	
	(c) Jeroen P. Broks, , All rights reserved
	
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

Import brl.map
Import brl.oggloader

Import tricky_units.StringMap
Import tricky_units.MKL_Version
Import tricky_units.os_audiodrivers
Import jcr6.jcr6main

Import "error.bmx"
Import "view.bmx"


MKL_Version "JCR6 - viewassoc.bmx","15.09.02"
MKL_Lic     "JCR6 - viewassoc.bmx","GNU General Public License 3"

' ---- MY PRIVATE STUFF, KEEP OUT! ;) ----
Private
Global AssocMap:TMap = New TMap

Type TBASE
	Method View(JCR:TJCRDir,Entry$) Abstract
	End Type

Type TOGG Extends TBASE
	Method View(JCR:TJCRDir,Entry$)
	Local au:TSound = LoadSound(JCR_B(JCR,Entry))
	If Not au Return error("The sound in this entry could not be loaded correctly and therefore not be played")
	PlaySound au
	End Method
	End Type
Global OGG:TOGG = New TOGG
MapInsert assocmap,"OGG",OGG


Type TPicture Extends TBASE
	Method View(JCR:TJCRDir,Entry$)
	ViewPic.Receive(JCR_B(JCR,Entry))
	End Method
	End Type
Global PicD:TPicture = New TPicture
MapInsert assocmap,"JPG",picD
MapInsert assocmap,"PNG",picD
MapInsert assocmap,"JPEG",picD
	
	
	
		

Type TREST Extends TBASE
	Method View(JCR:TJCRDir,Entry$)
	'Notify "Please wait, we're still working on this!"
	ViewText.Receive(JCR_B(JCR,Entry))
	End Method
	End Type
Global Rest:TRest = New TRest



Function GetAssoc:TBASE(Ext$)
Local Ret:TBASE = Rest
Local Get:TBASE = TBASE(MapValueForKey(AssocMap,Ext))
If Get Ret=Get
Return Ret
End Function


' --- OKAY, OPEN YOUR EYES, NOW YOU MAY LOOK :P ----
Public
Function ViewAssoc(JCR:TJCRDir,Entry$)
Local Ext$ = Upper(ExtractExt(Entry))
Local Assoc:TBase = getassoc(ext)
Assoc.View(JCR,Entry)
End Function
