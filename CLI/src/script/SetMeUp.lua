--[[
	A self setup for JCR6
	
	
	
	
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
Version: 16.12.21
]]

--- This script is not part of JCR6 itself. I only used it to both test the JCR6 scripter
--- but also to help it "build itself". A few handy lua libs I wrote had to be included too ya know ;)


jcr6file("libs.jcr")
config = config or {}

-- @IF $MAC
libdir = '/Volumes/Scyndi/Projects/Applications/Lua Libs For GALE'
-- @FI

-- @IF $WINDOWS
libdir = '/Projects/Lua Libs For GALE'
-- @FI
tree = GetTree(libdir)


for f in each(tree) do
    if lower(right(f,4))==".lua" then
       if not config[f] then          
          print("I do not yet know "..f)
          config[f] = { allow=upper(input("Add it ? (Y/N) "))=='Y' }
          end
       end
    end
    
debug = true    

globalstorage("zlib")
fatstorage("zlib")
addcomment("Hello","This is just a collection of lua libraries to make scripting for JCR6 easier. None of them are part of the JCR6 project itself, as they are all written for general uses, and several lua based programs of mine use them. Most of them are written and copyrighted by me (Jeroen Broks), however not all of them are. Most of them are licensed under the zlib license, but that is not always the case. In other words, which the license blocks inside the libs first before you extract them from this JCR6 file for your own usage!")
bldcnt = (bldcnt or -1) + 1
sig(DEC_HEX(rand(0,2000000000)).."-"..DEC_HEX(bldcnt))
for file,cfg in spairs(config) do
	  -- print(file)
    if cfg.allow then
       Add(libdir.."/"..file,"LIBS:"..file,{author="Jeroen P. Broks",notes="Usually libs are (c) Jeroen Broks and licensed under the zlib license however I advice to check inside the file itself to be sure!"})
       --Alias("LIBS:"..file,"ALIAS:"..file) 
       --Alias("LIBS:"..file,"ALIAS2:"..file) -- These two were solely meant to test if aliasing through a script works ;) 
       end 
    end    
        
