Program Mapper;

{
    This program maintains a map for the game Empire (by Chris Gray and
    David Wright).  It doesn't do anything fancy like read sector dumps -
    it's meant to replace graph paper with something a little more colorful
    and easy to erase.

    I used the console.device and ANSI codes to do the drawing, simply
    because I didn't feel like measuring fonts and all that.  Thus this
    version is limited to 8 colors, whereas its MS-DOS cousin, ironically,
    provides 16.

    The storage of the map itself is a dump of MS-DOS screen memory.  In
    other words, each word corresponds to something like BBTTCCCC in
    hex, where BB is the background color, TT is the foreground (or text)
    color, and CCCC is the actual ASCII character.

    It would not be at all difficult to add a routine to parse the output
    from the dump command.  If you did that, you could expand the inform-
    ation window to list things like population and whatever.

    If you've never played Empire, it's your basic game of territorial
    conquest, played over several weeks or months.  Players in our game
    sign in over the modem, and play 30 minute turns every day (that's
    30 minutes on line, plus 23.5 hours planning time).  It's a modern
    version of an old mainframe game, and was brought to the Amiga
    through the hard work of Chris Gray (the writer of the Draco compiler)
    and several others.  If you like Risk, Reach for the Stars, etc. give
    it a shot.  You'll end up writing programs like this.

    To use this program, just move around the map using the cursor keys.
    If you type a printable character the program will insert the
    character into the map at the current location in the current color.
    Use F1,F2 and Shift-F1, Shift-F2 to cycle through the available
    colors.  Press F10 to change to the color of the current sector.
    Press Shift F10 to print the entire map to "prt:"

    This was originally written for a 32 X 32 map, and there may be
    some lingering problems for other sizes.
}


{$I "Include:Intuition/Intuition.i"}
{$I "Include:Graphics/Graphics.i"}
{$I "Include:Graphics/View.i"}
{$I "Include:Exec/Libraries.i"}
{$I "Include:Utils/ConsoleUtils.i"}
{$I "Include:Utils/DeadKeyConvert.i"}
{$I "Include:Utils/CRT.i"}
{$I "Include:Utils/StringLib.i"}

var
    w          : WindowPtr;
    infowindow : WindowPtr;
    c          : Address; { CRT handle for w }
    infocon    : Address; { Another CRT handle }
    s          : ScreenPtr;

    MapName       : String;

Const
    CenterX = 23;
    CenterY = 8;

    CurrentText : Short = 1;
    CurrentBack : Short = 0;

    CX          : Short = 0;
    CY          : Short = 1;

    MapSize    = 32;
    MinCoord   = -(MapSize div 2);
    MaxCoord   = MapSize div 2 - 1;

Const
    StdInName  : String = Nil;  { This program will not automatically }
    StdOutName : String = Nil;  { open a console window, so no read/write }

Function OpenTheScreen : Boolean;
var
    ns : NewScreenPtr;
begin
    new(ns);
    with ns^ do begin
	LeftEdge := 0;
	TopEdge  := 0;
	Width    := 640;
	Height   := 200;
	Depth    := 3;
	DetailPen := 7;
	BlockPen  := 7;
	ViewModes := 32768;
	SType     := CUSTOMSCREEN_f;
	Font      := Nil;
	DefaultTitle := "Empire Map";
	Gadgets   := nil;
	CustomBitMap := nil;
    end;
    s := OpenScreen(ns);
    dispose(ns);
    OpenTheScreen := s <> nil;
end;

Function OpenTheWindow : Boolean;
{
    Actually opens both the main map window and the information
    window below it.  This could probably be arranged better, and
    even fit on a low-res screen if your memory is tight.
}
var
    nw : NewWindow;
begin
    with nw do begin
	LeftEdge := 120;
	TopEdge := 151;
	Width := 380;
	Height := 40;

	DetailPen := 7;
	BlockPen  := 7;
	IDCMPFlags := 0;
	Flags := SIMPLE_REFRESH + ACTIVATE;
	FirstGadget := Nil;
	CheckMark := Nil;
	Title := "";
	Screen := s;
	BitMap := Nil;
	MinWidth := 0;
	MaxWidth := -1;
	MinHeight := 0;
	MaxHeight := -1;
	WType := CUSTOMSCREEN_f;
    end;

    infowindow := OpenWindow(Adr(nw));
    if infowindow = Nil then
	OpenTheWindow := False;

    with nw do begin
	TopEdge := 12;
	Height  := 138;
    end;

    w := OpenWindow(Adr(nw));
    OpenTheWindow := w <> Nil;
