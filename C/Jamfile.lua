local project_name = 'libstarfish'
BINARY_OR_TEXT_COMMAND_LINE = 'text'
path = '.'
--~ ospath = require 'ospath'
--~ filefind = require 'filefind'
local BIN = '../bin/'
local so_ext = '.dll'
local static_ext = '.lib'

--~ Unzip something. Josh has build in tarball features?
local function call7Zip()
	
end



--~ Create and return a table with Lua version and naming information. 
local function makeVersion(version)
    if not version then 
        return nil,'Need a version number' 
    end
    
    --~ so = lua51, lua52 etc. so_target = lua51-shared...
    local so = string.format('lua%s', version:gsub('%.',''))
    if so:len() > 5 then
		so = so:sub(1,5)
	end
	local so_full = string.format('lua%s%s', version:gsub('%.',''), so_ext)
    local path = string.format('lua-%s/src',version)
    local lua_build = {
        version = version,
        --~ sourcepath = path,
        source_path = jam_expand('@(' .. path .. ':T)')[1],
        so_target = so..'-shared',
        static_target = so..'-static',
        shared_object = so,
        static_object = so,
        shared_object_full = so_full,
        outpath = BIN
    }
    return lua_build
end

local function buildChronos(build)

	local target_name = 'chronos-module'
	
	--~ local lfs_path = jam_expand('@(' .. path .. ':T)')[1]
	jam['C.ActiveTarget'](target_name)
	jam['C.Defines'](nil, '_WIN32')
	jam['C.OutputPath'](nil, bin)
	jam['C.OutputName'](nil, 'chronos')
	--need to get lua include path
	jam['C.IncludeDirectories'] (nil, 'c:\\program files (x86)\\WinLua\\Lua\\5.3\\include')
	--~ jam['C.LinkLibraries']( nil, build.so_target)
	jam['C.Library'](nil, {'chronos.c@=**.h'}, 'shared')
	jam['Depends']('all', target_name)
end

local function buildLua(version_table, winlua)
	local shared_outpath
	local static_outpath
	jam.CopyFile('C:/temp/itworked.txt','C:/temp/conf.lcf')
	for i,v in pairs(version_table) do
		local build = makeVersion(v)
		if winlua then
			build.source_path = 'winlua-src/' .. build.source_path
			shared_outpath = build.outpath ..build.version:sub(1,3)
			static_outpath = build.outpath ..build.version:sub(1,3)
		else
			shared_outpath = build.outpath .. '/bin'
			static_outpath = build.outpath .. '/static'
		end
		--Target for intermediary files
		jam['C.ActiveTarget'](build.so_target)
		jam['C.OutputPath']( nil, shared_outpath)
		jam['C.OutputName']( nil, build.shared_object)
		jam['C.Defines']( nil, 'LUA_BUILD_AS_DLL')
		jam['C.IncludeDirectories']( nil, build.source_path)
		if winlua then
			jam['C.Library']( nil, {build.source_path..'/*@=**.c@=**.h'}, 'shared')
		else
			 jam['C.Library']( nil, {build.source_path..'/*@=**.c@=**.h@-**/lua.c@-**/luac.c'}, 'shared')
		end
		
		--~ --Static Library: Target for intermediary files
		jam['C.ActiveTarget']( build.static_target)
		jam['C.OutputPath']( nil, static_outpath)
		jam['C.OutputName']( nil, build.static_object)
		jam['C.IncludeDirectories']( nil, build.source_path)
		--lua.c is patched and needs to be included with the other files
		jam['C.Library']( nil, {build.source_path..'/*@=**.c@=**.h@-**/lua.c@-**/luac.c'}, 'static')
		jam['Depends']('all', build.static_target)
		
		--Target for Shared Object
		jam['C.ActiveTarget']( build.shared_object)
		jam['C.OutputPath'](nil,  shared_outpath)
		--Why no target for the executable?
			jam['Depends']('all', build.so_target)
		build.outpath = shared_outpath
		buildLFS(build)
	end
end

local function buildDTLua()
	local hpp = "winlua-src\\src\\getopt-lua.hpp"
	local getopt = "getopt.lua"
	--~ NOTE: This runs regardless of the target because it's outside
	--~ the jam execution
	genHppFile('get_opts', hpp, getopt)

	--~ hard coded for now. pretend this was returned from buildLua
	link_libs = {'lua53-shared'}
	buildLua({'5.1.5','5.2.4','5.3.5','5.4'}, true)
	jam['C.ActiveTarget']( project_name)
	jam['C.OutputPath'](nil, BIN)
	jam['C.OutputName'](nil, project_name)
	jam['C.IncludeDirectories'](nil, {'lua-5.3.5/src','src/'})
	jam['C.LinkLibraries'](nil, link_libs)
	jam['C.Application'](nil, 'src/dtlua.cpp')
	jam['Depends']('all', project_name)
end

local function buildStandardLua()
	BIN = '../Deploy/x86/Lua'
	link_libs = {'lua53-shared'}
	buildLua({'5.3.5'})
	jam['C.ActiveTarget']( 'lua')
	jam['C.OutputPath'](nil, BIN .. '/bin')
	jam['C.OutputName'](nil, 'lua')
	jam['C.IncludeDirectories'](nil, {'lua-5.3.5/src'})
	jam['C.LinkLibraries'](nil, link_libs)
	jam['C.PrecompiledHeader'](nil, {'stdafx' , 'resources/resource.rc','resources/stdafx.h'})
	jam['C.MFC'](nil, {'link', 'shared'})
	jam['C.Rc'](nil, 'resources/resource.rc')
	--~ jam['C.Application'](nil, {'lua-5.3.5/src/luac.c', 'C.Rc', 'resources/resource.rc'})
	jam['C.Application'](nil, {'resources/stdafx.cpp','lua-5.3.5/src/lua.c'})

	
	jam['C.ActiveTarget']( 'luac')
	jam['C.OutputPath'](nil, BIN .. '/bin')
	jam['C.OutputName'](nil, 'luac')
	jam['C.IncludeDirectories'](nil, {'lua-5.3.5/src'})
	jam['C.LinkLibraries'](nil, 'lua53-static' , 'static')
	--~ jam['C.Define'](nil, '_AFX_NO_OLE_SUPPORT')
	jam['C.PrecompiledHeader'](nil, 'stdafx', 'resources/stdafx.h')
	jam['C.MFC'](nil, {'link', 'shared'})
	jam['C.Rc'](nil, 'resources/resource.rc')
	--~ jam['C.Application'](nil, {'lua-5.3.5/src/luac.c', 'C.Rc', 'resources/resource.rc'})
	jam['C.Application'](nil, {'resources/stdafx.cpp','lua-5.3.5/src/luac.c'})
end
--~ buildDTLua()
buildChronos()
