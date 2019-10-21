
local fw_request = {
	buff = 0x000a0000
}
local bytes = {
	start = 0xaa55aa55,
	crc_msglen = 0x00000001,
	payload = fw_request
}


local cable_info_msg = ""


cable_info_msg = string.pack('<J<J<J', bytes.start, bytes.crc_msglen, bytes.payload.buff)

SendBinary(cable_info_msg)

--print = WriteConsole
--for i,v in pairs(bytes) do
--	cable_info_msg = cable_info_msg .. string.pack("<h", v)
--	num =  string.unpack("<h",cable_info_msg)
--	if not num then print ('nil')
--	else
--		print(cable_info_msg)
--		print(num) 
--		print(string.format("%x",num))	
--	end
--end

-- Author: Clark Li <clark.li86@gmail.com>
-- Ported from http://introcs.cs.princeton.edu/java/51data/CRC16CCITT.java.html
local POLY = 0x1021

function ccitt_16(byte_array)

  local function hash(crc, byte)
    for i = 0, 7 do
      local bit = bit32.extract(byte, 7 - i) -- Take the lsb
      local msb = bit32.extract(crc, 15, 1) -- msb
      crc = crc << 1 -- Remove the lsb of crc
      if bit ~ msb == 1 then 
		crc = crc ~ POLY 
	  end
    end
    return crc
  end

  local crc = 0xffff
  for i in ipairs(byte_array) do
    crc = hash(crc, byte_array[i])
  end

--  return bit32.extract(crc, 0, 16)
  return crc & 0xFFFF
end

l = {0x01,0x02,0x03}
print(ccitt_16(l))
---- Author: Clark Li <clark.li86@gmail.com>
---- Ported from http://introcs.cs.princeton.edu/java/51data/CRC16CCITT.java.html
--local POLY = 0x1021
--
--function ccitt_16(byte_array)
--
--  local function hash(crc, byte)
--    for i = 0, 7 do
--      local bit = bit32.extract(byte, 7 - i) -- Take the lsb
--      local msb = bit32.extract(crc, 15, 1) -- msb
--      crc = bit32.lshift(crc, 1) -- Remove the lsb of crc
--      if bit32.bxor(bit, msb) == 1 then crc = bit32.bxor(crc, POLY) end
--    end
--    return crc
--  end
--
--  local crc = 0xffff
--  for i in ipairs(byte_array) do
--    crc = hash(crc, byte_array[i])
--  end
--
--  return bit32.extract(crc, 0, 16)
--end