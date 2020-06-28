/* 
 * gcc -shared -fPIC -o msleep.so -I/usr/include/lua5.1 -llua5.1 msleep.c
 * -I and -l may vary on your computer.
 * Your computer may use something besides -fPIC
*/

#include <windows.h>
#include <stdint.h>
#include "msleep.h"

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
