Rem
	CLI - Script - Incbin
	Incbins all needed Lua scripts
	
	
	
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
Version: 16.03.15
End Rem
Strict

Import jcr6.fileasjcr
Import jcr6.zlibdriver


Incbin "UseDefs.lua"
Incbin "system.lua"
Incbin "libs.jcr"


Global LuaMap:TJCRDir = New TJCRDir

Function SetUpIncBin(f$)
If ExtractExt(f).toupper()<>"LUA" f:+".lua"
Local lsv$ = StripExt(f)+".lsv"
addraw luamap,"incbin::UseDefs.lua",f
addraw luamap,"incbin::system.lua","SYS:system.lua"
addraw luamap,f,"USER:"+StripDir(f)
If FileType(lsv) addraw luamap,lsv,"USER:"+StripAll(F)+".lsv"
JCR_AddPatch luamap,JCR_Dir("incbin::libs.jcr")
End Function
