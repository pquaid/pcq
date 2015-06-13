{
	GfxStuff.i for PCQ Pascal

	Just generic graphics stuff.
}

{$I "Include:Exec/Memory.i"}
{$I "Include:CEUtils/CMem.i"}
{$I "Include:Exec/Libraries.i"}
{$I "Include:Libraries/DOS.i"}
{$I "Include:Graphics/RastPort.i"}
{$I "Include:Graphics/GELS.i"}
{$I "Include:Graphics/View.i"}

{

Type
	BUserStuff	= Address;	But of course we can't #define this.
					I've put it in my GELS.i file.
}

const	MAXWIDTH	= 376;
	MAXHEIGHT	= 242;
	cmpByteRun1	= 1;
	mskNone		= 0;
	mskHasMask	= 1;
	mskHasTransparentColour = 2;
	mskLasso	= 3;

type	Chunk = record
		ckID,
		ckSize		: Integer;
		end;

	BitMapHeader = record
		w,h,x,y		: Short;
		nPlanes,
		masking,
		compression,
		pad1		: Byte;
		transparentcolour
				: Short;
		xAspect,
		yAspect		: Byte;
		pageWidth,
		pageHeight	: Short;
		end;

	VColMap = Array [0..32, 0..2] of Byte;

	VcolMapPtr = ^VColMap;

	BytePtr = ^Byte;

const 	ID_FORM = $464f524d;	{ Crissakes I hate doing this }
	ID_ILBM = $494c424d;
	ID_BMHD = $424d4844;
	ID_CAMG = $43414d47;
	ID_CMAP = $434d4150;
	ID_BODY	= $424f4459;

Var
	BMH	: BitMapHeader; { current ILBM BMHD	 }
	CIF	: String;	{ current ILBM file name }
	CFH	: FileHandle;
	Header	: Chunk;
	VcolourMap
		: VColMap;

Function RastSize (W, H : Integer) : Integer;			External;
Function MakeBitMap (W, H, D : Short) : BitMapPtr;		External;
Function MakeMask (iB : BitMapPtr;) : BitMapPtr;		External;
Procedure FreeBitMap (B : BitMapPtr; W, H, D : Short);		External;
Procedure MakeBob (Var BB : BobPtr; Var BM : BitMapPtr );	External;
Procedure FreeBob (BB : BobPtr);				External;
Procedure DoRead (Buffer : Address; Length : Integer);		External;
Procedure ReadJunk;						External;
Procedure DeComp (Sourcebuf : ^Byte; Dest : BitMapPtr);		External;
Procedure CMAPtoVPort (CC : Short; DVPort : ViewPortPtr; Sc : VColMapPtr);
								External;
Function OpenILBM (filespec : string) : FileHandle;		External;
Function CEReadILBM (
	Var DBMap	: BitMapPtr;	{ DeComp into here }
	NewBM		: Boolean;	{ Should we make a new bitmap? }
	ColDest		: ^Byte;	{ Load the CMAP into here. If nil,
					  put it in DVPort. }
	DVPort		: ViewPortPtr;	{ Colours }
	VMDest		: Address) : Boolean;	{ Address of ViewModes }
	External;
Procedure CloseILBM;						External;