end;

Procedure ResetColors;
{
    Sets the eight colors of this screen to the normal ANSI values.
    This way it looks about the same on the Amiga as the PC.  What
    a shame.
}
var
    vp : ViewPortPtr;
begin
    vp := ViewPortAddress(w);
    SetRGB4(vp, 0, 0, 0, 0);	{ Black	}
    SetRGB4(vp, 1, 0, 0, 15);	{ Blue	}
    SetRGB4(vp, 2, 0, 15, 0);	{ Green	}
    SetRGB4(vp, 3, 0, 15, 15);	{ Cyan	}
    SetRGB4(vp, 4, 15, 0, 0);	{ Red	}
    SetRGB4(vp, 5, 15, 0, 15);	{ Magenta }
    SetRGB4(vp, 6, 10, 7, 0);	{ Brown	}
    SetRGB4(vp, 7, 15, 15, 15);	{ Light Gray }
end;

Procedure OpenEverything;
{
    Open, in this order, the console device, the graphics library (just
    for the SetRGB4 calls), the screen, and both windows.  Then attach
    a CRT unit to each window.
}
var
    Error : Short;
begin
    OpenConsoleDevice;
    GfxBase := OpenLibrary("graphics.library",0);
    if OpenTheScreen then
	if OpenTheWindow then begin
	    c := AttachConsole(w);
	    if c <> Nil then begin
		infocon := AttachConsole(infowindow);
		if infocon <> Nil then
		    Return;
		DetachConsole(c);
	    end;
	end;
    CloseWindow(w);
    CloseScreen(s);
    CloseConsoleDevice;
end;

Procedure CloseEverything;
{
    The same as OpenEverything, but reversed.
}
begin
    DetachConsole(infocon);
    DetachConsole(c);
    CloseWindow(infowindow);
    CloseWindow(w);
    CloseScreen(s);
    CloseLibrary(GfxBase);
    CloseConsoleDevice;
end;

Function Fix(s : Short) : Short;
{
    Adjust coordinate values for the toroidal shape of the map (on
    a 32 sector wide map, -16 is the same as 16).
}
begin
    while s < MinCoord do
	s := s + MapSize;
    while s > MaxCoord do
	s := s - MapSize;
    Fix := s;
end;

{
   Actual definitions for the map type and the map itself.  This
   program, like Empire itself, only accepts square maps.
}

Type
    Column  = Array [MinCoord..MaxCoord] of Short;
    MapType = Array [MinCoord..MaxCoord] of Column;

var
    Command : Char;
    Map     : MapType;

{
    Draw the sector using a three-character string and the appropriate
    color settings.  If you wanted to go to a smaller window size you
    could cut this down to two or one character with little problem.
}

Procedure DrawSector(Sector : Short);
var
    Buffer : Array [0..3] of Char;
begin
    TextColor(c, (Sector shr 8) and 7);
    TextBackground(c, Sector shr 12);
    Buffer := '   \0';
    Buffer[1] := Chr(Sector);
    WriteString(c, Adr(Buffer));
end;

{
    Draw the part of the map that will fit in the window, centered
    on xx and yy.
}

Procedure DrawMap(xx, yy : Short);
var
    x,y : Short;
    row : Short;
begin
    CursOff(c);
    row := 1;
    for y := yy - 7 to yy + 7 do begin
	GotoXY(c, 1, row);
	for x := xx - 7 to xx + 7 do
	    DrawSector(Map[fix(y),fix(x)]);
	Inc(row);
    end;
    CX := xx;
    CY := yy;
    CursOn(c);
end;

{
    Scroll the map left.  In order to avoid wrap-around problems,
    this routine deletes the last three spaces on each line, then
    inserts three spaces on the left side.
}

Procedure ScrollLeft;
var
    i : Short;
    x,y : Short;
