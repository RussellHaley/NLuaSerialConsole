local sf = require 'libstarfish'
local lcrc = require 'crc1021'
local li = require 'clark-li-ccitt'

local data = {0x2, 0x0, 0xf, 0xf, 0xf, 0x0, 0x0, 0x0}
--~ local data = {0x00,0x00,0x0a,0x00, 0x00, 0x00, 0x0d, 0x00}


print('Lua Calling C hash:')
local crc = 0xffff

for i = 1, 8,1 do
	--~ local crc = 0xffff
	crc = sf.hash_1021_c(crc, data[i])
	print(string.format('%X %X', data[i], crc & 0xffff))
end
print(crc & 0xffff)

--~ local pl = string.pack('<I<I',0x000a0000,0x000d0000)
local pl = string.pack('>I>I',0x02000f0f,0x0f000000)
print('C on packed string')
local crc = sf.crc16_c(pl)
print(crc & 0xffff)

print('Lua converted C:')

print(lcrc.crc16_l(data))

print('li:')
local li_crc = li.ccitt_16(data)

print(string.format('%x',li_crc&0xffff))
print(li_crc&0xffff)
