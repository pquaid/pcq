External;

{
	DoubleBuffer.p

	These routines provide a very simple double buffer
	mechanism, mainly by being a bit inflexible with the
	choice of screens and windows.

	The first thing to do is to set up a NewScreen structure,
	just like you would do for OpenScreen.  This can be any
	sort of screen.  Then call OpenDoubleBuffer, which will
	return a pointer to a full-screen, borderless backdrop
	window, or Nil if something went wrong.

	If you write into the window's RastPort, it won't be
	visible until you call SwapBuffers.  By the way, you
	can always write into the same RastPort - you don't
	need to reinitialize after SwapBuffers.  All the
	buffer swapping takes place at the level of BitMaps,
	so it's transparent to RastPorts.

	When you have finished, call CloseDoubleBuffer.  If you
	close the window and screen seperately it might crash
	(I'm not sure), but you'll definitely lose memory.

	One last point: GfxBase must be open before you call
			OpenDoubleBuffer
}

{$I "Include:Intuition/Intuition.i"}
{$I "Include:Exec/Memory.i"}

{
    OpenDoubleBuffer opens the Screen described in "ns" without
    modification, then opens a full screen, borderless backdrop
    window on it.  That way the window and screen normally share
    the same BitMap.

    Assuming all that went OK, it allocates an extra BitMap record
    and the Rasters to go along with it.  Then it points the
    Window's BitMap, in its RastPort, at the extra bitmap.
}

Function OpenDoubleBuffer(ns : NewScreenPtr) : WindowPtr;
var
    s : ScreenPtr;
    w : WindowPtr;
    bm : BitMapPtr;
    i,j : Integer;
    nw : NewWindow;
    rp : RastPortPtr;
begin
    s := OpenScreen(ns);
    if s = Nil then
	OpenDoubleBuffer := Nil;

    ShowTitle(s, False);

    with s^ do begin
	nw.LeftEdge := LeftEdge;
	nw.TopEdge  := TopEdge;
	nw.Width    := Width;
	nw.Height   := Height;
    end;
    with nw do begin
	DetailPen := -1;
	BlockPen  := -1;
	IDCMPFlags := 0;
	Flags     := BACKDROP + BORDERLESS + ACTIVATE;
	FirstGadget := Nil;
	CheckMark := Nil;
	Title := "";
	Screen := s;
	BitMap := Nil;
	WType := CUSTOMSCREEN_f;
    end;
    w := OpenWindow(Adr(nw));
    if w = Nil then begin
	CloseScreen(s);
	OpenDoubleBuffer := Nil;
    end;

    bm := AllocMem(SizeOf(BitMap), MEMF_PUBLIC);
    if bm = Nil then begin
	CloseWindow(w);
	CloseScreen(s);
	OpenDoubleBuffer := Nil;
    end;

    bm^ := s^.SBitMap;

    with bm^ do
	for i := 0 to Pred(Depth) do begin
	    Planes[i] := AllocRaster(s^.Width, s^.Height);
	    if Planes[i] = Nil then begin
		if i > 0 then
		    for j := 0 to Pred(i) do
			FreeRaster(Planes[j], s^.Width, s^.Height);
		CloseWindow(w);
		CloseScreen(s);
		OpenDoubleBuffer := Nil;
	    end;
	end;

    rp := w^.RPort;
    rp^.bitMap := bm;

    OpenDoubleBuffer := w;
end;

{
    SwapBuffers swaps the PlanePtrs in the Window's and Screen's
    BitMap structure's, then calls ScrollVPort on the Screen's
    ViewPort to get everything going.
}

Procedure SwapBuffers(w : WindowPtr);
var
    s : ScreenPtr;
    bm1,
    bm2 : BitMapPtr;
    rp : RastPortPtr;
    Temp : Array [0..7] of PlanePtr;
begin
    s := w^.WScreen;
    rp := w^.RPort;
    bm1 := rp^.bitMap;
    bm2 := Adr(s^.SBitMap);
    Temp := bm2^.Planes;
    bm2^.Planes := bm1^.Planes;
    bm1^.Planes := Temp;
    ScrollVPort(Adr(s^.SViewPort));
end;

{
    CloseDoubleBuffer resets the Window's BitMap to the Screen's
    BitMap (just in case), closes the Window and Screen, then
    deallocates the extra BitMap structure and Rasters.
}

Procedure CloseDoubleBuffer(w : WindowPtr);
var
    s : ScreenPtr;
    bm : BitMapPtr;
    i  : Integer;
    rp : RastPortPtr;
begin
    s := w^.WScreen;
    rp := w^.RPort;
    bm := rp^.bitMap;
    rp^.bitMap := Adr(s^.SBitMap);
    with bm^ do
	for i := 0 to Pred(Depth) do
	    FreeRaster(Planes[i], s^.Width, s^.Height);
    FreeMem(bm, SizeOf(BitMap));
    CloseWindow(w);
    CloseScreen(s);
end;
