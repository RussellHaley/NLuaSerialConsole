#ifndef WINLUA_API
#ifdef _WIN32
#define WINLUA_API __declspec(dllexport)
#else
#define WINLUA_API __attribute__ ((visibility ("default")))
#endif
#endif
