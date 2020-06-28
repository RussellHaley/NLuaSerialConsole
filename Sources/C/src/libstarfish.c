#include <lua.h>
#include <lauxlib.h>
#include <lualib.h>
#include <stdint.h>
#include <stdbool.h>
#include <windows.h>
#include "winlua.h"
#include <stdio.h>
#include "crc32.h"

char* month[12] = 
	{
		"January",
		"February",
		"March",
		"April",
		"May",
		"June",
		"July",
		"August",
		"September",
		"October",
		"November",
		"December"
	};

char* dayofweek[7] = 
	{
		"Sunday",
		"Monday",
		"Tuesday",
		"Wednesday",
		"Thursday",
		"Friday",
		"Saturday"
	};

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

int sf_crc16(lua_State *L)
{
	int16_t crc = 0xffff;
	size_t len = 0;
	const char *buff = lua_tolstring(L,-1,&len);
	//~ printf("string len: %d\r\n", len);
	for(int i = 0; i < len; i++)
	{
		//~ printf("%d\r\n", buff[i]);
		crc = crc_1021_c(crc, buff[i]);
	}
	lua_pushnumber(L, crc & 0xffff);
	return 1;
}

int crc32(lua_State *L)
{
	crc_t crc = 0xffffffff;
	size_t len = 0;
	const char *buff = lua_tolstring(L,-1,&len);
	//~ printf("string len: %d\r\n", len);
	for(int i = 0; i < len; i++)
	{
		//~ printf("%d\r\n", buff[i]);
		crc = crc32_c(buff, len);
	}
	lua_pushnumber(L, crc);
	return 1;
}

#ifdef _WIN32
int msleep(lua_State *L)
{
	long msecs = lua_tointeger(L, -1);
	Sleep(msecs);
	return 1;
}
#else
int msleep(lua_State *L){
	long msecs = lua_tointeger(L, -1);
	usleep(1000*msecs);
	return 1;
}
#endif

int gettime(lua_State *L)
{
	SYSTEMTIME time;

	bool utc = lua_toboolean(L, -1);
	
	if(utc)
	{
		printf("UTC? %d", utc);
		GetSystemTime(&time);
	}
	else
	{
		GetLocalTime(&time);
	}
	
	lua_createtable(L, 0, 10);
	lua_pushinteger(L, time.wYear);
	lua_setfield(L, -2, "year");
	lua_pushinteger(L, time.wMonth);
	lua_setfield(L, -2, "month");
	lua_pushinteger(L, time.wDayOfWeek);
	lua_setfield(L, -2, "dayofweek");
	lua_pushstring(L, month[time.wMonth - 1]);
	lua_setfield(L, -2, "monthname");
	lua_pushstring(L, dayofweek[time.wDayOfWeek]);
	lua_setfield(L, -2, "dayofweekname");
	lua_pushinteger(L, time.wDay);
	lua_setfield(L, -2, "day");
	lua_pushinteger(L, time.wHour);
	lua_setfield(L, -2, "hour");
	lua_pushinteger(L, time.wMinute);
	lua_setfield(L, -2, "minutes");
	lua_pushinteger(L, time.wSecond);
	lua_setfield(L, -2, "seconds");
	lua_pushinteger(L, time.wMilliseconds);
	lua_setfield(L, -2, "milliseconds");
	return 1;
}

static const struct luaL_Reg starfish_functions [] = {
	{"sf_crc16", sf_crc16},
	{"crc32", crc32},
	{"msleep", msleep},
	{"gettime", gettime},
	{NULL,NULL} //EOL Marker
}; 

//~ __declspec(dllexport) int luaopen_libStarfish(lua_State *L)
WINLUA_API int luaopen_libstarfish(lua_State *L)
{
	luaL_newlib(L, starfish_functions);
	return 1;
}
