{
	CEILBM.i for PCQ Pascal

	Cat'sEye

	Include file for the ILBM functions in GfxStuff
}

{$I "Include:CEUtils/GfxStuff.i"}
{$I "Include:CEUtils/DosStuff.i"}

Procedure DeComp (Sourcebuf : ^Byte; Dest : BitMapPtr; BMH : BitMapHeader);
	External;

	{ Decompresses compressed ILBM data from SourceBuf into
	  the destination BitMap. }

Procedure CMAPtoVPort (CC : Short; DVPort : ViewPortPtr; Sc : VColMapPtr);
	External;

	{ Takes a VColMap structure and shoves it into a ViewPort. }

Function CEReadILBM (

	{ This Function actually reads and interprets an IFF ILBM,
	  opened by DosStuff OpenILBM(). }

	Cfh		: FileHandle;
	Var DBMap	: BitMapPtr;	{ DeComp into here }
	NewBM		: Boolean;	{ Should we make a new bitmap? }
	ColDest		: BytePtr;	{ Load the CMAP into here. If nil,
					  put it in DVPort. }
	DVPort		: ViewPortPtr;	{ Colours }
	Var BMH		: BitMapHeader;
	VMDest		: Address) : Boolean;	{ Address of ViewModes }
	External;

	{ Use DOSClose (filehandle) to Close an ILBM file }
