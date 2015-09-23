Rem
	Window for JCR6's GJCR
	
	
	
	
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
	Window for JCR6's GJCR
	
	
	
	
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
Import maxgui.drivers
Import tricky_units.MKL_Version
Import "error.bmx"

MKL_Version "JCR6 - window.bmx","15.09.02"
MKL_Lic     "JCR6 - window.bmx","GNU General Public License 3"



Global window:TGadget = CreateWindow("GJCR - for JCR6 - Version "+MKL_NewestVersion()+" - Coded by Tricky",0,0,1000,800,Null,window_clientcoords|window_titlebar|WINDOW_ACCEPTFILES|WINDOW_STATUS|Window_hidden|Window_Center)
Global WTabs:TGadget = CreateTabber(0,0,ClientWidth(window),ClientHeight(Window),window)



Type TTab
	Field Panel:TGadget
	Field PW,PH
	Method Flow(ID,Source:TGadget,Extra$,ExtraGadget:TGadget) Abstract
	Method HelloExtra() Abstract
	
	Method Hello()
	panel = CreatePanel(0,0,ClientWidth(WTabs),ClientHeight(WTabs),WTabs)
	End Method
	
	Method New() Hello()  End Method
	
	End Type
	
Global Tabs:TTab[20]
	
Function Hello(TabName$,tab:TTab)	
Local c
While tabs[c]
	c:+1
	If c>=Len(tabs) fatalerror "Too many tabs!"
	Wend	
tabs[c] = Tab
AddGadgetItem Wtabs,tabname
tab.helloextra
Return c
End Function

Function Pan:TGadget(c)
Return tabs[c].panel
End Function

Function HelloPanel:TGadget(TabName$,Tab:TTab)
Return Pan(Hello(TabName,Tab))
End Function

Global activetab
Function ShowPanel(c)
For Local ak=0 Until Len(tabs)
	If tabs[ak] tabs[ak].panel.setshow ak=c
	Next
activetab=c	
End Function
