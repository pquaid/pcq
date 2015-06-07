{
	GFX.i for PCQ Pascal

	General graphics include file for application programs 
}

const

    BITSET	= $8000;
    BITCLR	= 0;

type

    Rectangle = record
	MinX,MinY	: Short;
	MaxX,MaxY	: Short;
    end;
    RectanglePtr = ^Rectangle;

    Point = record
	x,y	: Short;
    end;
    PointPtr = ^Point;

    PLANEPTR = Address;

    BitMap = record
	BytesPerRow	: Short;
	Rows		: Short;
	Flags		: Byte;
	Depth		: Byte;
	pad		: Short;
	Planes		: Array [0..7] of PLANEPTR;
    end;
    BitMapPtr = ^BitMap;

Procedure InitBitMap(bm : BitMapPtr; depth : Byte; width, height : Short);
    External;

Function RASSIZE(w,h : Short) : Integer;   { not a graphics.library call }
    External;

