local sl = require('libstarfish')
local sf = string.format

local cmds = {}
local PAUSE = 50
local ONE_SEC = 1000
--Open()
Script('output/test2/v0.2_fixed_test.txt')

local cmds = {
"dipi",
"4 setLoggingMask",
"1800 highTidalVolumeLimit",
"15 pressure", -- limits 250-1000 ml
"30 rate",
"0.4 riseTime", -- limits 5-120 lpm
"2 inspTime", -- limits 5-35 bpm
"modePC"
}

local cmds2 = {
"modeStandby",
"0 setLoggingMask",
"epi"
}

local function slowSend(text)
	for char in text:gmatch(".") do
        SendBinary(char)
        sl.msleep(1)
    end
end


local function main(slow)
	--SetBinary(true)
	slowSend("\n")
	for index ,cmd in pairs(cmds) do
		if slow then
			slowSend(cmd)
			slowSend("\n")
		else
			SendBinary(cmd)
			SendBinary("\n")
		end
		sl.msleep(PAUSE)
	end

	sl.msleep(ONE_SEC * 60)

	slowSend("\r\n")
	for index ,cmd in pairs(cmds2) do
		if slow then			
			slowSend(cmd)
			slowSend("\n")
		else
			SendBinary(cmd)
			SendBinary("\n")

		end
		sl.msleep(PAUSE)
	end

	Script("close") --This is terrible command. Needs to be fixed.
	ClosePort()

end
local SLOW = true
main(SLOW)

--~ SetBinary: bool - Tells the console if the input/output is binaryy. Data received from the target is displayed in hex
--~ WriteConsole: string - Write to this host output
--~ print - synonym for WriteConsole
--~ ReadConsole - Wait for user input
--~ Send: string - Send a text string. 
--~ SendBinary: string - Send a binary string (RH - Is this a necessary command given strings hold binary data in lua?)
--~ Script: string - Logg the input and output streams to a file. (e.g. record everything that goes to the target and everything that comes back).	
--~					There is currently no timestamps
--~ EndScript
--~ OpenPort: string - Open the specified serial port
--~ Open - Open the default serial port. The default port is set in the config file or manually set using SetPort
--~ ClosePort - Close the current open port
--~ Show: string [ports | ?] - display information
--~ IsOpen - returns true if the serial port is open
--~ GetPort - Returns serial port information
--~ SetPort: string - set the serial port
--~ GetSettings: <not implemeneted>
--~ Log - This is the logger object and can be used as so:
--~ 	Log.Info
--~ 	Log.Debug
--~ 	Log.Warn
--~ 	Log.Error
--~ 	Log.Fatal