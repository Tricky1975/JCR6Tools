Framework brl.retro


Import    tricky_units.ListDir
Import    tricky_units.prefixsuffix
Import    "imp/Version.bmx"

MKL_Version "",""
MKL_Lic     "",""
MKL_Post

Global p$ = "*VERSION*"
Global myextention$ = ExtractExt(AppFile)

If Len(AppArgs)>1 
	If Upper(AppArgs[1])="FULL"
		p = "*FULLVERSION*"
		Print "Showing full version information of all components"
	Else
		Print "Showing version numbers of the components. Add the parameter 'full' for full information"
		EndIf
	EndIf

system_ AppDir+"/jcr6 "+p
For Local u$=EachIn ListDir(AppDir,LISTDIR_FILEONLY)
		If Prefixed(u,"jcr6_") And myextention=ExtractExt(u) system_ AppDir+"/"+u+" "+p
		Next

