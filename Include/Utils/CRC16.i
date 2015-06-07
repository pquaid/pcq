{
	CRC16.p

	Routines for calculating 16-bit CRC values.
}

{
 * UpdCRC derived from article Copyright (C) 1986 Stephen Satchell.
 *  NOTE: First argument must be in range 0 to 255.
 *        Second argument is referenced twice.
 *
 * Programmers may incorporate any or all code into their programs,
 * giving proper credit within the source. Publication of the
 * source routines is permitted so long as proper credit is given
 * to Stephen Satchell, Satchell Evaluations and Chuck Forsberg,
 * Omen Technology.

    UpdCRC uses the fast table-driven method to calculate CRCs.
    You pass in the next byte as "cp", plus the previous CRC value
    as "crc".  The function returns the new crc value.  "crc" should
    be initialized to 0 before calculating CRCs, by the way.
}

Function UpdCRC(cp : Byte; crc : Short) : Short;
    External;

{
    CRCCheck uses the UpdCRC function to calculate the CRC of
    an entire buffer at once.  You pass in the Buffer address
    and the number of characters you want to use, and this
    function returns the CRC value.
}

Function CRCCheck(Buffer : Address; Length : Integer) : Short;
    External;

