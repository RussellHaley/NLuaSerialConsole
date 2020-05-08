package.cpath = package.cpath .. ';'..'c:\\Users\\rhaley\\git\\NLuaSerialConsole\\C\\?.dll'
print('hello world')

local sf = require 'libstarfish'

SetBinary(true)

local seq = 0
local function next_seq()
	seq = seq + 1
	return seq
end

local function stamp(typ,pl)
	if not pl or type(pl) ~= 'string' then 
		pl = " "
	end
	--~ local str = string.pack('>L>H>H>H',0x234d5347,typ,next_seq(),pl:len())
	local str = string.pack('<L<H<H<H',0x47534d23,typ,next_seq(),pl:len())
	str = str .. pl
	local crc = sf.crc32_c(str)
	print(string.format('%02x', crc))
	str = str .. string.pack('<L', crc)
	if DEBUG then
		print(str:len(), str)
	end
	return str
end

local str = stamp(0xff, "")

local outstr = ""
for i=1,#str,1 do
	outstr = outstr .. string.format('%02x', str:byte(i))
	
end
print(outstr)
if not IsOpen() then
	OpenPort('com7')
end
SendBinary(str)
--~ print(str)
