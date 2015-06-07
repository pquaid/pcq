program test;

{
	This is the most ridiculous jumble of records, arrays and strings
I could keep track of.  If this works, all the addressing stuff must work.
This is the test that the 1.0b compiler failed, which prompted me to re-
write the Selector() routine.
}

{$I "Include:Utils/StringLib.i"}

type
    BigArray = Array [5..63] of String;
    BigRecord= Record
		   First : Integer;
		   Second : String;
		   Third  : BigArray;
		end;
    BigPtr = ^BigRecord;
    SmallArray = Array [-4..16] of BigPtr;

var
    s : SmallArray;
    i : Short;
    s1 : String;
    s2 : Array [1..4] of String;
begin
    new(s[-2]);
    s[-2]^.Second := AllocString(80);
    s[-2]^.Third[11] := AllocString(80);
    write('Enter String 1 : ');
    ReadLn(s[-2]^.Second);
    write('Enter String 2 : ');
    ReadLn(s[-2]^.Third[11]);
    writeln(s[-2]^.Second);
    writeln(s[-2]^.Third[11]);
    i := 0;
    while s[-2]^.Second[i] <> Chr(0) do begin
	write(s[-2]^.Second[i]);
	i := Succ(i);
    end;
    writeln;
    i := 0;
    while s[-2]^.Third[11][i] <> Chr(0) do begin
	write(s[-2]^.Third[11][i]);
	i := Succ(i);
    end;
    writeln;
    writeln('Adr s[-2]^.Second is    ', Integer(Adr(s[-2]^.Second)));
    writeln('Adr s[-2]^.Second[2] is ', Integer(Adr(s[-2]^.Second[2])));
    writeln('Adr s[-2]^.Second^ is   ', Integer(Adr(s[-2]^.Second^)));
    writeln('Adr s[-2]^.Third[11] is ', Integer(Adr(s[-2]^.Third[11])));
    writeln('Adr s[-2]^.Third[11][2] ', Integer(Adr(s[-2]^.Third[11][2])));
    writeln('Adr s[-2]^.Third[11]^   ', Integer(Adr(s[-2]^.Third[11]^)));
end.
