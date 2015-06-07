Program Snowflake;

{ This program draws a fractal snowflake pattern.  I think I got it out
of some magazine years ago.  It was written, as I remember it, for the
PC in BASIC, which I converted to AmigaBASIC.  I have long since
forgotten the details of how it worked, so I could not give the
variables meaningful names.  To the original author, by the way, goes
the credit for those names.  Invoke the program with the line "Snow
<level>", where <level> is a digit between 1 and 6.  In order to get a
feel for what's going on, try running the levels in order.  Level 6
takes a long time, and frankly doesn't look as good as level 5.  }

{$I "Include:Exec/Ports.i" for GetMsg and WaitPort }
{$I "Include:Intuition/Intuition.i" for the windows }
{$I "Include:Graphics/Pens.i" for move() and draw() }
{$I "Include:Graphics/Graphics.i" for GfxBase }
{$I "Include:Exec/Libraries.i" just for OpenLibrary and CloseLibrary }
{$I "Include:Exec/Interrupts.i" for Forbid() and Permit() }

var
    dx : array [0..11] of real;
    dy : array [0..11] of real;
    sd : array [0..6] of integer;
    rd : array [0..6] of integer;
    sn : array [0..6] of integer;
    ln : array [0..6] of real;
    a  : real;
    nc : integer;
    x, y, t : real;
    w  : WindowPtr;
    rp : RastPortPtr;
    n  : integer;
    d, ns, i, j : integer;
    l : real;
    m : MessagePtr;

Procedure usage;
begin
    writeln('Usage: Snow <level>');
    writeln('       where <level> is between 1 and 6');
    exit(20);
end;

Function readcycles(): integer;
var
    index : integer;
    cycles : integer;
begin
    index := 0;
    while ((commandline[index] = ' ') or (commandline[index] = chr(9))) and
	(index < 128) do
	index := index + 1;
    if index >= 128 then
	usage;
    cycles := ord(commandline[index]) - ord('0');
    if (cycles > 6) or (cycles < 1) then
	usage;
    readcycles := cycles;
end;

Function OpenTheWindow() : Boolean;
var
    nw : NewWindowPtr;
begin
    new(nw);

    nw^.LeftEdge := 0;
    nw^.TopEdge := 0;
    nw^.Width := 640;
    nw^.Height := 200;

    nw^.DetailPen := -1;
    nw^.BlockPen  := -1;
    nw^.IDCMPFlags := CLOSEWINDOW_f;
    nw^.Flags := WINDOWDEPTH + WINDOWCLOSE + SMART_REFRESH + ACTIVATE;
    nw^.FirstGadget := nil;
    nw^.CheckMark := nil;
    nw^.Title := "Fractal Snowflake";
    nw^.Screen := nil;
    nw^.BitMap := nil;
    nw^.MinWidth := 50;
    nw^.MaxWidth := -1;
    nw^.MinHeight := 20;
    nw^.MaxHeight := -1;
    nw^.WType := WBENCHSCREEN_f;

    w := OpenWindow(nw);
    dispose(nw);
    OpenTheWindow := w <> nil;
end;

procedure initarrays;
begin
    sd[0] := 0;
    rd[0] := 0;
    sd[1] := 1;
    rd[1] := 0;
    sd[2] := 1;
    rd[2] := 7;
    sd[3] := 0;
    rd[3] := 10;
    sd[4] := 0;
    rd[4] := 0;
    sd[5] := 0;
    rd[5] := 2;
    sd[6] := 1;
    rd[6] := 2;

    for n := 0 to 6 do
	ln[n] := 1.0 / 3.0;
    ln[2] := sqrt(ln[1]);
    a := 0.0;
    for n := 6 to 11 do begin
	dy[n] := sin(a);
	dx[n] := cos(a);
        a := a + 0.52359;
    end;
    for n := 0 to 5 do begin
	dx[n] := -(dx[n + 6]);
	dy[n] := -(dy[n + 6]);
    end;
    x := 534.0;
    y := 151.0;
    t := 324.0;
end;

begin
    nc := readcycles();
    initarrays;

    GfxBase := OpenLibrary("graphics.library", 0);
    if GfxBase = nil then begin
	writeln('Could not open Graphics.library');
	exit(20);
    end;

    if OpenTheWindow() then begin
	rp := w^.RPort;

	for n := 0 to nc do
	    sn[n] := 0;

	Move(rp, trunc(x), trunc(y));

	repeat
	    d := 0;
	    l := t;
	    ns := 0;

	    for n := 1 to nc do begin
		i := sn[n];
		l := l * ln[i];
		j := sn[n - 1];
		ns := ns + sd[j];
		if odd(ns) then
		    d := (d + 12 - rd[i]) mod 12
		else
		    d := (d + rd[i]) mod 12;
	    end;

	    x := x + 1.33 * l * dx[d];
	    y := y - 0.5 * l * dy[d];

	    Draw(rp, trunc(x), trunc(y));
	    sn[nc] := sn[nc] + 1;
	    n := nc;
	    while (n >= 1) and (sn[n] = 7) do begin
		sn[n] := 0;
		sn[n - 1] := sn[n - 1] + 1;
		n := n - 1;
	    end;
	until sn[0] <> 0;
	m := WaitPort(w^.UserPort);
	forbid;
	repeat
	    m := GetMsg(w^.UserPort);
	until m = nil;
	permit;
	CloseWindow(w);
    end else
	writeln('Could not open the window');
    CloseLibrary(GfxBase);
end.
