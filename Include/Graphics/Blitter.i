{
	Blitter.i for PCQ Pascal

	Defines the routines, constants, types, etc. for accessing
	the Blitter.
}


{$I "Include:Graphics/GFX.i"}
{$I "Include:Graphics/RastPort.i"}

Const
    CleanUp	= $40;
    CleanMe	= CleanUp;

Type
    BltNode = record
	N	: ^BltNode;
	Func	: Address;
	Stat	: Byte;
	BlitSize: Short;
	BeamSync: Short;
	CleanUp	: Address;
    end;
    BltNodePtr = ^BltNode;


Const
    BltClearWait	= 1;	{ Waits for blit to finish }
    BltClearXY		= 2;	{ Use Row/Bytes per row method }

	{ Useful minterms }

    StraightCopy	= $C0;	{ Vanilla copy }
    InvertAndCopy	= $30;	{ Invert the source before copy }
    InvertDest		= $50;	{ Forget source, invert dest }


Function BltBitMap(SrcBitMap : BitMapPtr; SrcX, SrcY : Short;
		   DstBitMap : BitMapPtr; DstX, DstY : Short;
		   SizeX, SizeY : Short; Minterm : Byte;
		   Mask : Byte; TempA : Address) : Integer;
    External;


Procedure BltBitMapRastPort(SrcBM : BitMapPtr; SrcX, SrcY : Short;
			   DestRP: RastPortPtr; DestX, DestY : Short;
			   SizeX, SizeY : Short; MinTerm : Byte);
    External;


Procedure BltClear(memBlock : Address; ByteCount : Integer; Flags : Integer);
    External;


Procedure BltMaskBitMapRastPort(SrcBM : BitMapPtr; SrcX, SrcY : Short;
				DestRP : RastPortPtr; DestX, DestY : Short;
				SizeX, SizeY : Short;
				MinTerm : Byte; BltMask : PlanePtr);
    External;


Procedure BltPattern(RP : RastPortPtr; Mask : Address; xl, yl : Short;
			MaxX, MaxY : Short; ByteCnt : Short);
    External;


Procedure BltTemplate(SrcTemplate : PlanePtr; SrcX, SrcMOD : Short;
			RP : RastPortPtr; DstX, DstY, SizeX, SizeY : Short);
    External;


Procedure ClipBlit(Src : RastPortPtr; SrcX, SrcY : Short;
		   Dest: RastPortPtr; DestX, DestY : Short;
		   XSize, YSize : Short;
		   Minterm : Byte);
    External;


Procedure DisownBlitter;
    External;


Procedure OwnBlitter;
    External;


Procedure QBlit(bp : BltNodePtr);
    External;


Procedure QBSBlit(bsp : BltNodePtr);
    External;


Procedure WaitBlit;
    External;

