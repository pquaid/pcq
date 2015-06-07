{
	RastPort.i for PCQ Pascal
}

{$I "Include:Graphics/GFX.i"}

type

    AreaInfo = record
	VctrTbl	: Address;	{ ptr to start of vector table }
	VctrPtr	: Address;	{ ptr to current vertex }
	FlagTbl	: Address;	{ ptr to start of vector flag table }
	FlagPtr	: Address;	{ ptrs to areafill flags }
	Count	: Short;	{ number of vertices in list }
	MaxCount : Short;	{ AreaMove/Draw will not allow Count>MaxCount}
	FirstX,
	FirstY	: Short;	{ first point for this polygon }
    end;
    AreaInfoPtr = ^AreaInfo;

    TmpRas = record
	RasPtr	: Address;
	Size	: Integer;
    end;
    TmpRasPtr = ^TmpRas;

{ unoptimized for 32bit alignment of pointers }
    GelsInfo = record
	sprRsrvd	: Byte;	{ flag of which sprites to reserve from
				  vsprite system }
	Flags	: Byte;	      { system use }
	gelHead,
	gelTail	: Address; { (VSpritePtr) dummy vSprites for list management}

    { pointer to array of 8 WORDS for sprite available lines }

	nextLine : Address;

    { pointer to array of 8 pointers for color-last-assigned to vSprites }

	lastColor : Address;
	collHandler : Address;	{ (collTablePtr) addresses of collision routines }
	leftmost,
	rightmost,
	topmost,
	bottommost	: Short;
	firstBlissObj,
	lastBlissObj	: Address;    { system use only }
    end;
    GelsInfoPtr = ^GelsInfo;

    RastPort = record
	Layer		: Address;	{ LayerPtr }
	BitMap		: Address;	{ BitMapPtr }
	AreaPtrn 	: Address;	{ ptr to areafill pattern }
	TmpRas		: TmpRasPtr;
	AreaInfo 	: AreaInfoPtr;
	GelsInfo 	: GelsInfoPtr;
	Mask		: Byte;		{ write mask for this raster }
	FgPen		: Byte;		{ foreground pen for this raster }
	BgPen		: Byte;		{ background pen	 }
	AOlPen		: Byte;		{ areafill outline pen }
	DrawMode	: Byte; { drawing mode for fill, lines, and text }
	AreaPtSz 	: Byte;		{ 2^n words for areafill pattern }
	linpatcnt 	: Byte;	{ current line drawing pattern preshift }
	dummy		: Byte;
	Flags		: Short;	{ miscellaneous control bits }
	LinePtrn 	: Short;	{ 16 bits for textured lines }
	cp_x,
	cp_y		: Short;	{ current pen position }
	minterms	: Array [0..7] of Byte;
	PenWidth	: Short;
	PenHeight	: Short;
	Font		: Address;	{ (TextFontPtr) current font address }
	AlgoStyle	: Byte;		{ the algorithmically generated style }
	TxFlags		: Byte;		{ text specific flags }
	TxHeight	: Short;	{ text height }
	TxWidth		: Short;	{ text nominal width }
	TxBaseline	: Short;	{ text baseline }
	TxSpacing 	: Short;	{ text spacing (per character) }
	RP_User		: Address;
	longreserved	: Array [0..1] of Integer;
	wordreserved	: Array [0..6] of Short;	{ used to be a node }
	reserved	: Array [0..7] of Byte;		{ for future use }
    end;
    RastPortPtr = ^RastPort;

const

{ drawing modes }

    JAM1	= 0;	{ jam 1 color into raster }
    JAM2	= 1;	{ jam 2 colors into raster }
    COMPLEMENT	= 2;	{ XOR bits into raster }
    INVERSVID	= 4;	{ inverse video for drawing modes }

{ these are the flag bits for RastPort flags }

    FRST_DOT	= $01;	{ draw the first dot of this line ? }
    ONE_DOT	= $02;	{ use one dot mode for drawing lines }
    DBUFFER	= $04;	{ flag set when RastPorts are double-buffered }

	     { only used for bobs }

    AREAOUTLINE	= $08;	{ used by areafiller }
    NOCROSSFILL	= $20;	{ areafills have no crossovers }

{ there is only one style of clipping: raster clipping }
{ this preserves the continuity of jaggies regardless of clip window }
{ When drawing into a RastPort, if the ptr to ClipRect is nil then there }
{ is no clipping done, this is dangerous but useful for speed }

Function AllocRaster(width,height : Short) : PLANEPTR;
    External;

Procedure FreeRaster(p : PLANEPTR; width, height : Short);
    External;

Procedure InitRastPort(rp : RastPortPtr);
    External;

Procedure InitTmpRas(tmpras : TmpRasPtr; buffer : Address; size : Integer);
    External;

Procedure ScrollRaster(rp : RastPortPtr; dx, dy,
			xmin, ymin, xmax, ymax : Short);
    External;

Procedure SetRast(rp : RastPortPtr; pen : Byte);
    External;