begin
    for i := 1 to 15 do begin
	GotoXY(c, 43, i);
	ClrEOL(c);
	GotoXY(c, 1, i);
	WriteString(c, "\c3@");   { Insert 3 spaces }
    end;
    CX := Fix(Pred(CX));
    x := Fix(CX - 7);
    i := 1;
    for y := CY - 7 to CY + 7 do begin
	GotoXY(c, 1, i);
	DrawSector(Map[Fix(y),x]);
	Inc(i);
    end;
end;

{
    Scroll the map to the right.  This routine deletes the first three
    characters of each line, then draws the sectors at the right edge
    of each line.
}

Procedure ScrollRight;
var
    i : Short;
    x : Short;
    y : Short;
begin
    for i := 1 to 15 do begin
	GotoXY(c, 1, i);
	WriteString(c, "\c3P");
    end;
    CX := Fix(Succ(CX));
    x := Fix(CX + 7);
    i := 1;
    for y := CY - 7 to CY + 7 do begin
	GotoXY(c, 43, i);
	DrawSector(Map[Fix(y),x]);
	Inc(i);
    end;
end;

{
    Scroll the window up.  This routine inserts a new first line,
    then draws the sectors across.  Note that this is somewhat
    faster than the left and right routines.
}

Procedure ScrollUp;
var
    i : Short;
    y : Short;
begin
    GotoXY(c, 1, 1);
    WriteString(c, "\cL");
    CY := Fix(Pred(CY));
    y := Fix(CY - 7);
    for i := CX - 7 to CX + 7 do
	DrawSector(Map[y, Fix(i)]);
end;

{
    Scroll the window down.  Delete the first line, go to the last one,
    and draw the sectors across.
}

Procedure ScrollDown;
var
    i : Short;
    y : Short;
begin
    GotoXY(c, 1, 1);
    WriteString(c, "\cM");
    CY := Fix(Succ(CY));
    GotoXY(c, 1, 15);
    y := Fix(CY + 7);
    for i := CX - 7 to CX + 7 do
	DrawSector(Map[y, Fix(i)]);
end;

{
    Load a map from the disk.  If there is a problem, the program
    will abort ( the O- option was not used).
}

Procedure LoadMap;
var
    x,y     : Short;
    MapFile : File of MapType;
begin
    if reopen(MapName, MapFile) then begin
	Read(MapFile, Map);
	Close(MapFile);
	Return;
    end;
    for x := MinCoord to MaxCoord do
	for y := MinCoord to MaxCoord do
	    Map[y,x] := $0120;  { by default, each sector is space }
end;

{
    Save the current map, returning TRUE if everything goes OK
}

Function SaveMap : Boolean;
var
    MapFile : File of MapType;
    OK	: Boolean;
begin
    if open(MapName, MapFile) then begin
	Write(MapFile, Map);
	{$O-}
	OK := IOResult = 0;
	{$O+}
	Close(MapFile);
	SaveMap := OK;
    end else
	SaveMap := False;
end;

{
    Print the map on the preferences printer.  The printout will always
    be centered on the capital (location 0,0), but that can easily be
    changed.
}

Procedure PrintMap;
var
    PrintFile : Text;
    x, y : Integer;

    Procedure NumberRow;
    begin
	Write(PrintFile, '  ');
	for x := MinCoord to MaxCoord do begin
	    case x of
	      -99..-10 : Write(PrintFile, ' 1');
	       -9.. -1 : Write(PrintFile, ' -');
	        0..  9 : Write(PrintFile, ' 0');
	       10.. 99 : Write(PrintFile, ' 1');
	    end;
	end;
	Writeln(PrintFile);
	Write(PrintFile, '  ');
	for x := MinCoord to MaxCoord do
	    Write(PrintFile, Abs(x) mod 10:2);
	Writeln(PrintFile);
    end;

    Procedure NumberColumn(i : Integer);
    begin
	case i of
	  -99..-10 : Write(PrintFile, Abs(i));
	   -9.. -1 : Write(PrintFile, i);
	    0..  9 : Write(PrintFile, '0', i);
	   10.. 99 : Write(PrintFile, i);
	end;
    end;

