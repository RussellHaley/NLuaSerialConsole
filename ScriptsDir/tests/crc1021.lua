local function hash(orig_crc, byte)
	local crc
	local x;

	x = ((orig_crc >> 8) ~ byte) & 0xff;
	x = x ~ (x >> 4);
	crc = (orig_crc << 8) ~ (x << 12) ~ (x << 5) ~ x;

	crc = crc & 0xffff;
	return crc
end

local function ccitt_16(byte_array)

    local crc = 0xffff
    for i in ipairs(byte_array) do    
        crc = hash(crc, byte_array[i])
        print(string.format('%X %X', byte_array[i], crc))
    end

    return crc & 0xffff
end


return {crc16_l = ccitt_16, hash_1021_l = hash}
