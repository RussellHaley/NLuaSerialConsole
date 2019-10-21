#include <lua.h>
#include <lauxlib.h>
#include <lualib.h>
#include <stdint.h>
#include <windows.h>
#include "winlua.h"
#include <stdio.h>

int16_t crc_1021_c(int16_t old_crc, int8_t data)
{
	int16_t crc;
	int16_t x;

	x = ((old_crc>>8) ^ data) & 0xff;
	x ^= x>>4;
	crc = (old_crc << 8) ^ (x << 12) ^ (x << 5) ^ x;

	crc &= 0xffff; //disable this on 16 bit processors
	return crc;
}

int crc_1021(lua_State *L)
{
	int16_t old_crc = lua_tointeger(L, -2);
	int8_t data = lua_tointeger(L, -1);
	int16_t new_crc = crc_1021_c(old_crc, data);
	lua_pushnumber(L, new_crc);
	return 1;
}

int crc16(lua_State *L)
{
	int16_t crc = 0xffff;
	size_t len = 0;
	char *buff = lua_tolstring(L,-1,&len);
	//~ printf("string len: %d\r\n", len);
	for(int i = 0; i < len; i++)
	{
		//~ printf("%d\r\n", buff[i]);
		crc = crc_1021_c(crc, buff[i]);
	}
	lua_pushnumber(L, crc);
	return 1;
}

#ifdef _WIN32
int msleep_c(lua_State *L)
{
	long msecs = lua_tointeger(L, -1);
	Sleep(msecs);
	return 1;
}
#else
int msleep_c(lua_State *L){
	long msecs = lua_tointeger(L, -1);
	usleep(1000*msecs);
	return 1;
}
#endif

static const struct luaL_Reg starfish_functions [] = {
	{"crc1021", crc_1021},
	{"crc16", crc16},
	{"msleep", msleep_c},
	{NULL,NULL}}; //EOL Marker

WINLUA_API int luaopen_libstarfish(lua_State *L)
{
	luaL_newlib(L, starfish_functions);
	return 1;
}
