program PCQ_mangle;

{$I "Include:Utils/StringLib.i"}
{$I "Include:Utils/Parameters.i"}
{$I "Include:Utils/SameName.i"}
{$I "Include:Utils/Break.i"}

var

	outF		: text;
	inFN, outFN	: string;

	bs		: string;
	i, max		: short;
	ifl		: array [1..100] of string;

Procedure Dofile (filespec : string);
	forward;

Function familiar (st : string) : boolean;

var	fam	: boolean;

begin
fam := false;
if max > 0 then
	for i := 1 to max do
		begin
		if strieq (st, ifl[i]) then fam := true;
		end;
familiar := fam;
end;

Procedure Familiarize (st : string);

begin
inc(max);
if max <= 100 then strcpy (ifl[max], st);
end;

Procedure Parse (st : string);

var	ss, s2	: string;
	ch	: char;
	ph, p2	: short;
	ff	: text;

begin
ss := allocstring (strlen (st) + 1);
s2 := allocstring (strlen (st) + 1);
if (st[0] = '{') and (st[1] = '$') and (st[2] = 'I') then
	begin
	ph := 3;
	p2 := 0;
	while st[ph] <> '"' do
		inc (ph);
	inc (ph);
	while st[ph] <> '"' do
		begin
		ss[p2] := st[ph];
		inc (p2);
		inc (ph);
		end;
	ss[p2] := char(0);
	if not familiar (ss) then
		begin
		write ("Including file ");
		writeln (ss);
		DoFile (ss);
		Familiarize (ss);
		end;
	end else
		writeln (outF, st);
freestring (ss);
freestring (s2);
end;

Procedure Dofile (filespec : string);

var	inF	: text;
	sk	: string;

begin
sk := allocstring (2000);
if reopen (filespec, inF) then
	begin
	while (not eof(inF)) and (not checkbreak) do
		begin
		readln (inF, sk);
		Parse (sk);
		end;
	close (inF);
	end else
		begin
		write ("Couldn't open file ");
		writeln (filespec);
		end;
end;
	
begin
inFN := allocstring (80);
outFN := allocstring (80);
max := 0;
for i := 1 to 100 do
	ifl[i] := allocstring (70);
WriteLn ("PCQMangle v0.90b, Sept 14 1991 Chris Pressey");
Write ("Input file name  : ");
Readln (inFN);
Write ("Output file name : ");
Readln (outFN);
if open (outFN, outF) then Dofile (inFN) else
	writeln ("Could not open output file.");
close (outF);
for i := 1 to 100 do
	freestring (ifl[i]);
freestring (inFN);
freestring (outFN);
end.
