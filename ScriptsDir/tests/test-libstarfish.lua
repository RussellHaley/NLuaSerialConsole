package.cpath = package.cpath..';C:/Users/russh/source/repos/NLuaSerialConsole/utils/lib/?.dll'

ls = require 'libStarfish'


local tm = ls.gettime(nil)

for i,v in pairs(tm) do 
	print(i,v)
	ls.msleep(500)
end


