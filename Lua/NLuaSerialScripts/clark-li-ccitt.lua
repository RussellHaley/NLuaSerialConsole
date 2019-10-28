local bit32={}
bit32.extract=function(x,s,n) n=n or 1 return (x>>s)&((1<<n)-1) end
bit32.lshift=function(x,n) return x<<n end
bit32.bxor=function(a,b) return a~b end

-- Author: Clark Li <clark.li86@gmail.com>
-- Ported from http://introcs.cs.princeton.edu/java/51data/CRC16CCITT.java.html
local POLY = 0x1021

function ccitt_16(byte_array)

  local function hash(crc, byte)
    for i = 0, 7 do
      local bit = bit32.extract(byte, 7 - i) -- Take the lsb
      local msb = bit32.extract(crc, 15, 1) -- msb
      crc = bit32.lshift(crc, 1) -- Remove the lsb of crc
      if bit32.bxor(bit, msb) == 1 then crc = bit32.bxor(crc, POLY) end
    end
    return crc
  end

  local crc = 0xffff
  for i in ipairs(byte_array) do
    crc = hash(crc, byte_array[i])
  end

  return bit32.extract(crc, 0, 16)
end


return {ccitt_16 = ccitt_16}
