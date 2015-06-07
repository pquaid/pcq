program Icons;

{
  This program shows how to access the arguments passed to a program
  by the Workbench.  Compile and link this program, then make a
  tool icon for it.  Then activate the program by clicking on some
  project icons and this icon.  In my original archive, I included
  a copy of the CLI icon in this directory, so you might be able to
  use it.

  This program also shows that PCQ will open a default console window
  if a program run from the Workbench needs it.
}

{$I "Include:Utils/Parameters.i"}

var
   WB : WBStartupPtr;

   Arg : Integer;
begin
    WB := GetStartupMsg();
    if WB <> nil then begin
	Writeln('There were ', WB^.sm_NumArgs, ' arguments.');
	for Arg := 1 to WB^.sm_NumArgs do
	    writeln(WB^.sm_ArgList^[Arg].wa_Name);
	readln;
    end else
	writeln('Run from the CLI');
end.

