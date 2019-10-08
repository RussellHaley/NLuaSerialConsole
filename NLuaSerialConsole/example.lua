WriteConsole("Enter SOme Text")
local text = ReadConsole()

Script("C:\\temp\\scripttest.txt")
WriteConsole(text)

Show("version")

WriteConsole("That's all folks!")

WriteConsole("ABCDE\b\bFGHIJ")


for i = 1,10,1 do
	WriteConsole (tostring(i))
end

Script("close")