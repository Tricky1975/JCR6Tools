Rem
/*
	JCR6 - GJCR - View
	
	
	
	
	(c) Jeroen Petrus Broks, 2015, All rights reserved
	
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


MKL_Version "JCR6 - BlitzMax/Apps/GJCR/imp/View.bmx","15.05.20"
MKL_Lic     "JCR6 - BlitzMax/Apps/GJCR/imp/View.bmx","GNU - General Public License ver3"


 

Type ViewTab Extends TTab 


	Method Flow(ID,Source:TGadget,Extra$,ExtraGadget:TGadget)
	End Method
	
	Method HelloExtra()
	End Method
	
	End Type
	

Global ViewList:TList = New TList
Global View:TGadget

Type TViewBase Abstract
	Field MainGadget:TGadget
	Method Receive(B:TBank) Abstract
	End Type


Function NewView(ViewScreen:TViewBase)
For Local V:TviewBase = EachIn viewlist 
	If v.maingadget HideGadget V.MainGadget
	Next
If ViewScreen 
	ShowGadget ViewScreen.MainGadget
	SelectGadgetItem WTabs,ViewIdx
	showpanel ViewIDX
	Print "Are we seeing tab #"+ViewIDX+"?"
	EndIf
End Function



Type TViewText Extends TViewBase
	Method receive(B:TBank)
	If Not MainGadget 
		MainGadget = CreateTextArea(0,0,ClientWidth(View),ClientHeight(View),View)
		SetGadgetFont MainGadget,LookupGuiFont(GUIFONT_MonoSpaced,12)
		SetGadgetColor mainGadget,0,255,255,False
		SetGadgetColor maingadget,0,  0,100,True
		EndIf
	If Not B Return JError("Content could not be read!"	)
	SetGadgetText MainGadget,LoadString(B)
	NewView ViewText
	End Method
	End Type
	
	
Type TViewPic Extends TViewBase
	Field Pix:TPixmap
	Field PixPanel:TGadget
	Field Info:TGadget
	Method Receive(B:TBank)
	If Not MainGadget 
		maingadget = CreatePanel(0,0,ClientWidth(View),ClientHeight(View),View)
		pixpanel = CreatePanel(0,0,ClientWidth(MainGadget),ClientHeight(MainGadget)-20,View)
		info = CreateLabel("",0,ClientHeight(MainGadget)-15,ClientWidth(Maingadget),15,View,LABEL_CENTER)
		EndIf
	Pix = LoadPixmap(B)
	If Not Pix Return Error("The image could not be loaded. Perhaps it's damaged.")
	Local PxW = PixmapWidth(Pix)
	Local PxH = PixmapHeight(pix)
	Local PnW = ClientWidth(pixpanel)
	Local PnH = ClientHeight(pixpanel)
	Local Modes[] = [PANELPIXMAP_CENTER,PANELPIXMAP_STRETCH]
	Local streched$[] = ["","(Scaled to fit in the window)"]
	Local toobig = PxW>PnW Or PxH>PnH
	Local mode = modes[toobig]
	SetGadgetPixmap pixpanel,pix,mode
	SetGadgetText info,"Format: "+PxW+"x"+PxH+"  "+Streched[toobig]
	newview ViewPic
	End Method
	End Type			

Global ViewIdx


Global ViewText:TViewText 
Global ViewPic:TViewPic

Function SetUpView()
ViewIdx = Hello("View",New ViewTab)
View = Pan(ViewIdx)
Print "Index for view panel = "+ViewIDX
'View = HelloPanel("View",New ViewTab)
NewView Null
ViewText:TViewText = New TViewText
ViewPic = New TViewPic
ListAddLast viewlist,viewtext
ListAddLast viewlist,viewpic
End Function


