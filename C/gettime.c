#include <windows.h>

LONG getTime_c()
{
	SYSTEMTIME time;
	GetSystemTime(&time);
	LONG time_ms = (time.wSecond * 1000) + time.wMilliseconds;
}


static const struct luaL_Reg starfish_functions [] = {
	{"hash_1021_c", hash},
	{"crc16_c", crc16},
	{"msleep", msleep_c},
	{NULL,NULL}}; //EOL Marker

WINLUA_API int luaopen_libstarfish(lua_State *L)
{
	luaL_newlib(L, starfish_functions);
	return 1;
}
