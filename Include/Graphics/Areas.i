{
	Areas.i for PCQ Pascal

	Procedures and functions for using the area routines in the
	graphics.library.  Note that you will need to open the
	library and set GfxBase to an appropriate value.
}

{$I "Include:Graphics/RastPort.i"}

Function AreaCircle(rp : RastPortPtr; cx, cy, radius : Short) : Integer;
    External;

Function AreaDraw(rp : RastPortPtr; x, y : Short) : Integer;
    External;

Function AreaEllipse(rp : RastPortPtr; cx, cy, a, b : Short) : Integer;
    External;

Function AreaEnd(rp : RastPortPtr) : Integer;
    External;

Function AreaMove(rp : RastPortPtr; x, y : Short) : Integer;
    External;

Procedure InitArea(areaInfo : AreaInfoPtr;
			buffer : Address;
			maxVectors : Short);
    External;

