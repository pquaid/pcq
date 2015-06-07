Program MapMaker;

{$I "Include:Exec/Libraries.i"}
{$I "Include:Exec/Interrupts.i"}
{$I "Include:Graphics/Graphics.i"}
{$I "Include:Graphics/Pens.i"}
{$I "Include:Intuition/Intuition.i"}
{$I "Include:Libraries/DOS.i"}
{$I "Include:Graphics/View.i"}
{$I "Include:Utils/Random.i"}

{
    This program just draws a blocky map from straight overhead,
then repeatedly splits each block into four parts and adjusts the
elevation of each of the parts until it gets down to one pixel per
block.  It ends up looking something like a terrain map.  It's kind
of a fractal thing, but not too much.  Some program a long time ago
inspired this, but I apologize for forgetting which one.  As I
recall, that program was derived from Chris Gray's sc.
    Once upon a time I was thinking about writing an overblown
strategic conquest game, and this was the first stab at a map
maker.  The maps it produces look nifty, but have no sense of
geology so they're really not too useful for a game.
    When the map is finished, press the left button inside the
window somewhere and the program will go away.
}

const
    MinX = 0;
    MaxX = 320;
    MinY = 0;
    MaxY = 200;

type
    MapArray = array [MinX .. MaxX - 1, MinY .. MaxY - 1] of Byte;

VAR
    average,x,y,
    nextx,nexty,count,
    skip,level	  : Short;
    rp            : RastPortPtr;
    vp            : Address;
    s             : Address;
    w             : WindowPtr;
    Seed	  : Integer;
    m             : MessagePtr;
    Map           : MapArray;
    Quit	  : Boolean;


Function FixX(x : short): short;
begin
    if x < 0 then
	FixX := x + MaxX
    else if x >= MaxX then
	FixX := x mod MaxX
    else
	FixX := x;
end;

Function FixY(y : short) : short;
begin
    if x < 0 then
	FixY := y + MaxY
    else if x >= MaxY then
	FixY := y mod MaxY
    else
	FixY := y;
end;

Procedure DrawMap;
begin
    if skip = 1 then begin
	for x := MinX to MaxX - 1 do begin
	    for y := MinY to MaxY - 1 DO begin
		if Map[x,y] < 100 then begin
		    SetAPen(rp, 0);
		    WritePixel(rp, x, y)
		end else begin
		    average := (Map[x,y] - 100) DIV 6 + 1;
		    if average > 15 then
			average := 15;
		    SetAPen(rp, average);
		    WritePixel(rp, x, y)
		end
	    end
	end
   end else begin
	x := MinX;
	while x < MaxX do begin
	    y := MinY;
	    while y < MaxY do begin
		if Map[x,y] < 100 then begin
		    SetAPen(rp, 0);
		    RectFill(rp,x,y,x + skip - 1,y + skip - 1)
		end else begin
		    average := (Map[x,y] - 100) DIV 6 + 1;
		    if average > 15 then
			average := 15;
		    SetAPen(rp,average);
		    RectFill(rp,x,y,x + skip - 1,y + skip - 1);
		end;
		y := y + skip;
	    end;
	    x := x + skip;
	end;
    end;
end;

Function OpenTheScreen() : Boolean;
var
    ns : NewScreenPtr;
begin
    new(ns);
    with ns^ do begin
	LeftEdge := 0;
	TopEdge  := 0;
	Width    := 320;
	Height   := 200;
	Depth    := 5;
	DetailPen := 3;
	BlockPen  := 2;
	ViewModes := 0;
	SType     := CUSTOMSCREEN_f;
	Font      := nil;
	DefaultTitle := nil;
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
	LeftEdge := MinX;
	TopEdge := MinY;
	Width := MaxX;
	Height := MaxY;

	DetailPen := -1;
	BlockPen  := -1;
	IDCMPFlags := MOUSEBUTTONS_f;
	Flags := BORDERLESS + BACKDROP + SMART_REFRESH + ACTIVATE;
	FirstGadget := nil;
	CheckMark := nil;
	Title := nil;
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

Function Min(x,y : Short) : Short;
begin
    if x < y then
	Min := x
    else
	Min := y;
end;

Function Max(x,y : Short) : Short;
begin
    if x > y then
	Max := x
    else
	Max := y;
end;


Function Height(x,y : Short) : Short;
begin
    Height := Map[x,y] div 32;
end;

Procedure ChangeDelta(var d : Short);
begin
    case RangeRandom(100) of
      51..75   : if d < 1 then
		     Inc(d);
      76..100  : if d > -1 then
		     Dec(d);
    end; 
end;

Procedure MakeRivers;
var
    i    : Short;
    x,y,
    dx,dy  : Short;
    OK   : Boolean;
    LastHeight : Short;
    Count      : Short;
    cx,cy      : Short;
    Search     : Short;
    CheckHeight : Short;
