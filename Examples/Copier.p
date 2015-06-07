Program Copier;

{
	This is a simple program to exercise DOS a bit.  It just
copies one file to another, using DOSRead and DOSWrite.
}

{$I "Include:Libraries/DOS.i"}
{$I "Include:Exec/Ports.i"}
{$I "Include:Utils/Parameters.i"}
{$I "Include:Utils/StringLib.i"}

var
    InputFileName  : String;
    OutputFileName : String;
    Position	   : Integer;
    Infile         : FileHandle;
    Outfile        : FileHandle;
    Buffer	   : ^array [1..1000] of char;

Procedure Usage;
begin
    Writeln('Usage: Copier FromName ToName');
    Exit(20);
end;

begin
    InputFileName := AllocString(80);
    OutputFileName := AllocString(80);

    GetParam(1, InputFileName);
    if InputFileName[0] = Chr(0) then
	Usage;
    GetParam(2, OutputFileName);
    if OutputFileName[0] = Chr(0) then
	Usage;

    Infile := DOSOpen(InputFileName, MODE_OLDFILE);
    if Infile <> nil then begin
	Outfile := DOSOpen(OutputFileName, MODE_NEWFILE);
	if Outfile <> nil then begin
	    New(Buffer);
	    repeat
		Position := DOSRead(Infile, Buffer, 1000);
		if Position > 0 then begin
		    Position := DOSWrite(Outfile, Buffer, Position);
		    if Position = 0 then begin
			writeln('Write error');
			exit(20);
		    end;
		end;
	    until Position = 0;
	    Dispose(Buffer);
	    DOSClose(Outfile);
	end else
	    writeln('Could not open output file.');
	DOSClose(Infile);
    end else
	writeln('Could not open input file.');
end.
