Program Bezier;

{  This program draws Bezier curves in the slow, simple, recursive
   way.  When it first runs, you enter points in the window by
   clicking the left mouse button.  After you double click on the
   last point, the program begins drawing the curve.

   Since this is a highly recursive program, it's speed decreases
   dramatically as you enter more points.  It can handle six or
   seven points with reasonable speed, but if you enter ten you
   might want to go see a movie while it draws.  It also uses
   more stack space as you enter more points, but I hasn't blown
   a 4k stack yet.
}

{$I "Include:Exec/Interrupts.i" for Forbid and Permit }
{$I "Include:Exec/Libraries.i" for Open and Close }
{$I "Include:Exec/Ports.i" for the Message stuff }
{$I "Include:Intuition/Intuition.i" for window & screen structures and functions }
{$I "Include:Graphics/Pens.i" for drawing stuff }
{$I "Include:Graphics/Text.i" for GText }
{$I "Include:Graphics/Graphics.i"}

type
    PointRec = Record
        X, Y : Short;
    end;
    
Const
    w  : WindowPtr = Nil;
    s  : Address   = Nil;

{  The following definitions mean that the start-up code will
   not create an output window for this program if it is run
   from the Workbench.  Therefore this program should NOT use
   ReadLn and WriteLn. }

    StdInName : Address = Nil;
    StdOutName: Address = Nil;
Var
    m  : MessagePtr;
    rp : RastPortPtr;

    PointCount : Short;
    Points : Array [1..15] of PointRec;

    t, tprime : Real;

    LastX, LastY : Short;

Procedure CleanUpAndDie;
begin
    if w <> Nil then begin
	Forbid;
	repeat until GetMsg(w^.UserPort) = Nil;
	CloseWindow(w);
	Permit;
    end;
    if s <> Nil then
	CloseScreen(s);
    CloseLibrary(GfxBase);
    Exit(0);
end;

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
	DefaultTitle := "Simple Bezier Curves";
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
	LeftEdge := 0;
	TopEdge := 11;
	Width := 640;
	Height := 189;

	DetailPen := -1;
	BlockPen  := -1;
	IDCMPFlags := CLOSEWINDOW_f;
	Flags := WINDOWDRAG + WINDOWDEPTH + REPORTMOUSE_f +
		 WINDOWCLOSE + SMART_REFRESH + ACTIVATE;
	FirstGadget := nil;
	CheckMark := nil;
	Title := "Close the Window to Quit";
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

Procedure DrawLine;
begin
    Move(rp, Points[PointCount].X, Points[PointCount].Y);
    Draw(rp, LastX, LastY);
end;

Procedure GetPoints;
var
    LastSeconds,
    LastMicros	: Integer;
    IM : IntuiMessagePtr;
    StoreMsg : IntuiMessage;
    Leave : Boolean;
    OutOfBounds : Boolean;
    BorderLeft, BorderRight,
    BorderTop, BorderBottom : Short;

    Procedure AddPoint;
    begin
	Inc(PointCount);
	with Points[PointCount] do begin
	    X := StoreMsg.MouseX;
	    Y := StoreMsg.MouseY;
	end;
	with StoreMsg do begin
	    LastX := MouseX;
	    LastY := MouseY;
	    LastSeconds := Seconds;
	    LastMicros := Micros;
	end;
	SetAPen(rp, 2);
	SetDrMd(rp, JAM1);
	DrawEllipse(rp, LastX, LastY, 5, 3);
	SetAPen(rp, 3);
	SetDrMd(rp, COMPLEMENT);
	DrawLine;
    end;

    Function CheckForExit : Boolean;
    {   This function determines whether the user wanted to stop
	entering points.  I added the position tests because my
	doubleclick time is too long, and I was too lazy to dig
	out Preferences to change it. }
    begin
	with StoreMsg do
	    CheckForExit := DoubleClick(LastSeconds, LastMicros,
					Seconds, Micros) and
			    (Abs(MouseX - Points[PointCount].X) < 5) and
			    (Abs(MouseY - Points[PointCount].Y) < 3);
    end;

    Procedure ClearIt;
    {  This just clears the screen when you enter your first point }
    begin
	SetDrMd(rp, JAM1);
	SetAPen(rp, 0);
	RectFill(rp, BorderLeft, BorderTop,
		     BorderRight, BorderBottom);
	SetDrMd(rp, COMPLEMENT);
	SetAPen(rp, 3);
    end;

