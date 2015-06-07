program WriteHexTest;

{ I can't remember what prompted me to write this program. }


Procedure WriteHex(num : Integer);
var
    Result : Array [1..8] of Char;
    index  : Short;

    Function ToHex(n : Short) : Char;
    begin
	if n < 10 then
	    ToHex := Chr(n + Ord('0'))
	else
	    ToHex := Chr(n - 10 + Ord('A'));
    end;

begin
    for index := 8 downto 1 do begin
	Result[index] := ToHex(num and 15);
	num := num shr 4;
    end;
    Write(Result);
end;

begin
    WriteHex($01010101); WriteLn;
    WriteHex($10101010); WriteLn;
    WriteHex(MaxInt); WriteLn;
end.
