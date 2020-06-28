local utils = 'C:/Users/russh/source/repos/NLuaSerialConsole/Lua/Utils/?.lua'
package.path = package.path..';'..utils
package.cpath = package.cpath..';'... 
local s = require('serpent')
local bytes = {0x5AA5,
0x0700,
0xF8FF,
0x0001,
0x0100,
0x0002,
0x0101,
0x0011,
0xD82B,
0x6DE3,
0x4599,
0x87}


local function sendBytes()
	--~ local bytes = {0x5AA5, 0x5AA5, 0x5AA5, 0x5AA5}
	local cable_info_msg = ""

	--print = WriteConsole
	for i,v in pairs(bytes) do
		--print (v)
		--~ print(string.format("%x",tonumber(v)))
		cable_info_msg = cable_info_msg .. string.pack("<H", v)
		num =  string.unpack("<H",cable_info_msg)
		if not num then print ('nil')
		else
			SendBinary(cable_info_msg)
	--		print(num)
			--~ print(string.format("%x",num))	
		end
	end
	SendBinary(cable_info_msg)
end

local function send_junk()
	local whatsup = [[¯\_(ツ)_/¯]]
	--~ SendBinary(cable_info_msg)
	Send(whatsup)
	Send("10")
	Send("20")
	Send("30")
end

local count = 0
repeat
	count = count + 1
	if count == 300 then print(tostring(RUNNING__)) count = 0 end
	sendBytes()
until not RUNNING__

print("It is: " .. tostring(RUNNING__))