begin
    Move(rp, 252, 20);
    GText(rp, "Enter points by pressing the left mouse button", 46);
    Move(rp, 252, 30);
    GText(rp, "Double click on the last point to begin drawing", 47);
    ModifyIDCMP(w, CLOSEWINDOW_f + MOUSEBUTTONS_f + MOUSEMOVE_f);
    SetDrMd(rp, COMPLEMENT);
    PointCount := 0;
    Leave := False;
    OutOfBounds := False;
    BorderLeft := w^.BorderLeft;
    BorderRight := 639 - w^.BorderRight;
    BorderTop := w^.BorderTop;
    BorderBottom := 189 - w^.BorderBottom;
    repeat
        IM := IntuiMessagePtr(WaitPort(w^.UserPort));
        IM := IntuiMessagePtr(GetMsg(w^.UserPort));
        StoreMsg := IM^;
        ReplyMsg(MessagePtr(IM));
        case StoreMsg.Class of
           MOUSEMOVE_f : if PointCount > 0 then begin
			     if not OutOfBounds then
				 DrawLine;
           		     LastX := StoreMsg.MouseX;
           		     LastY := StoreMsg.MouseY;
			     if (LastX > BorderLeft) and
				(LastX < BorderRight) and
				(LastY > BorderTop) and
				(LastY < BorderBottom) then begin
				 DrawLine;
				 OutOfBounds := False;
			     end else
				 OutOfBounds := True;
           		 end;
           MOUSEBUTTONS_f : if StoreMsg.Code = SELECTUP then begin
           			if PointCount > 0 then
				    Leave := CheckForExit
				else
				    ClearIt;
           			if (not Leave) and (not OutOfBounds) then
				    AddPoint;
           		    end;
           CLOSEWINDOW_f : CleanUpAndDie;
        end;
    until Leave or (PointCount > 14);
    if not Leave then
        DrawLine;
    ModifyIDCMP(w, CLOSEWINDOW_f);
    SetDrMd(rp, JAM1);
    SetAPen(rp, 1);
end;

{
   These two function just implement the de Casteljau
algorithm, which looks like:

         r            r-1         r-1
	B  = (1-t) * B    +  t * B
         i            i           i+1

   Where r and i are meant to be subscripts and superscripts.  R is
   a level number, where zero represents the data points and
   (the number of points - 1) represents the curve points.  I is
   the point numbers, starting from zero normally but in this
   program starting from 1.  t is the familiar 'parameter' running
   from 0 to 1 in arbitrary increments.
}

Function BezierX(r, i : Short) : Real;
begin
    if r = 0 then
	BezierX := Float(Points[i].X)
    else
	BezierX := tprime * BezierX(Pred(r), i) + t * BezierX(Pred(r), Succ(i));
end;

Function BezierY(r, i : Short) : Real;
begin
    if r = 0 then
	BezierY := Float(Points[i].Y)
    else
	BezierY := tprime * BezierY(Pred(r), i) + t * BezierY(Pred(r), Succ(i));
end;

Procedure DrawBezier;
var
    increment : Real;
begin
    increment := 0.01; { This could be a function of PointCount }
    t := 0.0;
    tprime := 1.0;
    Move(rp, Trunc(BezierX(Pred(PointCount), 1)),
	     Trunc(BezierY(Pred(PointCount), 1)));
    t := t + increment;
    tprime := 1.0 - t;
    while t <= 1.0 do begin
	Draw(rp, Trunc(BezierX(Pred(PointCount), 1)),
		 Trunc(BezierY(Pred(PointCount), 1)));
	t := t + increment;
	tprime := 1.0 - t;
	if GetMsg(w^.UserPort) <> Nil then
	    CleanUpAndDie;
    end;
    t := 1.0;
    tprime := 0.0;
    Draw(rp, Trunc(BezierX(Pred(PointCount), 1)),
	     Trunc(BezierY(Pred(PointCount), 1)));
end;

begin
    GfxBase := OpenLibrary("graphics.library", 0);
    if GfxBase <> nil then begin
	if OpenTheScreen() then begin
	    if OpenTheWindow() then begin
	    	rp := w^.RPort;
	    	GetPoints;
	    	DrawBezier;
		m := WaitPort(w^.UserPort);
		Forbid;
		repeat
		    m := GetMsg(w^.UserPort);
		until m = nil;
		CloseWindow(w);
		Permit;
	    end;
	    CloseScreen(s);
	end;
	CloseLibrary(GfxBase);
    end;
end.
