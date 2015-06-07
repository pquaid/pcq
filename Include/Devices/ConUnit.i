{
	ConUnit.i for PCQ Pascal

	Console device unit definitions
}

{$I "Include:Exec/Ports.i"}
{$I "Include:Devices/Console.i"}
{$I "Include:Devices/Keymap.i"}
{$I "Include:Devices/InputEvent.i"}


const

    PMB_ASM	= M_LNM + 1;	{ internal storage bit for AS flag }
    PMB_AWM	= PMB_ASM + 1;	{ internal storage bit for AW flag }
    MAXTABS	= 80;


type

    ConUnit = record
	cu_MP	: MsgPort;
	{ ---- read only variables }
	cu_Window	: Address;	{ (WindowPtr) intuition window bound to this unit }
	cu_XCP		: Short;	{ character position }
	cu_YCP		: Short;
	cu_XMax		: Short;	{ max character position }
	cu_YMax		: Short;
	cu_XRSize	: Short;	{ character raster size }
	cu_YRSize	: Short;
	cu_XROrigin	: Short;	{ raster origin }
	cu_YROrigin	: Short;
	cu_XRExtant	: Short;	{ raster maxima }
	cu_YRExtant	: Short;
	cu_XMinShrink	: Short;	{ smallest area intact from resize process }
	cu_YMinShrink	: Short;
	cu_XCCP		: Short;	{ cursor position }
	cu_YCCP		: Short;

   { ---- read/write variables (writes must must be protected) }
   { ---- storage for AskKeyMap and SetKeyMap }

	cu_KeyMapStruct	: KeyMap;

   { ---- tab stops }

	cu_TabStops	: Array [0..MAXTABS-1] of Short;
				{ 0 at start, -1 at end of list }

   { ---- console rastport attributes }

	cu_Mask		: Byte;
	cu_FgPen	: Byte;
	cu_BgPen	: Byte;
	cu_AOLPen	: Byte;
	cu_DrawMode	: Byte;
	cu_AreaPtSz	: Byte;
	cu_AreaPtrn	: Address;	{ cursor area pattern }
	cu_Minterms	: Array [0..7] of Byte;	{ console minterms }
	cu_Font		: Address;	{ (TextFontPtr) }
	cu_AlgoStyle	: Byte;
	cu_TxFlags	: Byte;
	cu_TxHeight	: Short;
	cu_TxWidth	: Short;
	cu_TxBaseline	: Short;
	cu_TxSpacing	: Short;

   { ---- console MODES and RAW EVENTS switches }

	cu_Modes	: Array [0..(PMB_AWM+7) div 8 - 1] of Byte;
				{ one bit per mode }
	cu_RawEvents	: Array [0..(IECLASS_MAX+7) div 8 - 1] of Byte;
    end;
    ConUnitPtr = ^ConUnit;

