{
    View.i for PCQ Pascal
}


{$I "Include:Graphics/GFX.i"}
{$I "Include:Graphics/Copper.i"}

type

    ColorMap = record
	Flags	: Byte;
	CType	: Byte;		{ This is "Type" in C includes }
	Count	: Short;
	ColorTable	: Address;
    end;
    ColorMapPtr = ^ColorMap;

{ if Type = 0 then ColorTable is a table of UWORDS xRGB }

    RasInfo = record	{ used by callers to and InitDspC() }
	Next	: ^RasInfo;	{ used for dualpf }
	BitMap	: BitMapPtr;
	RxOffset,
	RyOffset : Short;	{ scroll offsets in this BitMap }
    end;
    RasInfoPtr = ^RasInfo;

    ViewPort = record
	Next	: ^ViewPort;
	ColorMap : ColorMapPtr;	{ table of colors for this viewport }
			  { if this is nil, MakeVPort assumes default values }
	DspIns	: CopListPtr;	{ user by MakeView() }
	SprIns	: CopListPtr;	{ used by sprite stuff }
	ClrIns	: CopListPtr;	{ used by sprite stuff }
	UCopIns	: UCopListPtr;	{ User copper list }
	DWidth,
	DHeight	: Short;
	DxOffset,
	DyOffset : Short;
	Modes	: Short;
	SpritePriorities : Byte;	{ used by makevp }
	reserved : Byte;
	RasInfo	: RasInfoPtr;
    end;
    ViewPortPtr = ^ViewPort;


    View = record
	ViewPort	: ViewPortPtr;
	LOFCprList	: cprlistptr;	{ used for interlaced and noninterlaced }
	SHFCprList	: cprlistptr;	{ only used during interlace }
	DyOffset,
	DxOffset	: Short;	{ for complete View positioning }
				{ offsets are +- adjustments to standard #s }
	Modes		: Short;	{ such as INTERLACE, GENLOC }
    end;
    ViewPtr = ^View;


{ defines used for Modes in IVPargs }

const

    PFBA	= $40;
    DUALPF	= $400;
    HIRES	= $8000;
    LACE	= 4;
    HAM		= $800;
    SPRITES	= $4000;	{ reuse one of plane ctr bits }
    VP_HIDE	= $2000;	{ reuse another plane crt bit }
    GENLOCK_AUDIO = $100;
    GENLOCK_VIDEO = 2;
    EXTRA_HALFBRITE = $80;

Procedure FreeColorMap(colormap : ColorMapPtr);
    External;

Procedure FreeVPortCopLists(vp : ViewPortPtr);
    External;

Function GetColorMap(entries : Integer) : ColorMapPtr;
    External;

Function GetRGB4(colomap : ColorMapPtr; entry : Integer) : Integer;
    External;

Procedure InitView(view : ViewPtr);
    External;

Procedure InitVPort(vp : ViewPortPtr);
    External;

Procedure LoadRGB4(vp : ViewPortPtr; colors : Address; count : Short);
    External;

Procedure LoadView(view : ViewPtr);
    External;

Procedure MakeVPort(view : ViewPtr; viewport : ViewPortPtr);
    External;

Procedure MrgCop(view : ViewPtr);
    External;

Procedure ScrollVPort(vp : ViewPortPtr);
    External;

Procedure SetRGB4(vp : ViewPortPtr; n : Short; r, g, b : Byte);
    External;

Procedure SetRGB4CM(cm : ColorMapPtr; n : Short; r, g, b : Byte);
    External;

Function VBeamPos : Integer;
    External;

Procedure WaitBOVP(vp : ViewPortPtr);
    External;

Procedure WaitTOF;
    External;

