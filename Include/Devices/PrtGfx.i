{
	PrtGfx.i for PCQ Pascal
}

Const

    PCMYELLOW		= 0;		{ byte index for yellow }
    PCMMAGENTA		= 1;		{ byte index for magenta }
    PCMCYAN		= 2;		{ byte index for cyan }
    PCMBLACK		= 3;		{ byte index for black }
    PCMBLUE		= PCMYELLOW;	{ byte index for blue }
    PCMGREEN		= PCMMAGENTA;	{ byte index for green }
    PCMRED		= PCMCYAN;	{ byte index for red }
    PCMWHITE		= PCMBLACK;	{ byte index for white }

Type

    colorEntry = record
	colorLong	: Integer;	{ quick access to all of YMCB }
	colorByte	: Array [0..3] of Byte;	{ 1 entry for each of YMCB }
	colorSByte	: Array [0..3] of Byte;	{ ditto (except signed) }
    end;
    colorEntryPtr = ^colorEntry;


    PrtInfo = record { printer info }
	pi_render	: Address;	{ PRIVATE - DO NOT USE! }
	pi_rp		: Address;	{ PRIVATE - DO NOT USE! (RastPortPtr)}
	pi_temprp	: Address;	{ PRIVATE - DO NOT USE! (RastPortPtr)}
	pi_RowBuf	: Address;	{ PRIVATE - DO NOT USE! }
	pi_HamBuf	: Address;	{ PRIVATE - DO NOT USE! }
	pi_ColorMap	: colorEntryPtr; { PRIVATE - DO NOT USE! }
	pi_ColorInt	: colorEntryPtr; { color intensities for entire row }
	pi_HamInt	: colorEntryPtr; { PRIVATE - DO NOT USE! }
	pi_Dest1Int	: colorEntryPtr; { PRIVATE - DO NOT USE! }
	pi_Dest2Int	: colorEntryPtr; { PRIVATE - DO NOT USE! }
	pi_ScaleX	: Address;	{ array of scale values for X }
	pi_ScaleXAlt	: Address;	{ PRIVATE - DO NOT USE! }
	pi_dmatrix	: Address;	{ pointer to dither matrix }
	pi_TopBuf	: Address;	{ PRIVATE - DO NOT USE! }
	pi_BotBuf	: Address;	{ PRIVATE - DO NOT USE! }

	pi_RowBufSize	: Short;	{ PRIVATE - DO NOT USE! }
	pi_HamBufSize	: Short;	{ PRIVATE - DO NOT USE! }
	pi_ColorMapSize	: Short;	{ PRIVATE - DO NOT USE! }
	pi_ColorIntSize	: Short;	{ PRIVATE - DO NOT USE! }
	pi_HamIntSize	: Short;	{ PRIVATE - DO NOT USE! }
	pi_Dest1IntSize	: Short;	{ PRIVATE - DO NOT USE! }
	pi_Dest2IntSize	: Short;	{ PRIVATE - DO NOT USE! }
	pi_ScaleXSize	: Short;	{ PRIVATE - DO NOT USE! }
	pi_ScaleXAltSize : Short;	{ PRIVATE - DO NOT USE! }

	pi_PrefsFlags	: Short;	{ PRIVATE - DO NOT USE! }
	pi_special	: Integer;	{ PRIVATE - DO NOT USE! }
	pi_xstart	: Short;	{ PRIVATE - DO NOT USE! }
	pi_ystart	: Short;	{ PRIVATE - DO NOT USE! }
	pi_width	: Short;	{ source width (in pixels) }
	pi_height	: Short;	{ PRIVATE - DO NOT USE! }
	pi_pc		: Integer;	{ PRIVATE - DO NOT USE! }
	pi_pr		: Integer;	{ PRIVATE - DO NOT USE! }
	pi_ymult	: Short;	{ PRIVATE - DO NOT USE! }
	pi_ymod		: Short;	{ PRIVATE - DO NOT USE! }
	pi_ety		: Short;	{ PRIVATE - DO NOT USE! }
	pi_xpos		: Short;	{ offset to start printing picture }
	pi_threshold	: Short;	{ threshold value (from prefs) }
	pi_tempwidth	: Short;	{ PRIVATE - DO NOT USE! }
	pi_flags	: Short;	{ PRIVATE - DO NOT USE! }
    end;
    PrtInfoPtr = ^PrtInfo;

