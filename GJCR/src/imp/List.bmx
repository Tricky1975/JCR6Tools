Rem
	JCR6 - GJCR - List
	
	
	
	
	(c) Jeroen P. Broks, 2015, 2017, All rights reserved
	
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
Version: 17.04.27
End Rem
Strict
Import jcr6.jcr6main
Import brl.eventqueue
Import bah.Volumes
Import "window.bmx" 
Import "comments.bmx"
Import "viewassoc.bmx"
Import "view.bmx"

'Incbin "JCR.png"

MKL_Version "JCR6 - List.bmx","17.04.27"
MKL_Lic     "JCR6 - List.bmx","GNU General Public License 3"


Private

Global CFile$ 
Global JCR:TJCRDir

Type ListTab Extends TTab 


	Method Flow(ID,Source:TGadget,Extra$,ExtraGadget:TGadget)
	'fileinfo.setenabled CFile<>""
	If cfile And JCR
		Select JCR_Changed(JCR)
			Case 0 ' Do nothing
			Case 1,2
				Notify "One of the main files in this resource appears to have been modified, and will be reloaded!"
				Reload
			Case 3
				If FileType(cfile)
					Notify "One of the main files has been removed. I will try to reload!"
					Reload
				Else
					Notify "The root main file has been removed. A reload is not possible!"
					FreeGadget root
					cfile = ""					
				EndIf
			Case 4
				Notify "An unregistered resource file has been tied into the JCR6 resource.~nThis can only be the result of a bug in either GJCR or the underlying JCR6 system!~nPlease notify Jeroen Broks on his github repository: http://github/Tricky1975/JCR6Tools~n~nA direct reload is currently not possible!"
				cfile = ""
				FreeGadget root	
			EndSelect
		EndIf		
	Local s,f$
	Select id
		Case event_windowaccept	Accept Extra
		Case event_gadgetselect
			NodeSelected ExtraGadget 'TGadget(EventExtra())
		Case event_gadgetaction
			Select source
				Case tree,BView 
					PrepareView
				Case recentfiles
					s = SelectedGadgetItem(recentfiles)
					If s>=0 accept Recentarray[s]
				Case BExtr
					f = RequestFile("Extract this entry to:","Any File:*",1)
					If f Extract f
				Case BXAll
					ExtractAll	
				End Select	 
		End Select 
	bxall.setenabled CFile<>""
	fxall.setenabled CFile<>""	
	End Method
	
	Method HelloExtra()
	End Method
	
	End Type
	
Type TEntryNode	
	Field File$
	Field kind ' 1 = file, 2 = directory, 0 = JCR File itself
	End Type
	
Global rootnode:TEntryNode = New TEntryNode
rootnode.file="*"
rootnode.kind=0
	
Global EntryNodes:TMap = New TMap
Global DirNodes:TMap = New TMap

Function Node:TentryNode(GetNode:Object)	
Global RGetNode:TGadget
If TGadget(GetNode)
	RGetNode = TGadget(getnode)
ElseIf String(getnode)
	rgetnode = TGadget(MapValueForKey(dirnodes,String(getnode)))
Else
	fatalerror "Unknown type to retreive a node"
	EndIf
If Not rgetnode fatalerror "Could not retrieve the key to get the node"	
If getNode=root Then Return rootnode
Return tentrynode(MapValueForKey(EntryNodes,RGetNode))
End Function

Function GadNode:TGadget(k$)
If Not k Return root
Return TGadget(MapValueForKey(dirnodes,k))
End Function

Global ListPanel:TGadget = HelloPanel("List",New ListTab)
Global PW = ClientWidth(ListPanel)
Global PH = ClientHeight(ListPanel)

'CreateLabel "Current file:",0,0,200,15,ListPanel
'Global CurrentFile:TGadget = CreateLabel("< NONE >",200,0,400,15,listpanel)
'Global fileinfo:TGadget = CreateButton("File Info",800,0,150,15,listpanel); HideGadget fileinfo ' At second thought, I may not need this one, but I keep it as a safety plug.

Global BView:TGadget = CreateButton("View",0,0,100,25,ListPanel)
Global BExtr:TGadget = CreateButton("Extract",100,0,100,25,ListPanel)
Global BXAll:TGadget = CreateButton("Extract all to:",200,0,200,25,listpanel)
Global FXAll:TGadget = CreateTextField(400,0,200,25,listpanel)
Global FileButtons:TList = CreateList()
ListAddLast FileButtons,BView
ListAddLast filebuttons,bextr
For Local fb:TGadget = EachIn filebuttons 
	DisableGadget fb
	Next
	
