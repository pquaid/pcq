Program Circle;

{
	  This program just draws two simple circles.  The first is
	  drawn using PCQ's new (at the moment) sine and cosine
	  functions.  The second is drawn directly over the top with
	  the SPSin and SPCos functions from the mathtrans.library.

	  I wrote this to determine whether the trig functions I had
	  just written were accurate enough to be worthwhile.  Since
	  these two circles come pretty close to overlapping, I
	  left them in.

	  To run this program without the mathtrans.library, just
	  remove the MathTrans.i include, the open and close
	  of the library, and lines that draw the second circle.
	  That's all.

	  Later Note: I replaced the older, less accurate functions
	  with more traditional series-based functions, which are
	  much more accurate and only a little slower.
}

{$I "Include:Exec/Libraries.i"}
{$I "Include:Exec/Interrupts.i"}
{$I "Include:Exec/Ports.i"}
{$I "Include:Intuition/Intuition.i"}
{$I "Include:Graphics/Graphics.i"}
{$I "Include:Graphics/Pens.i"}
{$I "Include:Libraries/MathTrans.i"}
{$I "Include:Utils/MathTransUtils.i"}

Const
    Pi = 3.1415927;
    TwoPi = Pi * 2.0;

    Aspect = 2.0;	{ To account for pixel shape }

var
    w  : WindowPtr;
    m  : MessagePtr;

Function OpenTheWindow() : Boolean;
var
    nw : NewWindowPtr;
begin
    new(nw);
    with nw^ do begin
	LeftEdge := 0;
	TopEdge := 0;
	Width := 640;
	Height := 200;

	DetailPen := -1;
	BlockPen  := -1;
	IDCMPFlags := CLOSEWINDOW_f;
	Flags := WINDOWSIZING + WINDOWDRAG + WINDOWDEPTH +
		 WINDOWCLOSE + SMART_REFRESH + ACTIVATE;
	FirstGadget := nil;
	CheckMark := nil;
	Title := "Horseshoes, handgrenades, and some trigonomentry";
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

Procedure DoCircle(RP : RastPortPtr; CX, CY, Radius : Short);
{
	Draw a circle using 500 line segments
}
Const
    Division = TwoPi / 500.0;
var
    t : Real;
    i : Integer;
    RealRad : Real;
begin
    SetAPen(rp, 1);
    RealRad := Float(Radius);
    Move(rp, CX + Round(RealRad * Aspect), CY);
    for i := 1 to 500 do
	Draw(rp, CX + Round(Cos(Float(i) * Division) * RealRad * Aspect),
		 CY + round(Sin(Float(i) * Division) * RealRad));
    Draw(rp, CX + Round(RealRad * Aspect), CY);
    SetAPen(rp, 3);
    Move(rp, CX + Round(RealRad * Aspect), CY);
    for i := 1 to 500 do
	Draw(rp, CX + Round(SPCos(Float(i) * Division) * RealRad * Aspect),
		 CY + round(SPSin(Float(i) * Division) * RealRad));
    Draw(rp, CX + Round(RealRad * Aspect), CY);
end;

begin
	{ Note that the startup code of all PCQ programs depends on
	  Intuition, so if we got to this point Intuition must be
	  open, so the run time library just uses the pointer that
	  the startup code created.  Same with DOS, although we don't
	  use that here. }

    GfxBase := OpenLibrary("graphics.library", 0);
    if GfxBase <> nil then begin
	if OpenMathTrans then begin
	    if OpenTheWindow() then begin
		DoCircle(w^.RPort, 320, 105, 92);
		m := WaitPort(w^.UserPort);
		Forbid;
		repeat
		    m := GetMsg(w^.UserPort);
		until m = nil;
		CloseWindow(w);
		Permit;
	    end else
		writeln('Could not open the window');
	    CloseMathTrans;
	end else
	    Writeln('Could not open math library');
	CloseLibrary(GfxBase);
    end else
	Writeln('Could not open graphics.library');
end.
