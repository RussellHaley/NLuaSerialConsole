--~ package.path = package.path..';C:\\Users\\russh\\source\\repos\\luaConsoleMsgs\\?.lua';
package.cpath = package.cpath..';..\\..\\..\\bin\\?.dll'
serpent = require 'serpent'
lstf = require 'libstarfish'
chronos = require 'chronos'
sf = string.format
sp = string.pack
sup = string.unpack
local MAX_PKT_LEN = 4096
local PACK_SZ = 0
local startword = 0xaa55aa55
local sequence = 0

local function next_seq()
	sequence = sequence + 1
	return sequence
end


local function mk_word(part1, part2, part3)
	--~ Use table.pack to get a count and then in each case
	--~ check the types. then we could make error messages more robust
	local result = 0
	if not part2 then
		if type(part1) ~= 'number' then
			error('not a number')
		end
		print(string.format('%02x', part1 & 0xffffffff))
		result = part1 & 0xffffffff
		--~ return string.pack('<I',part1 & 0xffffffff) 
	elseif part3 and type(part1) == 'number' and type(part2) == 'number' 
		and type(part3) == 'number' then
		result = (part1 << 16) + (part2 & 0xff) + (part3 & 0xff)
		--~ string.pack('<I',(part1 << 16) + (part2 & 0xff) + (part3 & 0xff))
		--~ 16 8 8
	elseif type(part1) == 'number' and type(part2) == 'number' then
		--~ return string.pack('<I',(part1 << 16) + (part2 & 0xffff))
		result = (part1 << 16) + (part2 & 0xffff)
	else
		error('An error occured. Could not build 32 bit word from the supplied parts.')
	end
	
	return result
end

local function stamp(pl)
	if not pl or type(pl) ~= 'string' then 
		error('no payload')
	end	
	--~ if #pl ~= MAX_PKT_LEN * PACK_SZ then error('MSG WRONG SIZE') end
	
	
	--~ Get the crc 16 of the payload, pack it in a word with
	--~ the payload size. Pack the result in a string with the header.
	local str = sp('<I<I',startword, mk_word(lstf.crc16_c(pl), #pl/4))
	--~ Append the payload
	str = str .. pl
	
	if DEBUG then
		print(str:len(), str)
	end
	return str
end

local function build_fmt(len)
	str = ""
	for i=1,len,1 do
		str = str .. '<I'
	end
	return str
end

--This is from the Canary implementation. 
local function make_bin_datetime(use_seconds)
	local dt = os.date('*t')
	
	local strip = function (year)
		return math.floor((math.fmod(year*0.01,1))/0.01)
	end
	local dt_str = sp('>B>B>B>B>B',strip(dt.year), dt.month, 
	dt.day, dt.hour, dt.min)
	if use_seconds then
		dt_str = dt_str .. sp('>B', dt.sec)
	end
	return dt_str
end


local function bcd()
	
--~ 0xffffffff
--~ 0xffffffff
end

local function to_string(data)
	local len = #data
	local str = ""
	for i=1,len,1 do
		str = str .. string.format('%02x ',data:byte(i))
	end
	return str
end

local function timestamp()
	local time = lstf.gettime()
	return sf('%d-%02d-%02d %02d:%02d:%02d.%03d', time.year, time.month, time.day, 
		time.hour, time.minutes, time.seconds, time.milliseconds)
end

--This function expects the last 4 bytes to be the crc. 
--Is that a prudent assumption?
local function extract(packet)
	if not packet or type(packet) ~= 'string' then 
		return nil
	end
	--~ Get the crc/length. First 2 bytes are the crc, 
	--~ second two are the length in words.
	local pack_slip = sup('<I', packet:sub(5))
	crc = pack_slip >> 16
	pl_len = pack_slip & 0xffff
	pl = packet:sub(9)
	--~ print('len: %d %d', pl_len, #pl)
	--~ Payload length is in 4 byte words
	if #pl/4 ~= pl_len then error('payload length wrong') end
	local lcrc = lstf.crc16_c(pl)
	--~ if crc ~= lcrc then
		--~ print('CRC didn\'t match')
	--~ else
		--~ print(sf('crc: 0x%x',lcrc))
	--~ end

	local msg = {}
	msg.timestamp = timestamp()
	
	msg.words = table.pack(sup(build_fmt(pl_len/4), pl))
	msg.words[msg.words.n] = nil
	msg.words.n = msg.words.n - 1
	return msg
end

local function new(msgs)
	local t = {}
	t.to_string = to_string
	t.msgs = msgs
	t.msgs.mk_word = mk_word
	t.extract = extract
	t.stamp = stamp	
	
	return t
end

return {new = new, timestamp = timestamp, stopwatch = chronos.nanotime}
