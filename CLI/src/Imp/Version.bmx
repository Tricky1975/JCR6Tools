Import tricky_units.MKL_Version
MKL_Version "",""
MKL_Lic     "",""


Function MKL_Post()
If Len(AppArgs)>1
	If AppArgs[1]="*VERSION*" Or AppArgs[1]="*FULLVERSION*"
		Print StripAll(AppFile)+"~t"+"v"+MKL_NewestVersion()
		If AppArgs[1]="*FULLVERSION*"
			Print MKL_GetAllversions()
			EndIf
			End
		EndIf	
	EndIf
End Function	

