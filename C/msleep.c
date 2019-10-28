/* 
 * gcc -shared -fPIC -o msleep.so -I/usr/include/lua5.1 -llua5.1 msleep.c
 * -I and -l may vary on your computer.
 * Your computer may use something besides -fPIC
*/

#include <lua.h>
#include <lauxlib.h>
#include <lualib.h>
#include <windows.h>
#include <stdint.h>
#include "winlua.h"

#ifdef _WIN32
int msleep_c(lua_State *L)
{
	long msecs = lua_tointeger(L, -1);
	Sleep(msecs);
	return 0;
}
#else
static int msleep_c(lua_State *L){
	long msecs = lua_tointeger(L, -1);
	usleep(1000*msecs);
	return 0;                  /* No items returned */
}

/* Can't name this sleep(), it conflicts with sleep() in unistd.h */
static int sleep_c(lua_State *L){
	long secs = lua_tointeger(L, -1);
	sleep(secs);
	return 0;                  /* No items returned */
}

#endif


WINLUA_API int luaopen_msleep(lua_State *L){
	lua_register( L, "msleep", msleep_c);  
	return 0;
}
