package.path = package.path..';C:\\Users\\russh\\source\\repos\\luaConsoleMsgs\\?.lua';
lib_crc = require 'crc32'
serpent = require 'serpent'

local sequence = 0

local function next_seq()
	sequence = sequence + 1
	return sequence
end

local function stamp(typ,pl)
	if not pl or type(pl) ~= 'string' then 
		pl = " "
	end
	local str = string.pack('>L>H>H>H',0x234d5347,typ,next_seq(),pl:len())
	str = str .. pl
	str = str .. string.pack('>L',lib_crc.crc32(str))
	if DEBUG then
		print(str:len(), str)
	end
	return str
end

--This function expects the last 4 bytes to be the crc. 
--Is that a prudent assumption?
function extract(msg)
	if not msg or type(msg) ~= 'string' then 
		return nil
	end
	local crc = string.unpack('>L', msg:sub(-4))
	local lcrc = lib_crc.crc32(msg:sub(1,-5))
	if crc ~= lcrc then
		print('DIDNT WORK!')
	else
		print('crc: ' ..lcrc)
	end
	local _, typ, seq, pl_len = string.unpack('>L>H>H>H',msg)
	print('my t '..typ)
	local t = {}
	t.type = typ
	t.sequence = seq
	t.payload_length = pl_len --Do we even need this? payload is a string
	t.payload = msg:sub(11,-5)
	local pl = msg:sub(11,-5)
	--!THIS DOESN"T TO ANYTHING YET!"
	return t
end

local function make_bin_datetime(use_seconds)
	local dt = os.date('*t')
	
	local strip = function (year)
		return math.floor((math.fmod(year*0.01,1))/0.01)
	end
	local dt_str = string.pack('>B>B>B>B>B',strip(dt.year), dt.month, 
	dt.day, dt.hour, dt.min)
	if use_seconds then
		dt_str = dt_str .. string.pack('>B', dt.sec)
	end
	return dt_str
end

STATUS = {
	[1] = OK,
	[2] = UNINITIALIZED,
	[3] = BUSY,
	[4] = TIMEOUT,
	[5] = BAD_PARAMETER
}

CONN = {
	open,
	close,
	status,
	endpoint_info,
	local_info
}


local function is_inet_uri(addr)
	return true
end
--[[
	Lookup the endpoint by it's sender id, likely a bus number.
	Do we wait for the spi response?
--]]
local function send_spi(endpoint, msg)

end

local function send_serial(msg)

end

local function send_inet(msg)

end

--~ local function send_to(endpoint, msg)
	--~ if endpoint.type and type(endpoint.type) == 'string' then
		--~ if endpoint.type == 'serial' then
			--~ --how do we check for a valid address?
			--~ send_serial(endpoint, msg)
		--~ else if endpoint.type == 'spi' then
			--~ --check if a valid spi address
			--~ send_spi(endpoint, msg)
		--~ else if endpoint.type == 'inet' then
			--~ if endpoint.address and is_inet_uri(endpoint.address) then
				--~ send_inet(endpoint.address, (endpoint.port or 443), msg)
			--~ end
		--~ end
	--~ end
--~ end


types = {
	['get_status'] = 100,
	['get_version'] = 101,
	['get_datetime'] = 102,
	['set_datetime'] = 103,
	['get_metadata'] = 104,
	['set_metadata'] = 105,
	['get_config'] = 106,
	['set_config'] = 107,
	['get_mode'] = 108,
	['set_mode'] = 109,
	['get_data_size'] = 110,
	['get_count_records'] = 111,
	['get_record_header'] = 112,
	['get_record'] = 113,
	['delete_record'] = 114,
	['erase'] = 115,
	['get_status_rsp'] = 300,
	['get_version_rsp'] = 301,
	['get_datetime_rsp'] = 302,
	['set_datetime_rsp'] = 303,
	['get_metadata_rsp'] = 304,
	['set_metadata_rsp'] = 305,
	['get_config_rsp'] = 306,
	['set_config_rsp'] = 307,
	['get_mode_rsp'] = 308,
	['set_mode_rsp'] = 309,
	['get_data_size_rsp'] = 310,
	['get_count_records_rsp'] = 311,
	['get_record_header_rsp'] = 312,
	['get_record_rsp'] = 313,
	['delete_record_rsp'] = 314,
	['erase_rsp'] = 315,
	['process_get_status_rsp'] = 500,
	['process_get_version_rsp'] = 501,
	['process_get_datetime_rsp'] = 502,
	['process_set_datetime_rsp'] = 503,
	['process_get_metadata_rsp'] = 504,
	['process_set_metadata_rsp'] = 505,
	['process_get_config_rsp'] = 506,
	['process_set_config_rsp'] = 507,
	['process_get_mode_rsp'] = 508,
	['process_set_mode_rsp'] = 509,
	['process_get_data_size_rsp'] = 510,
	['process_get_count_records_rsp'] = 511,
	['process_get_record_header_rsp'] = 512,
	['process_get_record_rsp'] = 513,
	['process_delete_record_rsp'] = 514,
	['process_erase_rsp'] = 315,
}
	