Global RecentFiles:TGadget = CreateComboBox(PW-200,0,200,25,ListPanel)
Global RecentList:TList = New TList
Global RecentArray:String[ ]
LoadRecent

Function LoadRecent()
Local file$ = "JCR6/GJCR/RecentFiles.txt"
?Linux
file = "."+File
?
Local fullfile$ = GetUserAppDir() + "/" + File
If Not FileType(fullfile) Return
Local BT:TStream = ReadFile(FullFile)
If Not bt Return
Local L$
While Not Eof(BT)
	L = Trim(ReadLine(BT))
	If L ListAddLast recentlist,L
	Wend
CloseFile BT
UpdateRecent()
End Function

Function UpdateRecent(F$="")
If F 
	ListRemove RecentList,F
	ListAddFirst RecentList,F
	EndIf
'RecentArray = String[](ListToArray(RecentList))
Local c = CountList(recentlist)
recentarray = New String[c]
ClearGadgetItems RecentFiles
Local ak=0
For Local File$=EachIn RecentList
	AddGadgetItem RecentFiles,StripDir(File)
	recentarray[ak]=file; ak:+1
	Next
saverecent	
End Function

Function SaveRecent()
Local file$ = "JCR6/GJCR/RecentFiles.txt"
?Linux
file = "."+File
?
Local fullfile$ = GetUserAppDir() + "/" + File
Local dir$ = ExtractDir(FullFile)
If Not CreateDir(Dir,1) Return Error("Error Saving Recent File List (MKD)")
Local BT:TStream = WriteFile(Fullfile)
If Not BT Return Error("Error Saving Recent File List (WFL)")
For Local F$=EachIn recentlist
	WriteLine BT,F
	Next
CloseFile BT	
End Function
	

Global Tree:TGadget = CreateTreeView(0,25,PW,(PH-200)-25,ListPanel)
Global treeroot:TGadget = TreeViewRoot(tree)
SetGadgetColor tree,80,20,0,True
SetGadgetColor tree,255,180,0,False
Global Root:TGadget


Global JCRInfo:TGadget  = CreatePanel(0,PH-200,PW,200,ListPanel)
Global FileInfo:TGadget = CreatePanel(0,PH-200,PW,200,ListPanel)
Global DirInfo:TGadget  = CreatePanel(0,PH-200,PW,200,ListPanel)
Global InfoPanels:TGadget[] = [JCRInfo,FileInfo,DirInfo]
For Local I:TGadget=EachIn InfoPanels HideGadget I Next
Global CInfo=-1


CreateLabel "File:     ",0, 0,200,15,JCRInfo 
CreateLabel "Size:     ",0,15,200,15,JCRInfo 
CreateLabel "Case:     ",0,30,200,15,JCRInfo 
CreateLabel "FAT:      ",0,45,200,15,JCRInfo 
CreateLabel "Entries:  ",0,60,200,15,JCRInfo 
CreateLabel "Type:     ",0,75,200,15,JCRInfo
CreateLabel "Signature:",0,90,200,15,JCRInfo

Global JIFile:TGadget = CreateLabel("--",200, 0,200,15,JCRInfo) 
Global JISize:TGadget = CreateLabel("--",200,15,200,15,JCRInfo) 
Global JICase:TGadget = CreateLabel("??",200,30,200,15,JCRInfo) 
Global JISFAT:TGadget = CreateLabel("--",200,45,200,15,JCRInfo) 
Global JIEntr:TGadget = CreateLabel("--",200,60,200,15,JCRInfo) 
Global JIType:TGadget = CreateLabel("--",200,75,200,15,JCRInfo)
Global JISign:TGadget = CreateLabel("--",200,90,200,15,JCRInfo)

CreateLabel "Directory: ",0,0,200,15,DirInfo 
Global DIName:TGadget = CreateLabel("--",200,0,200,15,DirInfo)

CreateLabel "File:       ",0,  0,200,15,FileInfo 
CreateLabel "Size:       ",0, 15,200,15,FileInfo 
CreateLabel "Compressed: ",0, 30,200,15,FileInfo 
CreateLabel "Down to:    ",0, 45,200,15,FileInfo 
CreateLabel "Offset:     ",0, 60,200,15,FileInfo 
CreateLabel "Algorithm:  ",0, 75,200,15,FileInfo 
CreateLabel "Author:     ",0, 90,200,15,FileInfo 
CreateLabel "Unix perm:  ",0,105,200,15,fileinfo
CreateLabel "Main File:  ",0,120,200,15,FileInfo 

