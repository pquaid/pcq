Program CRC;

{
    CRC

    This program shows three different methods for calculating
    16-bit CRC values.  The one from the CRC16.i file is based on
    the ZMODEM method, whereas the other two are used for Kermit
    (and XMODEM, I think).  Unfortunately the two methods produce
    different results, although the two Kermit versions are
    compatible.

    The ZMODEM method uses a 256-entry (512 byte) table to speed
    up the calculation, and it is the fastest of these three.
    The CRC2 method is second, and the CRC3 method is the slowest
    by far.
}

{$I "Include:Utils/Parameters.i"}
{$I "Include:Utils/CRC16.i"}
{$I "Include:Utils/StringLib.i"}

var
    FileName	: String;
    InFile	: File of Byte;

    CRC1,
    CRC2,
    CRC3	: Word;

    c		: Byte;

{ This CRC algorithm is from the Kermit manual }

Function CalcCRC2(c : Byte; crc : Word) : Word;
begin
    crc := (crc shr 4) xor (((crc xor c) and 15) * 4225);
    CalcCRC2 := (crc shr 4) xor (((crc xor (c shr 4)) and 15) * 4225);
end;

{ This CRC algorithm is from an ancient Kermit program }

Function CalcCRC3(c : Byte; crc : Word) : Word;
var
    i : Integer;
    Temp : Integer;
begin
    for i := 0 to 7 do begin
	Temp := crc xor c;
	crc := crc shr 1;
	if Odd(Temp) then
	    crc := crc xor $8408;
	c := c shr 1;
    end;
    CalcCRC3 := crc;
end;

begin
    FileName := AllocString(256);
    GetParam(1,FileName);
    if FileName^ = '\0' then begin
	Writeln('Usage: CRC filename');
	Exit(10);
    end;

    if reopen(FileName, InFile, 2048) then begin
	CRC1 := 0;
	CRC2 := 0;
	CRC3 := 0;

	while not eof(InFile) do begin
	    Read(InFile, c);

	    CRC1 := UpdCRC(c, CRC1);
	    CRC2 := CalcCRC2(c, CRC2);
	    CRC3 := CalcCRC3(c, CRC3);

	end;
	Writeln('CRC is ', CRC1, ' ', CRC2, ' ', CRC3);
    end else
	Writeln('Could not open ', FileName);
end.

