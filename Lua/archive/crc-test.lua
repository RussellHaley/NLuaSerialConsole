local sf = require 'libstarfish'

crc = 0xffff

local fw_request = 0x000a0000
local time_request = 0x000d0000

local bytes = {
	start = 0xaa55aa55,
	crc = 0x0,
	msglen = 0x0,
	payload = {fw_request,time_request}
}

local count = 0
local pl = ""
for i,v in pairs(bytes.payload) do
	pl = pl .. string.pack('<I', v)
	count = count + 1
end

print('lua:')
local crc = 0xffff
local data = {0x00,0x00,0x0a,0x00, 0x00, 0x00, 0x0d, 0x00}
for i = 1, 8,1 do
	print(data[i])
	crc = sf.crc1021(crc, data[i])	
end
print(crc)

print('C:')
bytes.crc = sf.crc16(pl)
print(bytes.crc, count)

bytes.msglen = count
local header = bytes.crc & bytes.msglen >> 8
local msg = string.pack('<I<I',bytes.start, header)
msg = msg .. pl

--~ print (msg)

