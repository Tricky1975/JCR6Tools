Rem
	JCR6 - CLI - Update lib
	Updates JCR6 files for modification
	
	
	
	(c) Jeroen P. Broks, 2016, All rights reserved
	
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
Version: 16.03.12
End Rem
Strict

Import    brl.retro
Import    tricky_units.Listfile
Import    tricky_units.Dirry
Import    "ModsINeed.bmx" ' This contains just all mods all components actively looking inside a JCR6 file or writing a JCR6 require.
Import    "WildCard.bmx"

 
MKL_Version "JCR6 - Update.bmx","16.03.12"
MKL_Lic     "JCR6 - Update.bmx","GNU General Public License 3"


Global Original$,Target$ ',RemoveOriginal
Global deleted

Type toffset
	Field newoffset
	'Field list:TList = New TList
	End Type

Global OffSetMap:TMap = New TMap
	
Function NewOffset(offs,JO:TStream)
Local hoffs$ = Hex(offs)
Local o:toffset
If Not MapContains(offsetmap,hoffs)
	o = New toffset
	MapInsert offsetmap,hoffs,o
	o.newoffset = StreamPos(JO)
	EndIf
Return toffset(MapValueForKey(offsetmap,hoffs)).newoffset
End Function	

Function GotOffs(offs)
Local hoffs$ = Hex(offs)
Return MapContains(offsetmap,hoffs)
End Function

Function Got(L:TList,e$)
For Local c$=EachIn L 
	If Upper(c)=Upper(e) Return True 
	Next
Return False
End Function

Global updateremoved:TList = New tlist

Function UpdateJCR:TJCRCreate(O$,Remove:TList,chat=False)
If original Or target Print "ERROR! I can only update one JCR at once!" End
original = o
deleted = 0
updateremoved = New TList
ClearMap offsetmap
'removeoriginal = True
If (Not chat) And JCR_Type(o)<>"JCR6" 
		Print "This resource is of the "+JCR_Type(o)+" type."
		Print "JCR6 is unable to modify this type, however, it *IS* possible to convert this archive to JCR6 and bring the modifications to the newly created file"
		Print "The original shall be kept, so this is entirely safe!"
		If Input("Do you want me to convert this archive? (Y/N) ").toUpper()<>"Y" End
		original = StripExt(o)+".jcr"
		If FileType(original)
		   If Input("The output JCR6 file ~q"+original+"~q appears to exist. Overwrite ? (Y/N) ").toupper()<>"Y" End
		   EndIf
ElseIf JCR_Type(o)<>"JCR6" 
	Print "ERROR! I can only update resources of the JCR6 type" 
	End
	EndIf
Local d$ = ExtractDir(original)
Repeat
target = d+"/"+Hex(Rand(0,MilliSecs()))+".JCR"
If Chr(target[0])="/" And Chr(o[0])<>"/" target=Right(target,Len(target)-1)
Until Not FileType(target)
Local JD:TJCRDir = JCR_Dir(o); If Not JD Print "ERROR! Failed to access ~q"+o+"~q" End
Local JI:TStream = ReadFile(o); If Not JI Print "ERROR! Failed to open ~q"+o+"~q" End
Local JO:TJCRCreate = JCR_Create(target,JD.config); If Not JO Print "ERROR! Failed to write temp file ~q"+o+"~q" End
Local docopy,newoffs,ent:TJCREntry,bank:TBank
For Local entry:TJCREntry = EachIn MapValues(JD.entries)
	DebugLog "Updating data for: "+entry.filename
	If Not got(remove,entry.filename)
		' First of all we want to know what the new location will be
		docopy = Not gotoffs(entry.offset) ' Aliassed files will remain aliased. Yeah yeah, we go for sophistication!
		newoffs = newoffset(entry.offset,JO.bt)
		ent = New TJCREntry
		ent.FileName = entry.filename
		ent.MainFile$ = target
		ent.Size = entry.size
		ent.Offset = newoffs
		ent.Storage = entry.storage
 		ent.CompressedSize = entry.compressedsize
		ent.Author = entry.Author
		ent.Notes = entry.Notes
		MapInsert ent.mv,"$__Entry",Ent.FileName
		MapInsert ent.mv,"%__Size",Ent.Size+""
		MapInsert ent.mv,"%__CSize",Ent.CompressedSize+""
		MapInsert ent.mv,"%__Offset",Ent.Offset+""
		MapInsert ent.mv,"$__Storage",Ent.Storage
		MapInsert ent.mv,"$__Author",Ent.Author
		MapInsert ent.mv,"$__Notes",Ent.Notes
		MapInsert JO.Entries,Upper(entry.filename),Ent	
		If docopy 
			bank = CreateBank(Entry.Compressedsize)
			SeekStream JI,entry.offset
			ReadBank  bank,ji   ,0,entry.compressedsize ' We don't have to uncompress this shit now. This also means unsupported compression methods will not cause you to suffer on this operation.
			WriteBank bank,jo.bt,0,entry.compressedsize
			DebugLog "File has been repositioned to "+newoffs
			Else
			DebugLog "File is an alias, I just wrote a new reference to the existing offset "+newoffs
			EndIf
		DebugLog "This file should be 'done' now"				
	Else
		If chat Print "  = "+entry.filename+" ... deleted"
		ListAddLast updateremoved,Upper(entry.filename)
		deleted:+1
		EndIf
	Next
JO.comments = JD.comments
CloseFile JI	
Return JO	
End Function

Function CloseUpdateJCR(JO:TJCRCreate,storage$="Store")
If Not original And target Print "ERROR! I cannot close a JCR file when none is being update" End
JO.close storage
DebugLog "Finalizing update!"
If FileType(original)	
	DebugLog "Deleting: "+original
	If Not DeleteFile(original) Print "ERROR! I cannot delete the old archive" End
	EndIf
If Not RenameFile(target,original) Print "ERROR! I cannot rename temp JCR "+target+", back to the name of the original JCR6 "+original End
target = ""
original = ""
End Function


