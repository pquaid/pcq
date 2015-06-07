Program Typer;

{
	Demonstrates the use of the PCQ Pascal IO routines by
	implementing something like the AmigaDOS TYPE command.
}

var
    Infile : Text;
    InfileName : String;

{$I "Include:Utils/StringLib.i"}
{$I "Include:Utils/Parameters.i"}

begin
    InfileName := AllocString(80);
    GetParam(1, InfileName);
    if InfileName^ = Chr(0) then begin
	Writeln('No filename specified');
	Exit(10);
    end;
    if reopen(InfileName, Infile) then begin
	while not eof(Infile) do begin
	    write(Infile^);
	    get(Infile);
	end;
	close(Infile);
    end else
	writeln('Could not open the input file.');
end.