Global FIFile:TGadget = CreateLabel("--",200,  0,200,15,FileInfo)
Global FISize:TGadget = CreateLabel("--",200, 15,200,15,FileInfo)
Global FIComp:TGadget = CreateLabel("--",200, 30,200,15,FileInfo)
Global FIDown:TGadget = CreateLabel("--",200, 45,200,15,FileInfo)
Global FIOffs:TGadget = CreateLabel("--",200, 60,200,15,FileInfo)
Global FIAlgo:TGadget = CreateLabel("--",200, 75,200,15,FileInfo)
Global FIAuth:TGadget = CreateLabel("--",200, 90,200,15,FileInfo)
Global FIUPrm:TGadget = CreateLabel("--",200,105,200,15,FileInfo)
Global FIMain:TGadget = CreateLabel("--",200,120,200,75,FileInfo)


Global JIFW = ClientWidth(FileInfo)
Global JIFH = ClientHeight(FileInfo)
CreateLabel "Notes:",420,0,JIFW-420,15,FileInfo
Global FINotes:TGadget = CreateTextArea(420,15,JIFW-420,JIFh-15,FileInfo,TEXTAREA_READONLY|Textarea_WordWrap)




' -- Let's get the entire tree --
' Add a node
Function AddNode(cap$,parent:TGadget,kind)
Local n:TGadget = AddTreeViewNode(StripDir(cap),parent)
Local e:TEntryNode = New TEntryNode
e.file = cap
e.kind = kind
MapInsert dirnodes,cap,n
MapInsert entrynodes,n,e
End Function

' Add a dir node with all the shit
Function AddDir(d$,L:TList,parent:TGadget)
Print "Adding dir: ~q"+d+"~q"
Local F$
Local n:TGadget
For F=EachIn L
	If ExtractDir(F)=d
		AddNode(f,parent,2)
		AddDir(f,L,GadNode(f))
		EndIf
	Next
End Function

' The main tree builder
Function Accept(File$)
Local TempJCR:TJCRDir = JCR_Dir(File)
If Not TempJCR Return jerror("File "+File+" could not be read as a valid JCR file!") 
JCR = TempJCR 
' Hide the info panels 
For Local ak=0 Until Len(infopanels) HideGadget infopanels[ak] Next 
' Let's get all the directories listed before we start crackin' 
Local L:TList = New TList 
Local F$,D$ 
For F$=EachIn MapKeys(JCR.Entries)
	D = ExtractDir(F)
	While D
		If Not ListContains(L,D) ListAddLast L,D; Print "Added to list: "+D 
		D = ExtractDir(D) 
		Wend 
	Next 
	SortList L 
' Let's now put this all in the tree view
If root FreeGadget root
root = AddTreeViewNode("JCR: "+file,treeroot)
ClearMap entrynodes 
ClearMap dirnodes 
AddDir("",L,root) 
CFile = File 
'SetGadgetText currentfile,file ' Not needed since the root node is name this way ;) 
Local E:TJCREntry 
Local Dr$ 
For E=EachIn MapValues(JCR.Entries) 
	If JCR.Config.B("__CaseSensitive")
		Dr = ExtractDir(E.FileName) 
		Else
		Dr = ExtractDir(E.FileName.toUpper()) 
		EndIf
	Addnode E.FileName,GadNode(Dr),1 
	Next
listcomments(JCR)	 
For Local gb:TGadget=EachIn FileButtons 
	gb.setenabled 0 
	Next
updaterecent File 	
End Function 

Function Reload()
If Not Cfile Return
If Not FileType(CFile) Return Notify(Cfile+" appears to be removed making a reload impossible")
Local file$ = CFile
FreeGadget root
CFile = ""
Accept file
End Function

' Let's expose the data every node provides
Type TIMain
	Method GiveData(E:tentrynode) Abstract
	End Type
	
