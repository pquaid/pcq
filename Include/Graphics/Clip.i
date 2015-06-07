{
    Clip.i of PCQ Pascal

    These are the types used for layer and clipping stuff.
}

{$I "Include:Graphics/GFX.i"}
{$I "Include:Exec/Semaphores.i"}

type

{ structures used by and constructed by windowlib.a }
{ understood by rom software }

    ClipRect = Record
	Next	: ^ClipRect;	{ roms used to find next ClipRect }
	prev	: ^ClipRect;	{ ignored by roms, used by windowlib }
	lobs	: Address;	{ ignored by roms, used by windowlib (LayerPtr)}
	BitMap	: Address;
	bounds	: Rectangle;	{ set up by windowlib, used by roms }
	_p1,
	_p2	: ^ClipRect;	{ system reserved }
	reserved : Integer;	{ system use }
	Flags	: Integer;	{ only exists in layer allocation }
    end;
    ClipRectPtr = ^ClipRect;

    Layer = record
	front,
	back		: ^Layer;	{ ignored by roms }
	ClipRect 	: ClipRectPtr;	{ read by roms to find first cliprect }
	rp		: Address;	{ (RastPortPtr) ignored by roms, I hope }
	bounds		: Rectangle;	{ ignored by roms }
	reserved 	: Array [0..3] of Byte;
	priority 	: Short;	{ system use only }
	Flags		: Short;	{ obscured ?, Virtual BitMap? }
	SuperBitMap	: Address;
	SuperClipRect	: ClipRectPtr;	{ super bitmap cliprects if 
						VBitMap != 0}
					{ else damage cliprect list for refresh }
	Window		: Address;	{ reserved for user interface use }
	Scroll_X,
	Scroll_Y	: Short;
	cr,
	cr2,
	crnew		: ClipRectPtr;	{ used by dedice }
	SuperSaveClipRects : ClipRectPtr; { preallocated cr's }
	_cliprects	: ClipRectPtr;	{ system use during refresh }
	LayerInfo	: Address;	{ points to head of the list }
	Lock		: SignalSemaphore;
	reserved3	: Array [0..7] of Byte;
	ClipRegion	: Address;
	saveClipRects	: Address;	{ used to back out when in trouble}
	reserved2	: Array [0..21] of Byte;
	{ this must stay here }
	DamageList	: Address;	{ list of rectangles to refresh 
						through }
    end;
    LayerPtr = ^Layer;

const

{ internal cliprect flags }

    CR_NEEDS_NO_CONCEALED_RASTERS	= 1;

{ defines for code values for getcode }

    ISLESSX	= 1;
    ISLESSY	= 2;
    ISGRTRX	= 4;
    ISGRTRY	= 8;


Function AttemptLockLayerRom(layer : LayerPtr) : Boolean;
    External;

Procedure CopySBit(layer : LayerPtr);
    External;

Procedure LockLayerRom(layer : LayerPtr);
    External;

Procedure SyncSBitMap(layer : LayerPtr);
    External;

Procedure UnlockLayerRom(layer : LayerPtr);
    External;

