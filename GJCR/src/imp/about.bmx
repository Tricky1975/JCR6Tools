Rem
/*
	JCR6 - GJCR - about
	
	
	
	
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
Import "window.bmx" 

Incbin "JCR.png"

MKL_Version "JCR6 - BlitzMax/Apps/GJCR/imp/about.bmx","15.05.20"
MKL_Lic     "JCR6 - BlitzMax/Apps/GJCR/imp/about.bmx","GNU - General Public License ver3"


Private

Type AboutTab Extends TTab 

	Field vset = False
	Method Flow(ID,Source:TGadget,Extra$,Extragadget:TGadget)
	If Not vset 
		SetGadgetText v,MKL_GetAllversions()
		Print "Version data redone: ~n"+MKL_GetAllversions()+"~n~n"
		vset = True
		EndIf
	End Method
	
	Method HelloExtra()
	End Method
	
	End Type
	

Global about:TGadget = HelloPanel("About",New AboutTab)

Global logopixmap:TPixmap = LoadPixmap("incbin::JCR.png")

Global logo:TGadget = CreatePanel(0,0,GadgetWidth(about),PixmapHeight(logopixmap),about)

SetGadgetPixmap logo,logopixmap,PANELPIXMAP_CENTER


Global PW=GadgetWidth(about)

CreateLabel "GJCR For: JCR6",0,100,PW,15,about,label_center
CreateLabel "Coded by: Jeroen P. Broks",0,115,PW,15,about,label_center
CreateLabel "Version: "+MKL_NewestVersion(),0,130,PW,15,about,label_center
CreateLabel "(c) Jeroen Petrus Broks, 2015",0,160,PW,15,about,label_center
CreateLabel "JCR6 itself has been licensed under the Mozilla Public License v2",0,175,PW,15,about,label_center
CreateLabel "This GJCR application has been licensed under the GNU General Public License v3",0,190,PW,15,about,label_center
CreateLabel "The logo was made with www.flamingtext.com",0,205,PW,15,about,label_center
CreateLabel "Other pictures may NOT be used, but you may use your own pictures in stead when compiling this source",0,220,PW,15,about,label_center


Global v:TGadget = CreateLabel (MKL_GetAllversions(),0,250,PW,300,about)
SetGadgetFont v,LookupGuiFont(GUIFONT_MonoSpaced,12)

