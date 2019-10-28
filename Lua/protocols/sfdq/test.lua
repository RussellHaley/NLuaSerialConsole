package.cpath = package.cpath..';..\\..\\..\\bin\\?.dll'
local sf = require('libstarfish')
local daq_factory = require 'starfish-daq'
local s = require 'serpent'
SetBinary(true)
Script("C:\\temp\\sfdq-test2.txt")
local function pt(t)
	for i,v in pairs(t) do 
	print(i,v)
	end
end
local msgs = require 'messages'
local daq1 = daq_factory.new(msgs)

print(s.block(daq1.msgs:list()))
local pl = daq1.msgs:get_msg ('firmware_request'):request()
 --~ .. daq1.msgs:get_msg ('time'):request()
	
local msg = daq1.stamp(pl)


--~ if not IsOpen() then
	--~ OpenPort('com3')
--~ end
print(daq1.to_string(msg))
local dqueued = daq1.extract(msg)

--~ while RUNNING__ do
	--~ SendBinary(msg)
	--~ sf.msleep(50)
--~ end
--~ ClosePort();
Script("close")
--~ local t = daq1.extract(msg)
--~ if not t then print('not t')  return end
--~ local ack = daq1.stamp(daq1.msgs:get_msg('ack'):response(0x1234, 0xabdc))
--~ print (ack)
--~ t = daq1.extract(ack)

print(_VERSION)
