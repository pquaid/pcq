Program LED;

{$I "Include:Exec/Exec.i"}
{$I "Include:Exec/Memory.i"}
{$I "Include:Utils/StringLib.i"}
{$I "Include:Utils/Parameters.i"}
{$I "Include:Hardware/CIA.i"}

type

	BytePtr = ^Byte;

var
	b		: BytePtr;
	i, n		: Short;

procedure Usage;

begin
WriteLn ('LED V1.0 - Change the status of the power LED and audio filter.\n');
WriteLn ('Usage : LED <number> where');
WriteLn ('            0 is off');
WriteLn ('            1 is on\n');
Exit (10);
end;

Begin
i := 0;
b := BytePtr ($bfe001);
while (isspace(CommandLine[i])) do inc(i);
n := ord (commandline[i]) - ord('0');
case n of
	0 : b^ := (b^ or CIAF_LED);
	1 : b^ := (b^ and (not CIAF_LED));
	else Usage;
	end;
end.