begin
    SetAPen(rp, 16);

    for cx := 0 to 319 do begin
	for cy := 0 to 199 do begin
	    if (Map[cx,cy] > 153) and (Map[cx,cy] < 162) and 
	       (RangeRandom(100) < 3) then begin

		x := cx;
		y := cy;

		dx := 0;
		dy := 0;
		while (dx = 0) and (dy = 0) do begin
		    dx := RangeRandom(2) - 1;
		    dy := RangeRandom(2) - 1;
		end;

		OK := True;

		Count := 0;
		while OK do begin
		    LastHeight := Map[x,y]; { Height(x,y); }
		    Map[x,y] := 0;
		    WritePixel(rp, x, y);

		    CheckHeight := -6;
		    Search := 0;
		    repeat
		        repeat
			    ChangeDelta(dx);
			    ChangeDelta(dy);
		        until (dx <> 0) or (dy <> 0);
			Inc(Search);
			if (Map[FixX(x + dx), FixY(y + dy)] > 0) and
                         {  (Height(FixX(x + dx), FixY(y + dy)) < CheckHeight) then begin }
			   (Map[FixX(x + dx), FixY(y + dy)] < (LastHeight + CheckHeight)) then begin
			    x := FixX(x + dx);
			    y := FixY(y + dy);
			    Search := 0;
			end else if Search > 200 then begin
			    if CheckHeight < 6 then begin
				Inc(CheckHeight,2);
				Search := 1;
			    end else begin
				Search := 0;
				OK := False;
			    end;
			end;
		    until Search = 0;

		    Inc(Count);
		    if Count > 150 then
			OK := False;
		    if Map[x,y] < 100 then
			OK := False;
		end;
	    end;
	end;
    end;
end;

Procedure MakeMap;
begin

    rp:= w^.RPort;
    vp:= ViewPortAddress(w);

    SetRGB4(vp, 0, 0, 0, 12); { Ocean Blue }
    SetRGB4(vp, 1, 1, 1, 0);
    SetRGB4(vp, 2, 0, 3, 0);
    SetRGB4(vp, 3, 0, 4, 0); { Dark Green }
    SetRGB4(vp, 4, 0, 5, 0);
    SetRGB4(vp, 5, 1, 6, 0);
    SetRGB4(vp, 6, 2, 8, 0); { Medium Green }
    SetRGB4(vp, 7, 4, 10, 0);
    SetRGB4(vp, 8, 6, 10, 0);
    SetRGB4(vp, 9, 9, 9, 0); { Brown }
    SetRGB4(vp, 10, 8, 8, 0);
    SetRGB4(vp, 11, 7, 7, 0); { Dark Brown }
    SetRGB4(vp, 12, 10, 10, 0); { Dark Grey }
    SetRGB4(vp, 13, 10, 10, 10);
    SetRGB4(vp, 14, 12, 12, 12);
    SetRGB4(vp, 15, 14, 14, 15); { White }
    SetRGB4(vp, 16, 0, 0, 10);   { River blue }

    SelfSeed; { Seed the Random Number Generator }

    level := 7;
    skip  := 16;

    y := MinY;
    while y < MaxY do begin
	x := MinX;
	while x < MaxX do begin
	    Map[x,y] := RangeRandom(220);
	    x := x + skip;
	end;
	y := y + skip;
    end;

    DrawMap;

    for level := 2 to 5 do begin
	skip := skip DIV 2;
	y := MinY;
	while y < MaxY do begin
	    if (y MOD (2*skip)) = 0 then
		nexty := skip * 2
	    else
		nexty:=skip;
	    x := MinX;
	    while x < MaxX do begin
		if (x MOD (2*skip)) = 0 then
		    nextx := skip * 2
		else
		    nextx := skip;
		if (nextx = skip * 2) AND (nexty = skip * 2) then begin
		    average := Map[x,y] * 5;
		    count := 9;
		end else begin
		    average := 0;
		    count := 4;
		end;
		if (nextx = skip * 2) then begin
			average := average + Map[x,FixY(y - skip)];
			average := average + Map[x,FixY(y + nexty)];
			count := count + 2;
		end;
		if (nexty = skip * 2) then begin
			average := average + Map[FixX(x - skip),y];
			average := average + Map[FixX(x + nextx),y];
			count := count + 2;
		end;
		average := average + Map[FixX(x-skip),FixY(y-skip)]
				   + Map[FixX(x-nextx),FixY(y+nexty)]
				   + Map[FixX(x+skip),FixY(y-skip)]
				   + Map[FixX(x+nextx),FixY(y+nexty)];
		average := (average DIV count) +
			    (RangeRandom(4) - 2) * (9 - level);
		case Average of
		  150..255 : Average := Average + 2;
		  100..149 : Inc(Average);
		else
		    Average := Average - 3;
		end;
		if average < 0 then
		    average := 0;
		if average > 220 then
		    average := 220;
		Map[x,y] := average;

		x := x + skip;
	    end;
	    m := GetMsg(w^.UserPort);
	    if m <> Nil then begin
		Quit := True;
		return;
	    end;
	    y := y + skip;
	end;
	DrawMap;
    end;
    MakeRivers;
end;

begin
    GfxBase := OpenLibrary("graphics.library", 0);
    if GfxBase <> nil then begin
	if OpenTheScreen() then begin
	    if OpenTheWindow() then begin
		Quit := False;
		ShowTitle(s, false);
		MakeMap;
		if not Quit then
		    m := WaitPort(w^.UserPort);
		Forbid;
		repeat
		    m := GetMsg(w^.UserPort);
		until m = nil;
		CloseWindow(w);
		Permit;
	    end else
		writeln('Could not open the window.');
	    CloseScreen(s);
	end else
	    writeln('Could not open the screen.');
	CloseLibrary(GfxBase);
    end else
	writeln('Could not open graphics.library');
end.
