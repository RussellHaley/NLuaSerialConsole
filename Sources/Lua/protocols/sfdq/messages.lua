local request = 1
local response = 2
local process = 3
local version = 0x00001000


local function mk_word(part1, part2, part3)
	--~ Use table.pack to get a count and then in each case
	--~ check the types. then we could make error messages more robust
	if not part2 then
		if type(part1) ~= 'number' then
			error('not a number')
		end
		print(string.format('%02x', part1 & 0xffffffff))
		return string.pack('<I',part1 & 0xffffffff) 
	elseif part3 and type(part1) == 'number' and type(part2) == 'number' 
		and type(part3) == 'number' then
		string.pack('<I',(part1 << 16) + (part2 & 0xff) + (part3 & 0xff))
		--~ 16 8 8
	elseif type(part1) == 'number' and type(part2) == 'number' then
		return string.pack('<I',(part1 << 16) + (part2 & 0xffff))
	else
		error('An error occured. Could not build 32 bit word from the supplied parts.')
	end
end


msgs = {
	[0x0000 ] = {
		id = 0x0000,
		size = 0x01,
		name = 'slave_id',
		meta = request,
		request = function(self)
			return mk_word(self.id)
		end,
		response = function(self)
			return false, 'not implemented'
		end,
		process = function(self, words)
			return false, 'not implemented'
		end
	},
	[0x0001] = {
		id = 0x0001,
		size = 0x0001,
		name = 'time',
		meta = request,
		request = function(self)
			return mk_word(self.id)
		end,
		response = function(self, words)
			--~ for i,v in pairs(words) do print(i,v) end
			return false, 'not implemented'
		end,
		process = function(self)
			return false, 'not implemented'
		end
	},

	[0x0002] = {
		id = 0x0002,
		size = 0x0001,
		name = 'ack',
		meta = request,
		response = function(self, ack_type, ack_subtype)
			
			return mk_word(self.id)..mk_word(ack_type, ack_subtype)
		end
	},

	[0x0003] = {
		id = 0x0003,
		size = 0x0001,
		name = 'nack',
		meta = request,
		fn = function(self)
			return mk_word(self.id)
		end
	},


	[0x0004] = {
		id = 0x0004,
		size = 0x0003,
		name = 'io_control',
		meta = '',
		request = function()
			return false, 'not implemented'
		end,
		response = function()
			return false, 'not implemented'
		end,
		process = function()
			return false, 'not implemented'
		end
	},
	[0x0006] = {
		id = 0x0006,
		size = 0x000a,
		name = 'io_response',
		meta = response,
		request = function()
			return false, 'not implemented'
		end,
		response = function()
			return false, 'not implemented'
		end,
		process = function()
			return false, 'not implemented'
		end
	},
	[0x0007] = {
		id = 0x0007,
		size = 0x0007,
		name = 'stepper_config',
		meta = request,
		request = function()
			return false, 'not implemented'
		end,
		response = function()
			return false, 'not implemented'
		end,
		process = function()
			return false, 'not implemented'
		end
	},
	[0x0008] = {
		id = 0x0008,
		size = 0x0003,
		name = 'stepper_control',
		meta = request,
		request = function()
			return false, 'not implemented'
		end,
		response = function()
			return false, 'not implemented'
		end,
		process = function()
			return false, 'not implemented'
		end
	},
	[0x0009] = {
		id = 0x0009,
		size = 0x0002,
		name = 'stepper_response',
		meta = response,
		request = function()
			return false, 'not implemented'
		end,
		response = function()
			return false, 'not implemented'
		end,
		process = function()
			return false, 'not implemented'
		end
	},
	[0x000a] = {
		id = 0x000a,
		size = 0x0000,
		name = 'firmware_request',
		meta = request,
		request = function(self)
			--~ print(string.format('%02x', self.id))
			local word = mk_word(self.id, size)
			print(string.format('%02x', word:byte(1,4)))
			return word
		end
	},
	[0x000b] = {
		id = 0x000b,
		size = 0x0001,
		name = 'firmware_response',
		meta = response,
		response = function()
			return mkword(version)
		end,
		process = function()
			return false, 'not implemented'
		end
	},	

	[0x000c] = {
		id = 0x000c,
		size = 0x0006,
		name = 'error_response',
		meta = response,
		request = function()
			return false, 'not implemented'
		end,
		response = function()
			return false, 'not implemented'
		end,
		process = function()
			return false, 'not implemented'
		end
	},
	--~ Is this for acking an alarm?
	[0x000d] = {
		id = 0x000d,
		size = 0x0001,
		name = 'error_ack',
		meta = response,
		request = function()
			return false, 'not implemented'
		end,
		response = function()
			return false, 'not implemented'
		end,
		process = function()
			return false, 'not implemented'
		end
	},
	[0x000e] = {
		id = 0x000e,
		size = 0x0005,
		name = 'thermal_control',
		meta = resquest,
		request = function()
			return false, 'not implemented'
		end,
		response = function()
			return false, 'not implemented'
		end,
		process = function()
			return false, 'not implemented'
		end
	},
	[0x000f] = {
		id = 0x000f,
		size = false,
		name = 'thermal_response',
		meta = response,
		request = function()
			return false, 'not implemented'
		end,
		response = function()
			return false, 'not implemented'
		end,
		process = function()
			return false, 'not implemented'
		end
	},
	[0x0010] ={
		id = 0x0010,
		size = 0x0000,
		name = 'thermal_request',
		meta = request,
		request = function()
			return false, 'not implemented'
		end,
		response = function()
			return false, 'not implemented'
		end,
		process = function()
			return false, 'not implemented'
		end
	},
	[0x0011]  ={
		id = 0x0011,
		size = 0x0003,
		name = 'pwm_control',
		meta = request,
		request = function()
			return false, 'not implemented'
		end,
		response = function()
			return false, 'not implemented'
		end,
		process = function()
			return false, 'not implemented'
		end
	},
	[0x0012]  ={
		id = 0x0012,
		size = 0x0003,
		name = 'pwm_response',
		meta = response ,
		request = function()
			return false, 'not implemented'
		end,
		response = function()
			return false, 'not implemented'
		end,
		process = function()
			return false, 'not implemented'
		end
	},
	[0x0016]  ={
		id = 0x0016,
		size = false,
		name = 'hadc_control',
		meta = request,
		request = function()
			return false, 'not implemented'
		end,
		response = function()
			return false, 'not implemented'
		end,
		process = function()
			return false, 'not implemented'
		end
	},  
	[0x0017]  ={
		id = 0x0017,
		size = 0x0000,
		name = 'hadc_request',
		meta = request,
		request = function()
			return false, 'not implemented'
		end,
		response = function()
			return false, 'not implemented'
		end,
		process = function()
			return false, 'not implemented'
		end
	},
	[0x0018]  ={
		id = 0x0018,
		name = 'hadc_response',
		size = false,
		meta = '',
		request = function()
			return false, 'not implemented'
		end,
		response = function()
			return false, 'not implemented'
		end,
		process = function()
			return false, 'not implemented'
		end
	},
	[0x0019]  ={
		id = 0x0019,
		size = 0x0003,
		name = 'imu_response',
		meta = response,
		request = function()
			return false, 'not implemented'
		end,
		response = function()
			return false, 'not implemented'
		end,
		process = function()
			return false, 'not implemented'
		end
	},
	[0x001a]  ={
		id = 0x001a,
		size = false,
		name = 'temperature_config',
		meta = request,
		request = function()
			return false, 'not implemented'
		end,
		response = function()
			return false, 'not implemented'
		end,
		process = function()
			return false, 'not implemented'
		end
	},
	[0x001b]  ={
		id = 0x001b,
		size = false,
		name = 'temperature_response',
		meta = response,
		request = function()
			return false, 'not implemented'
		end,
		response = function()
			return false, 'not implemented'
		end,
		process = function()
			return false, 'not implemented'
		end
	},
	[0x001c]  ={
		id = 0x001c,
		name = 'encoder_config',
		size = false,
		meta = request,
		request = function()
			return false, 'not implemented'
		end,
		response = function()
			return false, 'not implemented'
		end,
		process = function()
			return false, 'not implemented'
		end
	},
	[0x001d]  ={
		id = 0x001d,
		size = false,
		name = 'encoder_response',
		meta = response,
		request = function()
			return false, 'not implemented'
		end,
		response = function()
			return false, 'not implemented'
		end,
		process = function()
			return false, 'not implemented'
		end
	},
	[0x001e]  ={
		id = 0x001e,
		size = false,
		name = 'closed_loop_feedback_config',
		meta = request,
		request = function()
			return false, 'not implemented'
		end,
		response = function()
			return false, 'not implemented'
		end,
		process = function()
			return false, 'not implemented'
		end
	},
	[0x001f]  ={
		id = 0x001f,
		size = false,
		name = 'brushless_config',
		meta = request,
		request = function()
			return false, 'not implemented'
		end,
		response = function()
			return false, 'not implemented'
		end,
		process = function()
			return false, 'not implemented'
		end
	},
	[0x0020]  ={
		id = 0x0020,
		size = false,
		name = 'tragectory_response',
		meta = response,
		request = function()
			return false, 'not implemented'
		end,
		response = function()
			return false, 'not implemented'
		end,
		process = function()
			return false, 'not implemented'
		end
	},
	[0x0021]  ={
		id = 0x0021,
		size = false,
		name = 'trajectory_request',
		meta = request,
		request = function()
			return false, 'not implemented'
		end,
		response = function()
			return false, 'not implemented'
		end,
		process = function()
			return false, 'not implemented'
		end
	},

	list = function(self)
		t = {}
		for i,v in pairs(self) do
			if type(v) ~= 'function' then
				t[i] = v.name
			else
				t[i] = 'Function'
				
			end
		end
		return t
	end,

	get_msg = function(self, name)
		for i,v in pairs(self) do
			if type(v) ~= 'function' then
				--~ print(v.name)
				if v.name == name then
					return v
				end
			end
		end
	end
};

return msgs
