--[[
        system.lua
	(c) 2016 Jeroen Petrus Broks.
	
	This Source Code Form is subject to the terms of the 
	Mozilla Public License, v. 2.0. If a copy of the MPL was not 
	distributed with this file, You can obtain one at 
	http://mozilla.org/MPL/2.0/.
        Version: 16.09.24
]]
debug = false

print = StdOut.Print
input = StdOut.Input

wout = JLS.Output
jcr6file = JLS.SetJCR6OutputFile

function fileexists(file)
return JLS.FType(file)~=0
end 

function isfile(file)
return JLS.FType(file)==1
end

function isdir(file)
return JLS.FType(file)==2
end

filetype = JLS.FType

function debugchat(msg)
if debug then print(msg) end
end

function Add(file,tofile,data,force)
local allowedtags = {"TARGET","STORAGE","MERGE","MERGESTRIPEXT","MOVE","AUTHOR","NOTES"}
local warntags = {"MOVE"}
;({
   [0] = function() -- file not found
         print("ERROR! file \""..file.."\" does not appear to exist! -- Request to add it will therefore be ignored")
         end,
   [1] = function() -- requested file is a single file
         wout("FILE:"..file)
         wout("TARGET:"..tofile)
         for key,value in spairs(data or {}) do
             if force or tablecontains(allowedtags,upper(key)) then
                wout(key..":"..value)
             else
                print("NOTE! Ignored illegal file key: "..key)
                end
             end
         debugchat('Added file: '..file)    
         end,
   [2] = function() -- requested file is a directory
         local tree = gettree(file)
                  local slash = ""
                   if tofile and tofile~="" then slash="/" end
         for efile in each(tree) do Add(file.."/"..efile,tofile..slash..efile,data,force) end
         end     
})[filetype(file)]()
end add = Add

function GetTree(path)
local ggettree = loadstring(JLS.GetTree(path))
return ggettree()
end gettree = GetTree

function GetDir(path)
local ggetdir = loadstring(JLS.GetListDir(path))
return ggetdir()
end getdir = GetDir

function GlobalStorage(storage)
wout("GLOBALSTORAGE:"..storage)
end globalstorage = GlobalStorage

function FATStorage(storage) -- This has nothing to do with FAT partions. A JCR6 file has it's own file allocation table, and that's what this is. Nothing more. 
wout("FATSTORAGE:"..storage)
end fatstorage = FATStorage

function AddComment(name,comment)
wout("COMMENT:"..name..","..comment)
end addcomment = AddComment

function SetConfig(key,value)
wout("CONFIG:"..key..","..value)
end setconfig=SetConfig

function Sig(signature)
SetConfig("$__Signature",signature)
end sig = Sig

function Alias(ori,tar)
if curaliasori~=upper(ori) then wout("ALIAS:"..ori) end
wout("AS:"..tar)
curaliasoi=upper(ori)
end alias=Alias

function jcr6_system_init()
local gappargs = loadstring(JLS.GetAppArgs())
local gscriptargs = loadstring(JLS.GetScriptArgs())
appargs = gappargs()
scriptargs = gscriptargs()
end


jcr6_system_init()
