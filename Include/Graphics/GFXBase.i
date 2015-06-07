{
	GfxBase.i for PCQ Pascal
}

{$I "Include:Exec/Lists.i"}
{$I "Include:Exec/Libraries.i"}
{$I "Include:Exec/Interrupts.i"}

type

    GfxBaseRec = record
	LibNode		: Library;
	ActiView 	: Address;	{ ViewPtr }
	copinit		: Address; { (copinitptr) ptr to copper start up list }
	cia		: Address;	{ for 8520 resource use }
	blitter		: Address;	{ for future blitter resource use }
	LOFlist		: Address;
	SHFlist		: Address;
	blthd,
	blttl		: Address;
	bsblthd,
	bsblttl		: Address;	{ Previous four are (bltnodeptr) }
	vbsrv,
	timsrv,
	bltsrv		: Interrupt;
	TextFonts	: List;
	DefaultFont	: Address;	{ TextFontPtr }
	Modes		: Short;	{ copy of current first bplcon0 }
	VBlank		: Byte;
	Debug		: Byte;
	BeamSync	: Short;
	system_bplcon0	: Short; { it is ored into each bplcon0 for display }
	SpriteReserved	: Byte;
	bytereserved	: Byte;
	Flags		: Short;
	BlitLock	: Short;
	BlitNest	: Short;

	BlitWaitQ	: List;
	BlitOwner	: Address;	{ TaskPtr }
	TOF_WaitQ	: List;
	DisplayFlags	: Short;	{ NTSC PAL GENLOC etc}

		{ Display flags are determined at power on }

	SimpleSprites	: Address;	{ SimpleSpritePtr ptr }
	MaxDisplayRow	: Short;	{ hardware stuff, do not use }
	MaxDisplayColumn : Short;	{ hardware stuff, do not use }	
	NormalDisplayRows : Short;
	NormalDisplayColumns : Short;

	{ the following are for standard non interlace, 1/2 wb width }

	NormalDPMX	: Short;	{ Dots per meter on display }
	NormalDPMY	: Short;	{ Dots per meter on display }
	LastChanceMemory : Address;	{ SignalSemaphorePtr }
	LCMptr		: Address;
	MicrosPerLine	: Short;	{ 256 time usec/line }
	MinDisplayColumn : Short;
	reserved	: Array [0..22] of Integer; { for future use }
    end;
    GfxBasePtr = ^GfxBaseRec;

const

    NTSC	= 1;
    GENLOC	= 2;
    PAL		= 4;

    BLITMSG_FAULT = 4;
