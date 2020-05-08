typedef unsigned long  crc_t;

#define WIDTH    (8 * sizeof(crc_t))
#define TOPBIT   (1 << (WIDTH - 1))

#define CRC_NAME			"CRC-32"
#define POLYNOMIAL			0x04C11DB7
#define INITIAL_REMAINDER	0xFFFFFFFF
#define FINAL_XOR_VALUE		0xFFFFFFFF
#define REFLECT_DATA		TRUE
#define REFLECT_REMAINDER	TRUE
#define CHECK_VALUE			0xCBF43926

#undef  REFLECT_DATA
#define REFLECT_DATA(X)			((unsigned char) reflect((X), 8))

#undef  REFLECT_REMAINDER
#define REFLECT_REMAINDER(X)	((crc_t) reflect((X), WIDTH))

//~ __declspec(dllexport) unsigned long _crc32(unsigned char const message[], int nBytes);
