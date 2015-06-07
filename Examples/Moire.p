Program Moire;

	{ This program just draws a Moire pattern in a window.
	  It uses a surprising breadth of functions, so it shows
	  off a bit of what PCQ can do.  And it works to boot. }

{$I "Include:Exec/Libraries.i"}
{$I "Include:Exec/Interrupts.i"}
{$I "Include:Exec/Ports.i"}
{$I "Include:Intuition/Intuition.i"}
{$I "Include:Graphics/Graphics.i"}
{$I "Include:Graphics/Pens.i"}

var
    w  : WindowPtr;
    s  : Address;
    m  : MessagePtr;

Function OpenTheScreen() : Boolean;
var
    ns : NewScreenPtr;
begin
    new(ns);
    with ns^ do begin
	LeftEdge := 0;
	TopEdge  := 0;
	Width    := 640;
	Height   := 200;
	Depth    := 2;
	DetailPen := 3;
	BlockPen  := 2;
	ViewModes := 32768;
	SType     := CUSTOMSCREEN_f;
	Font      := nil;
	DefaultTitle := "Close the Window to End This Demonstration";
	Gadgets   := nil;
	CustomBitMap := nil;
    end;
    s := OpenScreen(ns);
    dispose(ns);
    OpenTheScreen := s <> nil;
end;

Function OpenTheWindow() : Boolean;
var
    nw : NewWindowPtr;
begin
    new(nw);
    with nw^ do begin
	LeftEdge := 20;
	TopEdge := 50;
	Width := 336;
	Height := 100;

	DetailPen := -1;
	BlockPen  := -1;
	IDCMPFlags := CLOSEWINDOW_f;
	Flags := WINDOWSIZING + WINDOWDRAG + WINDOWDEPTH +
		 WINDOWCLOSE + SMART_REFRESH + ACTIVATE;
	FirstGadget := nil;
	CheckMark := nil;
	Title := "Feel Free to Re-Size the Window";
	Screen := s;
	BitMap := nil;
	MinWidth := 50;
	MaxWidth := -1;
	MinHeight := 20;
	MaxHeight := -1;
	WType := CUSTOMSCREEN_f;
    end;

    w := OpenWindow(nw);
    dispose(nw);
    OpenTheWindow := w <> nil;
end;

Procedure DoDrawing(RP : RastPortPtr);
var
    x  : Short;
    Pen : Byte;
    Stop : Short;
begin
    Pen := 1;
    while true do begin
	with w^ do begin
	    x := 0;
	    while x < Pred(Width - BorderRight - BorderLeft) do begin
		Stop := Pred(Width - BorderRight);
		SetAPen(RP, Pen);
		Move(RP, Succ(x + BorderLeft), BorderTop);
		Draw(RP, Stop - x, Pred(Height - BorderBottom));
		Pen := (Pen + 1) mod 4;
		Inc(x);
	    end;
	    m := GetMsg(UserPort);
	    if m <> Nil then
		return;
	    x := 0;
	    while x < Pred(Height - BorderBottom - BorderTop) do begin
		Stop := Pred(Height - BorderBottom);
		SetAPen(RP, Pen);
		Move(RP, Pred(Width - BorderRight), Succ(x + BorderTop));
		Draw(RP, Succ(BorderLeft), Stop - x);
		Pen := (Pen + 1) mod 4;
		Inc(x);
	    end;
	    m := GetMsg(UserPort);
	    if m <> Nil then
		return;
	end;
    end;
end;

begin
	{ Note that the startup code of all PCQ programs depends on
	  Intuition, so if we got to this point Intuition must be
	  open, so the run time library just uses the pointer that
	  the startup code created.  Same with DOS, although we don't
	  use that here. }

    GfxBase := OpenLibrary("graphics.library", 0);
    if GfxBase <> nil then begin
	if OpenTheScreen() then begin
	    if OpenTheWindow() then begin
		DoDrawing(w^.RPort);
		Forbid;
		repeat
		    m := GetMsg(w^.UserPort);
		until m = nil;
		CloseWindow(w);
		Permit;
	    end else
		writeln('Could not open the window');
	    CloseScreen(s);
	end else
	    writeln('Could not open the screen.');
	CloseLibrary(GfxBase);
    end else
	writeln('Could not open graphics.library');
end.

