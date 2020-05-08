#include "crc32.h"

static unsigned long reflect(unsigned long data, unsigned char nBits)
{
	unsigned long  reflection = 0x00000000;
	unsigned char  bit;

	/*
	* Reflect the data about the center bit.
	*/
	for (bit = 0; bit < nBits; ++bit)
	{
		/*
		* If the LSB bit is set, set the reflection of it.
		*/
		if (data & 0x01)
		{
			reflection |= (1 << ((nBits - 1) - bit));
		}

		data = (data >> 1);
	}

	return (reflection);

}	/* reflect() */

crc crc32_c(unsigned char const message[], int nBytes)
{
	crc            remainder = INITIAL_REMAINDER;
	int            byte;
	unsigned char  bit;


	/*
	* Perform modulo-2 division, a byte at a time.
	*/
	for (byte = 0; byte < nBytes; ++byte)
	{
		/*
		* Bring the next byte into the remainder.
		*/
		remainder ^= (REFLECT_DATA(message[byte]) << (WIDTH - 8));

		/*
		* Perform modulo-2 division, a bit at a time.
		*/
		for (bit = 8; bit > 0; --bit)
		{
			/*
			* Try to divide the current data bit.
			*/
			if (remainder & TOPBIT)
			{
				remainder = (remainder << 1) ^ POLYNOMIAL;
			}
			else
			{
				remainder = (remainder << 1);
			}
		}
	}

	/*
	* The final remainder is the CRC result.
	*/
	return (REFLECT_REMAINDER(remainder) ^ FINAL_XOR_VALUE);
}
