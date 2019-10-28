--[[
crc32: Copyright (c) 2015, 2016, 2017, 2018 GreaseMonkey
crc16: Copyright (c) 2019 Russell Haley
Permission is hereby granted, free of charge, to any person obtaining a copy of
this software and associated documentation files (the "Software"), to deal in
the Software without restriction, including without limitation the rights to
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
of the Software, and to permit persons to whom the Software is furnished to do
so, subject to the following conditions:
The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
]]

local function hash_1021(orig_crc, byte)
	local crc
	local x

	x = ((orig_crc >> 8) ~ byte) & 0xff
	x = x ~ (x >> 4)
	crc = (orig_crc << 8) ~ (x << 12) ~ (x << 5) ~ x

	return crc & 0xffff
end

local function ccitt_16(byte_array)
    local crc = 0xffff
    
    if type(byte_array) == 'string' then
		for i=1,#byte_array do
			--print(str:byte(i))
			crc = hash_1021(crc, byte_array:byte(i))
		end
	elseif type(byte_array) == 'table' then
		for i in ipairs(byte_array) do
			crc = hash_1021(crc, byte_array[i])
		end
	else
		return false, 'Only strings and tables are supported'
	end
    return crc
end

-- CRC32 implementation
-- standard table lookup version
local crctab = {}

local i
for i=0,256-1 do
	local j
	local v = i
	--[[
	v = ((v<<4)|(v>>4)) & 0xFF
	v = ((v<<2)&0xCC)|((v>>2)&0x33)
	v = ((v<<1)&0xAA)|((v>>1)&0x55)
	]]

	for j=1,8 do
		if (v&1) == 0 then
			v = v>>1
		else
			v = (v>>1) ~ 0xEDB88320
		end
	end
	crctab[i+1] = v
end


local function crc32(byte_array, v)
	v = v or 0
	v = v ~ 0xFFFFFFFF

	local dt = type(byte_array)
	if dt == 'string' then
		local i
		for i=1,#byte_array do
			--print(str:byte(i))
			v = (v >> 8) ~ crctab[((v&0xFF) ~ byte_array:byte(i))+1]
		end
	elseif dt == 'table' then
		for i in ipairs(byte_array) do
			--print(str:byte(i))
			v = (v >> 8) ~ crctab[((v&0xFF) ~ byte_array[i])+1]
		end
	end
	v = v ~ 0xFFFFFFFF
	return v
end


return {
	crc32 = crc32,
	crc16 = ccitt_16
	}
