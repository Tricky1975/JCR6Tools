Rem
	JCR6 - GJCR - Run
	
	
	
	
	(c) Jeroen P. Broks, 2015, 2016, All rights reserved
	
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
Strict
Import brl.eventqueue
Import maxgui.drivers
Import tricky_units.MKL_Version

Import "window.bmx"

MKL_Version "JCR6 - run.bmx","16.05.03"
MKL_Lic     "JCR6 - run.bmx","GNU General Public License 3"


Function run()
Local ID,source:TGadget,Extra$,extragadget:TGadget,ExtraObject:Object
ShowGadget window
showpanel 0
Repeat
ID = EventID()
source = TGadget(EventSource())
extraobject = EventExtra()
Extra = String(extraObject)
extragadget = TGadget(extraobject)
menu_copy.setenabled ListContains(allowcopy,ActiveGadget())
Select ID
	Case event_appterminate,event_windowclose
		End
	Case event_Menuaction
		Select EventData()
			Case 1001
				GadgetCopy ActiveGadget	()
			End Select
	Case event_gadgetaction
		Select source
			Case wtabs
				showpanel SelectedGadgetItem(WTabs)
			End Select
	End Select
tabs[activetab].flow ID,Source,Extra,Extragadget
PollEvent
Forever
End Function
