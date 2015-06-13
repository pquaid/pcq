{

	CMem.i for PCQ Pascal

	Purpose : Old C Memory routine emulation

	(Pardon my French)

}

Procedure SetMem (ou : Address; combien: integer; que : byte);

var	I : integer;
	c : ^byte;

begin
c := ou;
for I := 1 to combien do
	begin
	c^ := que;
	inc(c);
	end;
end;

Procedure MovMem (from, a : Address; combien : integer);

begin
CopyMem (from, a, combien);
end;

