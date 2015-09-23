Rem
	JCR6 - GJCR - Create
	
	
	
	
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
	JCR6 - GJCR - Create
	
	
	
	
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

Import jcr6.jcr6main
Import tricky_units.tree
Import brl.eventqueue
Import "window.bmx"
Import "error.bmx"

MKL_Version "JCR6 - create.bmx","15.09.02"
MKL_Lic     "JCR6 - create.bmx","GNU General Public License 3"

Incbin "Create.png"
Private

Const defaultdrv$ = "zlib"

Global Key$,dn,c=0

Type CreateTab Extends TTab 

	Method Flow(ID,Source:TGadget,Extra$,extraGadget:TGadget)
	Select ID
		Case event_windowaccept
			Select FileType(Extra)
				Case 0	error "Somehow the file "+extra+" could not be identified"
				Case 1	PackFile Extra
				Case 2	PackDir Extra
				Default	error "File "+extra+" is identified in a type GJCR does not yet support ("+FileType(extra)+"). Either there's something wrong, or you compiled this version of GJCR with a higher version of BlitzMax."
				End Select
		Case event_gadgetaction
			Select source
				Case browseoutput
					Local F$=RequestFile("Select a file to output to","JCR file:jcr",True)
					If f SetGadgetText outputfile,f
				End Select	
		End Select
	End Method
	
	Method HelloExtra()
	End Method
	
	End Type



Global CrP:TGadget = HelloPanel("Create",New CreateTab)
Global PW = ClientWidth(Crp)
Global PH = ClientHeight(crp)
Global PHW = PW/2
Global TFW = PHW-50

Global pix:TPixmap = LoadPixmap("incbin::Create.png")
Global pxw = PixmapWidth(pix)
Global pxh = PixmapHeight(pix)
Global pixpanel:Tgadget = CreatePanel(PW-pxw,ph-pxh,pxw,pxh,CrP)
SetPanelPixmap pixpanel,pix

CreateLabel "Output File name:",0,0,PHW,25,crp
CreateLabel "Default file storage:",0,25,PHW,25,crp
CreateLabel "Default filetable storage:",0,50,PHW,25,crp

Global Outputfile:TGadget = CreateTextField(PHW, 0,TFW-110,25,crp)
Global BrowseOutput:TGadget = CreateButton("Browse",PHW+(TFW-100),0,100,25,crp)

Global FileStorage:TGadget = CreateComboBox(PHW,25,TFW,25,crp)
Global FATStorage :TGadget = CreateComboBox(PHW,50,TFW,25,crp)


Global drivers$[] = ListCompDrivers()
Print Len(drivers)+" drivers are found"
For key=EachIn drivers
	AddGadgetItem filestorage,key
	AddGadgetItem  fatstorage,key
	If key=defaultdrv dn=c
	c:+1
	Next
SelectGadgetItem filestorage,dn
SelectGadgetItem  fatstorage,dn


' The JCR creation tool themselves ;)

Function PackFile(F$)
Local OutF$ = TextFieldText(Outputfile)
Local flalgn = SelectedGadgetItem(FileStorage)
Local ftalgn = SelectedGadgetItem( FATStorage)
If flalgn=-1 Return error("No valid compression algorithm chosen for files")
If ftalgn=-1 Return error("No valid compression algorithm chosen for FAT")
Local flalg$ = GadgetItemText(filestorage,flalgn)
Local ftalg$ = GadgetItemText(filestorage,ftalgn)
If Not OutF OutF = F+".JCR"
If Not Confirm("Pack "+F+" into "+OutF+"?") Return
Local BT:TJCRCreate = JCR_Create(OutF)
BT.addentry(F$,StripDir(F),flalg)
bt.close ftalg
Notify "File has been packed into: "+OutF
End Function

Function PackDir(F$)
Local OutF$ = TextFieldText(Outputfile)
Local flalgn = SelectedGadgetItem(FileStorage)
Local ftalgn = SelectedGadgetItem( FATStorage)
If flalgn=-1 Return error("No valid compression algorithm chosen for files")
If ftalgn=-1 Return error("No valid compression algorithm chosen for FAT")
Local flalg$ = GadgetItemText(filestorage,flalgn)
Local ftalg$ = GadgetItemText(filestorage,ftalgn)
If Not OutF OutF = F+".JCR"
If Not Confirm("Pack "+F+" into "+OutF+"?") Return
Notify "Please note, especially when you are packing large directories. It may seem the program has crashed until the operation is completed. This is normal, so don't be alarmed!"
SetStatusText window,"Analysing tree: "+F
PollEvent
Local Tree:TList = CreateTree(F)
Local BT:TJCRCreate = JCR_Create(OutF)
For Local file$=EachIn tree
	SetStatusText window,"Freezing: "+file
	PollEvent
	bt.addentry F+"/"+File,File,flalg
	Next
SetStatusText window,"Finalizing..."
PollEvent
BT.close ftalg
SetStatusText window,""
PollEvent
Notify "Directory "+f+" has been packed into: "+OutF	
End Function


	
