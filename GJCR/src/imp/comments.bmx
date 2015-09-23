Rem
	JCR6 - GJCR - Comments
	
	
	
	
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
	JCR6 - GJCR - Comments
	
	
	
	
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

MKL_Version "JCR6 - comments.bmx","15.09.02"
MKL_Lic     "JCR6 - comments.bmx","GNU General Public License 3"


Private

Type CommentsTab Extends TTab 

	Method Flow(ID,Source:TGadget,Extra$,Extragadget:TGadget)
	Local idx,tag$
	If ID=EVENT_GadgetSelect And source=cmtlist
		idx = SelectedGadgetItem(CmtList)
		If idx<0
			SetGadgetText cmtview,""
		Else
			Print "reading comment index: "+idx
			tag = GadgetItemText(cmtlist,idx)
			Print "Tag = "+tag
			Print "<value>~n"+cmtjcr.comments.value(tag)+"~n</value>"
			SetGadgetText cmtview, cmtjcr.comments.value(tag)	
			EndIf
		EndIf
	End Method
	
	Method HelloExtra()
	End Method
	
	End Type
	


Global Comments:TGadget '= HelloPanel("Comments",New CommentsTab)


Global CmtList:TGadget '= CreateListBox(0,0,200,ClientHeight(comments),Comments)
Global cmtview:TGadget '= CreateTextArea(200,0,ClientWidth(comments)-200,ClientHeight(comments),comments)

Global CmtJCR:TJCRDir

Public

Function ListComments(J:TJCRDir)
Local cnt
ClearGadgetItems cmtlist
For Local c$=EachIn MapKeys(J.Comments)
	cnt:+1
	AddGadgetItem cmtlist,c
	Next
CmtJCR = J	
If cnt Notify "*** NOTICE~n~nThis file	contains "+cnt+" comments.~nThose comments can contain some important information (like license information) you really should read before accessing or extracting any data from this file!"
End Function

Function SetupCommentsTab()
Comments:TGadget = HelloPanel("Comments",New CommentsTab)
CmtList:TGadget = CreateListBox(0,0,200,ClientHeight(comments),Comments)
cmtview:TGadget = CreateTextArea(200,0,ClientWidth(comments)-200,ClientHeight(comments),comments,textarea_readonly)
SetGadgetFont cmtview,LookupGuiFont(GUIFONT_MonoSpaced,12)
End Function