begin
    if not open("prt:", PrintFile) then
	return;
    NumberRow;
    Writeln(PrintFile);
    for y := MinCoord to MaxCoord do begin
	NumberColumn(y);
	for x := MinCoord to MaxCoord do
	    Write(PrintFile, ' ', Chr(Map[y,x]));
	Write(PrintFile, ' ');
	NumberColumn(y);
	Writeln(PrintFile);
    end;
    Writeln(PrintFile);
    NumberRow;
    Close(PrintFile);
end;

{
    Handle the function keys.  This is really primitive stuff,
    but since I wanted it to match the PC version this was
    the easiest way to handle it.
}

Procedure ProcessFunctionKey(fnum : Short);
begin
    case fnum of
      0 : begin  { F1 : cycle forward through text colors }
	      CurrentText := Succ(CurrentText) and 7;
	      TextColor(c, CurrentText);
	  end;
      1 : begin  { F2 : cycle forward through background colors }
	      CurrentBack := Succ(CurrentBack) and 7;
	      TextBackground(c, CurrentBack);
	  end;
      9 : begin  { F10 : Use the color of the current sector }
	      CurrentText := (Map[CY,CX] and $0F00) shr 8;
	      CurrentBack := (Map[CY,CX] and $F000) shr 12;
	      TextColor(c, CurrentText);
	      TextBackground(c, CurrentBack);
	  end;
      10: begin  { Shift F1 : cycle backward through the text colors }
	      CurrentText := Pred(CurrentText) and 7;
	      TextColor(c, CurrentText);
	  end;
      11: begin  { Shift F2 : cycle backward through the background colors }
	      CurrentBack := Pred(CurrentBack) and 7;
	      TextColor(c, CurrentBack);
	  end;
      19 : PrintMap;  { Shift F10 : Print the map }
    end;
end;

{
    Process anything that starts with a CSI, which in this case
    means function keys and cursor keys.  Anything else is
    ignored.
}

Procedure ProcessCommand;
var
    Param : Short;
begin
    Param := 0;
    Command := ReadKey(c);
    while (Command >= '0') and (Command <= '9') do begin
	Param := Param * 10 + (Ord(Command) - Ord('0'));
	Command := ReadKey(c);
    end;
    TextBackground(c, 0);
    case Command of
      'A' : ScrollUp;
      'B' : ScrollDown;
      'C' : ScrollRight;
      'D' : ScrollLeft;
      '~' : ProcessFunctionKey(Param);
    end;
end;

{
    Set the current sector to the command character, and draw it.
}

Procedure SetMap;
var
    Buffer : Array [0..3] of Char;
begin
    GotoXY(c, Pred(CenterX),CenterY);
    Map[CY,CX] := (CurrentBack shl 12) + (CurrentText shl 8) + Ord(Command);
    DrawSector(Map[CY,CX]);
end;

{
    Write the current location and color to the information window
}

Procedure WriteInfo;
var
    NBuf : Array [0..11] of Char;
    Dummy : Integer;
begin
    TextColor(infocon, 7);
    TextBackground(infocon, 0);
    Dummy := IntToStr(Adr(NBuf), CY);
    GotoXY(infocon, 1, 2);
    ClrEOL(infocon);
    GotoXY(infocon, 4, 2);
    WriteString(infocon, "Row: ");
    WriteString(infocon, Adr(NBuf));
    Dummy := IntToStr(Adr(NBuf), CX);
    GotoXY(infocon, 14, 2);
    WriteString(infocon, "Column: ");
    WriteString(infocon, Adr(NBuf));
    TextColor(infocon, CurrentText);
    TextBackground(infocon, CurrentBack);
    GotoXY(infocon, 27, 2);
    WriteString(infocon, "Color");
end;

begin
    MapName := "Empire.MAP";
    OpenEverything;
    ResetColors;
    TextColor(c, CurrentText);
    TextBackground(c, CurrentBack);
    CursOff(infocon);
    LoadMap;
    DrawMap(0,0);
    repeat
	WriteInfo;
	GotoXY(c, CenterX, CenterY);
	CursOn(c);
	Command := ReadKey(c);
	CursOff(c);
	if Command = '\c' then { CSI }
	    ProcessCommand
	else if Command = '\e' then begin  { ESC }
	    if SaveMap then begin
		CloseEverything;
		Exit(0);
	    end;
	end else if (Command >= ' ') and (Command <= '~') then
	    SetMap;
    until False;
end.
