local sf = require 'starfish-crc'

local c = 'this is a test'
local d = string.pack('<I<I',0x0f, 0x9)
local crc16 = sf.crc16({0x00,0xf,0x2})
local crc32 = sf.crc32(c)

print (crc16, crc32)
