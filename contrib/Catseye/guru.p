Program Guru;

{$I "Include:Exec/Exec.i"}
{$I "Include:Exec/Memory.i"}
{$I "Include:Intuition/Intuition.i"}
{$I "Include:Utils/StringLib.i"}
{$I "Include:Utils/Parameters.i"}

var
	afp		: ^Array[0..1024] of char;
	TextString	: String;
	Home		: Array [0..100] of char;
	X		: ^Short;
	Affirmative	: Boolean;
	I, j		: Short;

procedure Usage;

begin
WriteLn ('Guru V1.0 - Alert the user with custom Intuition Alerts!\n');
WriteLn ('Usage : Guru <"String">\n');
Exit (10);
end;

Begin
afp := Address (CommandLine);
i := 0;
while (isspace(afp^[i]) or (afp^[i] = '"')) do inc(i);
j := 3;
while (afp^[i] <> '"') do
	begin
	Home [j] := afp^[i];
	inc(i);
	inc (j);
	end;
Home [j] := char(0);
X := Adr (Home [0]);
X^ := (640 - (j-3) * 8) DIV 2;
Home [2] := Char (25);
Affirmative := DisplayAlert ($00000000, string (adr(Home[0])), 50);
if Affirmative then exit (5) else exit (0);
end.
