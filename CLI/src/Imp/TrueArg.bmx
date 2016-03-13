Rem
	JCR6 - CLI Tools
	Program Argument Manager
	
	
	
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
Version: 16.03.13
End Rem
Strict

Import tricky_units.MKL_Version 

MKL_Version "JCR6 - TrueArg.bmx","16.03.13"
MKL_Lic     "JCR6 - TrueArg.bmx","GNU General Public License 3"

Global TArg$[]
Global Switches:TList

Function GetTrueArgs()
Local LArg:TList = New TList
switches:TList = New TList
For Local t$=EachIn AppArgs
	DebugLog "working on: "+t
	?win32
	If Chr(t[0])="-" And t<>"-VERSION-"
	?Not win32	
	If Chr(t[0])="-"
	?
		ListAddLast switches,t		
	Else
		ListAddLast Larg,t
		DebugLog "Non-Switch parameter: "+t
		EndIf
	Next
TArg = New String[CountList(Larg)]; DebugLog "Non-Switch pararms: "+CountList(Larg)
Local i=0
For Local tx$=EachIn Larg
	targ[i] = tx
	i:+1
	DebugLog "Got: "+i+">"+tx
	Next
End Function

Function GotSwitch(s$)
Return ListContains(switches,s)
End Function

GetTrueArgs
