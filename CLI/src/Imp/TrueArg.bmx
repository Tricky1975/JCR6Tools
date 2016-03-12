Strict

Import tricky_units.MKL_Version 

MKL_Version "JCR6 - jcr6.bmx","16.03.12"
MKL_Lic     "JCR6 - jcr6.bmx","GNU General Public License 3"

Global TArg$[]
Global Switches:TList

Function GetTrueArgs()
Local LArg:TList = New TList
switches:TList = New TList
For Local t$=EachIn AppArgs
	DebugLog "working on: "+t
	If Chr(t[0])="-"
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
