local sl = require('libstarfish')
local sf = string.format

local cmds = {}

Open()
Script('test.txt')

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

for index ,value in pairs(cmds) do
    for char in value:gmatch(".") do
        SendBinary(char)
        sl.msleep(1)
    end
    SendBinary("\r")
    sl.msleep(1)
    
    SendBinary("\n")
    sl.msleep(1)
    
    sl.msleep(1000)
end

sl.msleep(60000)

for index ,value in pairs(cmds2) do
    for char in value:gmatch(".") do
        SendBinary(char)
        sl.msleep(1)
    end
    SendBinary("\r")
    sl.msleep(1)
    
    SendBinary("\n")
    sl.msleep(1)
    
    sl.msleep(1000)
end

Script("close") --This is terrible command. Needs to be fixed.
ClosePort()


--~ SetBinary: bool - Tells the console if the input/output is binaryy. Data received from the target is displayed in hex
--~ WriteConsole: string - Write to this host output
--~ print - synonym for WriteConsole
--~ ReadConsole - Wait for user input
--~ SendBinary: string - Send a binary string
--~ Script: string - run the script at indicated by the string (path) provided
--~ OpenPort: string - Open the specified serial port
--~ Open - Open the currently set serial port 
--~ ClosePort - Close the current open port
--~ Show: string [ports | ?] - display information
--~ IsOpen - returns true if the serial port is open
--~ GetPort - Returns serial port information
--~ SetPort: string - set the serial port
--~ GetSettings: ?
--~ Log - This is the logger object and can be used as so:
--~ 	Log.Info
--~ 	Log.Debug
--~ 	Log.Warn
--~ 	Log.Error
--~ 	Log.Fatal