--[[
Implementation on the gateway
--]]
local function get_status(endpoint)
	return stamp(types.get_status)
end

local function get_version(endpoint)
	return stamp(types.get_version)
end

local function get_datetime(endpoint)
	return stamp(types.get_datetime)
end

local function set_datetime(endpoint)
	local dt = make_bin_datetime(true)
	return stamp(types.set_datetime,dt)
end

local function get_metadata(endpoint)
	return stamp(types.get_metadata)
end

local function set_metadata(endpoint, meta)
	return stamp(types.set_metadata, meta)
end

local function get_config(endpoint)
	return stamp(types.get_config)
end

local function set_config(endpoint, config)
	return stamp(types.set_config, config)
end

local function get_mode(endpoint)
	return stamp(types.get_mode)
end

local function set_mode(endpoint, mode)
	return stamp(types.set_mode)
end

local function get_data_size(endpoint)
	return stamp(types.get_data_size)
end

local function get_count_records(endpoint)
	return stamp(types.get_count_records)
end

local function get_record_header(endpoint, data_type, record_no)
	local pl = string.pack('>B>H', data_type, record_no)
	return stamp(types.get_record_header, pl)
end

local function get_record(endpoint, data_type, record_no)
	local pl = string.pack('>B>H', data_type, record_no)
	return stamp(types.get_record, pl)
end

local function delete_record(endpoint, data_type, record_no)
	local pl = string.pack('>B>H', data_type, record_no)
	return stamp(types.delete_record, pl)
end

local function erase(endpoint, data_type)
	local pl = string.pack('>B', data_type)
	return stamp(types.erase, pl)
end

local function process_get_status_rsp(endpoint, response)
	print(response.type,response.seq, response.payload:len())
	print('save the response and the time'.. serpent.block(response))
end

local function process_get_version_rsp(endpoint, response)
	print('save the version'.. serpent.block(response))
end

local function process_get_datetime_rsp(endpoint, response)
	print('log the timestamp'.. serpent.block(response))
end

local function process_set_datetime_rsp(endpoint, response)
	print('log the response', string.unpack('>B',response.payload))
end

local function process_get_metadata_rsp(endpoint, response)
	print('process the metadata: '.. serpent.block(response))
end

local function process_set_metadata_rsp(endpoint, response)
	print('log the response to the metadata change: '.. serpent.block(response))--.payload)
end

local function process_get_config_rsp(endpoint, response)
	print('The implant config is'..response.payload)
end

local function process_set_config_rsp(endpoint, response)
	print('log the result of: ' .. string.unpack('>B',response.payload))
end

local function process_get_mode_rsp(endpoint, response)
	print('log the mode response: ' .. string.unpack('>B', response.payload))
end

local function process_set_mode_rsp(endpoint, response)
	print('Response to set mode: '..string.unpack('>B',response.payload))
end

local function process_get_data_size_rsp(endpoint, response)
	print('store the size of data')
end

local function process_get_count_records_rsp(endpoint, response)
	print('note how many records')
end

local function process_get_record_header_rsp(endpoint, response)
	print('check the record header')
end

local function process_get_record_rsp(endpoint, response)
	print('save the record')
end

local function process_delete_record_rsp(endpoint, response)
	print('did we delete the record?')
end

local function process_erase_rsp(endpoint, response)
	print('Did we erase the data?')
end


--[[
Process the responses on the gateway
--]]

local status = 1
local function get_status_rsp(endpoint, request)
	local pl = string.pack('>B', status)
	return stamp(types.get_status_rsp, pl)
