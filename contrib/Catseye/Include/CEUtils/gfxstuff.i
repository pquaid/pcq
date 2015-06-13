{
	GfxStuff.i for PCQ Pascal

	Cat'sEye

	Include file for the library GfxStuff
}

{$I "Include:CEUtils/CETypes.i"}
{$I "Include:Exec/Memory.i"}
{$I "Include:Exec/Libraries.i"}
{$I "Include:Graphics/RastPort.i"}
{$I "Include:Graphics/View.i"}
{$I "Include:CEUtils/IFF.i"}

{

Type
	BUserStuff	= Address;	But of course we can't #define this.
					I've put it in my GELS.i file.
}

type
	
	VColMap = Array [0..32, 0..2] of Byte;
	VcolMapPtr = ^VColMap;

Function MakeBitMap (W, H, D : Integer) : BitMapPtr;		External;

	{ Makes a BitMap, initializes it, allocates a contiguous
	  space for all the planes and initializes them. }

Function MakeMask (iB : BitMapPtr) : BitMapPtr;			External;

	{ Frees a BitMap made with MakeBitMap(). }

Procedure FreeBitMap (B : BitMapPtr);				External;

	{ Takes a BitMap, makes a new 1-plane BitMap of the same size,
	  takes all of the the original planes and OR's them into
	  the new BitMap. }

Procedure AttachTmpRas (rp : RastPortPtr; tr : TmpRasPtr; bmp : BitMapPtr);
	External;

	{ A thimble-minded procedure to attach a TmpRas to a
	  RastPort, so you can do Areas and other junk into
	  it. }

Procedure DetachTmpRas (rp : RastPortPtr; tr : TmpRasPtr; bmp : BitMapPtr);
	External;

	{ Gets rid of a RastPort's TmpRas, if it was Attached()
	  with the above procedure. }

