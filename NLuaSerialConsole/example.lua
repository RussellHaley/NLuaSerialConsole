--local bytes = {0x5AA5,
--0x0700,
--0xF8FF,
--0x0001,
--0x0100,
--0x0002,
--0x0101,
--0x0011,
--0xD82B,
--0x6DE3,
--0x4599,
--0x87}


--local bytes = {0x5AA5,
--0x0700}
--


local bytes = {0x5AA5}
local cable_info_msg = ""

--print = WriteConsole
for i,v in pairs(bytes) do
	print (v)
	print(string.format("%x",tonumber(v)))
	cable_info_msg = cable_info_msg .. string.pack("<h", v)
	num =  string.unpack("<h",cable_info_msg)
	if not num then print ('nil')
	else
		print(cable_info_msg)
		print(num) 
		print(string.format("%x",num))	
	end
end
SendBinary(cable_info_msg)