Type TIJCR Extends TIMain
	Method GiveData(E:Tentrynode)
	Local sense$[]=["Insensitive","Sensitive"]
	Local cnt=0
	Local Signature$ = "None"
	If JCR.Config.S("__Signature") Signature = JCR.Config.S("__Signature")
	For Local f$=EachIn MapKeys(JCR.entries) cnt:+1 Next
	SetGadgetText JIFile,StripDir(CFile)
	SetGadgetText JISize,FileSize(CFile)+" bytes"
	SetGadgetText JICase,sense[JCR.Config.I("&__CaseSensitive")]
	SetGadgetText JISFAT,JCR.FatAlg
	SetGadgetText JIEntr,cnt+""
	SetGadgetText JIType,JCR.DirDrvName
	SetGadgetText JISign,Signature
	End Method	
	End Type

Type TIFile Extends TIMain
	Method GiveData(E:Tentrynode)
	Local File$ = E.File
	If Not JCR.Config.B("__CaseSensitive") File=Upper(File)
	Local Ent:TJCREntry = TJCREntry(MapValueForKey(JCR.entries,File))
	If Not Ent Return error("Unable to retrieve the data for entry: "+E.File)
	SetGadgetText FIFile,StripDir(Ent.FileName)
	SetGadgetText FISize,Ent.Size+" bytes"
	SetGadgetText FIComp,Ent.CompressedSize+" bytes"
	If Ent.Size=0 Or Ent.CompressedSize=Ent.Size
		SetGadgetText FIDown,"--"
		Else
		Local Ratio = Floor(Double(Double(Ent.CompressedSize)/Double(Ent.Size)*100))
		SetGadgetText FIDown,Ratio+"%"
		EndIf
	SetGadgetText FIOffs,Hex(Ent.Offset)
	SetGadgetText FIAlgo,Ent.Storage
	SetGadgetText FIAuth,Ent.Author	
	SetGadgetText FINotes,Ent.VNotes()
	SetGadgetText FIMain,Ent.MainFile
	If ent.unixpermissions<0
		SetGadgetText FIUPrm,"< Not defined >"
	Else
		SetGadgetText FIUPrm,Permissions(ent.unixpermissions)
	EndIf
	End Method	
	End Type

Type TIDir Extends TIMain
	Method GiveData(E:Tentrynode)
	SetGadgetText DIName,StripDir(E.File)
	End Method	
	End Type

Global TI:TIMain[3] 	
TI[0] = New TIJCR
TI[1] = New TIFile
TI[2] = New TIDir

Function NodeSelected(Source:TGadget)
If Not source Return
Local E:tentrynode = Node(Source)
If Not E Return
Local ak
For ak=0 Until Len(infopanels) 
	infopanels[ak].setshow ak=e.kind 
	'Print "Show "+ak+" = "+Int(ak=e.kind)
	Next
For Local gb:TGadget=EachIn FileButtons
	gb.setenabled e.kind=1
	Next
ti[e.kind].GiveData(E)
End Function


Function PrepareView() 
Local CNode:TGadget = SelectedTreeViewNode(Tree) 
If Not Cnode Return 
Local E:Tentrynode = Node(CNode) 
If Not E Return 
If E.kind<>1 Return
ViewAssoc JCR,E.File
End Function

Function Extract(F$)
Local CNode:TGadget = SelectedTreeViewNode(Tree) 
If Not Cnode Return 
Local E:Tentrynode = Node(CNode) 
If Not E Return 
If E.kind<>1 Return
JCR_Extract JCR,E.file,f,1
If FileType(f)=1
	Notify "File extracted as: "+F
Else
	jerror "Target file not found: "+F
	EndIf
End Function

Function ExtractAll()
Local outdir$ = TextFieldText(FXAll)
Local count=0
Local hcnt$=""
If Not Outdir$ 
	If ExtractExt(CFile).toUpper()="JCR" Outdir = StripExt(CFile) Else Outdir = CFile + ".Folder"
	While FileType(OutDir+hcnt) 
		count:+1	
		hcnt$="."+count
		Wend
	outdir:+hcnt		
	EndIf

If Not Confirm("Are you sure you wish to extract all files to folder ~q"+outdir+"~q?~n~nWARNING! If any files appear to exist with the same name, they will all be overwritten!~n~n") Return
Local E:TJCREntry
Local act$
For e=EachIn MapValues(JCR.Entries)
	If e.storage="Store" act = "Extracting: " Else act = "("+E.storage+"): Expanding: "
	SetStatusText window,act+E.FileName
	PollEvent
	JCR_Extract JCR,E.filename,outdir
	Next
SetStatusText Window,"All done!"
PollEvent	
Notify "Extraction done"
SetStatusText Window,""
End Function


' Thes lines must always be on the bottom of this file.
setupcommentstab 
setupview
