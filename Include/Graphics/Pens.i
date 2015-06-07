{
	Pens.i of PCQ Pascal

	This is not a standard Amiga include file, but since the
	various drawing routines don't seem to fit in any other
	include file, this one was created to declare them.
}


Procedure Draw(rp : Address; x, y : Short);
    External;

Procedure DrawCircle(rp : Address; cx, cy, radius : Short);
    External;

Procedure DrawEllipse(rp : Address; cx, cy, a, b : Short);
    External;

Procedure Flood(rp : Address; mode : Integer; x, y : Short);
    External;

Procedure Move(rp : Address; x, y : Short);
    External;

Procedure PolyDraw(rp : Address; count : Short; ary : Address);
    External;

Function ReadPixel(rp : Address; x, y : Short) : Integer;
    External;

Procedure RectFill(rp : Address; xmin, ymin, xmax, ymax : Short);
    External;

Procedure SetAPen(rp : Address; pen : Byte);
    External;

Procedure SetBPen(rp : Address; pen : Byte);
    External;

Procedure SetDrMd(rp : Address; mode : Byte);
    External;

Procedure WritePixel(rp : Address; x, y : Short);
    External;

