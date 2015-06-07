Program ConsoleTest;

{
	This program demonstrates and tests the console IO routines.
It uses the a small group of routines I wrote to make it a bit easier
to port Turbo programs that do screen IO.
}

{$I "Include:Exec/Ports.i"}
{$I "Include:Intuition/Intuition.i" for window structures and functions }
{$I "Include:Utils/CRT.i" for ReadKey, WriteString, AttachConsole, etc. }

var
    w  : WindowPtr;

Function OpenTheWindow() : Boolean;
var
    nw : NewWindowPtr;
begin
    new(nw);
    with nw^ do begin
	LeftEdge := 20;
	TopEdge := 50;
	Width := 300;
	Height := 100;

	DetailPen := -1;
	BlockPen  := -1;
	IDCMPFlags := 0;
	Flags := WINDOWSIZING + WINDOWDRAG + WINDOWDEPTH +
		 SMART_REFRESH + ACTIVATE;
	FirstGadget := nil;
	CheckMark := nil;
	Title := "Press q to Quit";
	Screen := Nil;
	BitMap := nil;
	MinWidth := 50;
	MaxWidth := -1;
	MinHeight := 20;
	MaxHeight := -1;
	WType := WBENCHSCREEN_f;
    end;

    w := OpenWindow(nw);
    dispose(nw);
    OpenTheWindow := w <> nil;
end;

var
    ConBlock : Address;
    ch : Array [0..1] of Char;
begin
    if OpenTheWindow() then begin
	ConBlock := AttachConsole(w);
	if ConBlock <> Nil then begin
	    ch[1] := '\0'; { Just for ease of writing }
	    repeat
		ch[0] := ReadKey(ConBlock);
		WriteString(ConBlock, Adr(ch));
	    until ch[0] = 'q';
	    DetachConsole(ConBlock);
	end else
	    Writeln('Could not open console device');
	CloseWindow(w);
   end else
	writeln('Could not open the window');
end.