end


local major,minor,patch = 0,1,0
--!NOTE: This rebuilds the build date very time!
local build_date = make_bin_datetime(false)

local function get_version_rsp(endpoint, request)
	--[[
	major
	minor
	patch
	build ->binary date %y%m%d%H%M
	]]
	
	local ver =	 string.pack('>B>B>B',major, minor, patch)
	ver = ver..make_bin_datetime(false)
	return stamp(types.get_version_rsp, ver)
end

local function get_datetime_rsp(endpoint, request)
	
	return stamp(types.get_datetime_rsp,dt)
end

local function set_datetime_rsp(endpoint, request)
	local t = {}
	print(request.payload)
	t.year,t.month,t.day,t.hour,t.minute = string.unpack('>B>B>B>B>B>B', request.payload)
	local s = require 'serpent'
	s.block(t)
	return stamp(types.set_datetime_rsp,string.pack('>B',1))
end	

local function get_metadata_rsp(endpoint, response)
	return stamp(types.get_metadata_rsp, 'This is meta!')
end

local function set_metadata_rsp(endpoint, response)
	print(response.payload)
	return stamp(types.set_metadata_rsp, 1)
end

local function get_config_rsp(endpoint, response)
	local config = "This is the implant config"
	return stamp(types.get_config_rsp, config)
end

local function set_config_rsp(endpoint, response)
	print('!!Set the config here...')
	return stamp(types.set_config_rsp, string.pack('>B', 1))
end

local mode = 3
local function get_mode_rsp(endpoint, response)
	print('!! Get the mode here')
	return stamp(types.get_mode_rsp, string.pack('>B', 1))
end

local function set_mode_rsp(endpoint, response)
	print('!!Set the mode to '..string.unpack('>B', response.payload))
	return stamp(types.set_mode_rsp, string.pack('>B', 1))
end

local function get_data_size_rsp(endpoint, response)

end

local function get_count_records_rsp(endpoint, response)

end

local function get_record_header_rsp(endpoint, response)

end

local function get_record_rsp(endpoint, response)

end

local function delete_record_rsp(endpoint, response)

end

local function erase_rsp(endpoint, response)

end

------------------------------------------------------------------------
--[[ 
Message processing and response on the collection device
--]]

--Yikes! need to separate these or something...
local chirpy = {
	types = types,

	requests = {
	[100] = get_status,
	[101] = get_version,
	[102] = get_datetime,
	[103] = set_datetime,
	[104] = get_metadata,
	[105] = set_metadata,
	[106] = get_config,
	[107] = set_config,
	[108] = get_mode,
	[109] = set_mode,
	[110] = get_data_size,
	[111] = get_count_records,
	[112] = get_record_header,
	[113] = get_record,
	[114] = delete_record,
	[115] = erase
	},

	responses = {
	[100] = get_status_rsp,
	[101] = get_version_rsp,
	[102] = get_datetime_rsp,
	[103] = set_datetime_rsp,
	[104] = get_metadata_rsp,
	[105] = set_metadata_rsp,
	[106] = get_config_rsp,
	[107] = set_config_rsp,
	[108] = get_mode_rsp,
	[109] = set_mode_rsp,
	[110] = get_data_size_rsp,
	[111] = get_count_records_rsp,
	[112] = get_record_header_rsp,
	[113] = get_record_rsp,
	[114] = delete_record_rsp,
	[115] = erase_rsp
	},

	processing = {
	[300] = process_get_status_rsp,
	[301] = process_get_version_rsp,
	[302] = process_get_datetime_rsp,
	[303] = process_set_datetime_rsp,
	[304] = process_get_metadata_rsp,
	[305] = process_set_metadata_rsp,
	[306] = process_get_config_rsp,
	[307] = process_set_config_rsp,
	[308] = process_get_mode_rsp,
	[309] = process_set_mode_rsp,
	[310] = process_get_data_size_rsp,
	[311] = process_get_count_records_rsp,
	[312] = process_get_record_header_rsp,
	[313] = process_get_record_rsp,
	[314] = process_delete_record_rsp,
	[315] = process_erase_rsp
	},
	
	extract = extract
}


local inet_status_interval = 10000
local spi_interval = 10
local serial_interval = 10

--~ print(chirpy.responses[chirpy.types.get_version_rsp]())

return chirpy
