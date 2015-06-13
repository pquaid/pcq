External;

{
	GfxStuff.x for PCQ Pascal

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

Function RastSize (W, H : Integer) : Integer;

	{ Yes folks, RASSIZE doesn't work. This does though. }

Begin
RastSize := H * (((w + 15) shr 3) AND $FFFE);
end;

Function MakeBitMap (W, H, D : Short) : BitMapPtr;

	{ Makes a BitMap, initializes it, allocates a contiguous
	  space for all the planes and initializes them. }

Var	B : BitMapPtr;
	I : Integer;
	C : Address;

Begin
B := AllocMem (SizeOf (BitMap), MEMF_CHIP + MEMF_CLEAR);
InitBitMap ( B, D, W, H );
C := AllocRaster (W, H * D);
for i := 0 to D-1 do
	B^.Planes[i] := Address(Integer(C) + RAStSIZE (W, H) * i);
MakeBitMap := B;
end;

Procedure FreeBitMap (B : BitMapPtr; W, H, D : Short);

	{ Frees a BitMap made with MakeBitMap(). }

Begin
FreeRaster (B^.Planes[0], W, H * D);
FreeMem (B, SizeOf (BitMap));
end;

Function MakeMask (iB : BitMapPtr;) : BitMapPtr;

	{ Takes a BitMap, makes a new 1-plane BitMap of the same size,
	  takes all of the the original planes and OR's them into
	  the new BitMap. }

Var	B	: BitMapPtr;
	I, J	: Integer;
	C	: BytePtr;
	Bp	: BytePtr;

Begin
B := MakeBitMap (iB^.BytesPerRow * 8, iB^.Rows, 1);
for J := 0 to iB^.BytesPerRow * ib^.Rows-1 do
	begin
	C := Address (Integer(B^.Planes[0]) + j);
	Bp := BytePtr (Integer(iB^.Planes[0]) + j);
	C^ := Bp^;
		for i := 1 to ib^.Depth-1 do
			begin
			Bp := BytePtr (Integer(iB^.Planes[i]) + j);
			C^ := C^ or Bp^;
			end;
	end;
MakeMask := B;
end;

Procedure MakeBob (Var BB : BobPtr; Var BM : BitMapPtr );

	{ NB. In order to make a BOB, the data pointed to by Planes[] in BM
	  must be CONTIGUOUS. My suggestion is to use MakeBitMap() }

Var 	VS : VSpritePtr;
	SB : BitMapPtr;

begin
BB := AllocMem (SizeOf (Bob), MEMF_CHIP + MEMF_PUBLIC);
VS := AllocMem (SizeOf (VSprite), MEMF_CHIP + MEMF_PUBLIC);
SB := MakeBitMap (BM^.BytesPerRow * 8, BM^.Rows, BM^.Depth);
With VS^ do
	Begin
	Flags	:= SAVEBACK + OVERLAY;
	Y	:= 0;
	X	:= 0;
	Height	:= BM^.Rows;
	Width	:= BM^.BytesPerRow * 8;
	Depth	:= BM^.Depth;
	MeMask	:= -1;
	HitMask := -1;
	ImageData := BM^.Planes[0];
	VSBob	:= BB;
	PlanePick := 255;
	PlaneOnOff := 0;
	VUserExt := nil;
	end;
With BB^ do
	begin
	Flags		:= SAVEBOB;	{ I think } {|}
	SaveBuffer	:= SB^.Planes[0];
	ImageShadow	:= nil;
	Before		:= nil;
	After		:= nil;
	BobVSprite	:= VS;
	BobComp		:= nil;
	DBuffer		:= nil;
	BUserExt	:= SB;	{ So we can FreeBitMap when we FreeBob }
	end;

end;

Procedure FreeBob (BB : BobPtr);

	{ Frees a BOB made with MakeBob. After calling this, free your
	  BitMap which contains this BOB image. Capish? }

Var	SB : BitMapPtr;

begin
FreeMem (BB^.BobVSprite, SizeOf (VSprite));
FreeBitMap (BitMapPtr(BB^.BUserExt), BB^.BobVSprite^.Height,
		 BB^.BobVSprite^.Width,  BB^.BobVSprite^.Depth);
FreeMem (BB, SizeOf (Bob));
end;

Procedure AttachTmpRas (rp : RastPortPtr; tr : TmpRasPtr);

begin
tr^.RasPtr := AllocRaster (Rp^.BitMap^.BytesPerRow * 8, Rp^.BitMap^.Rows * 8);
tr^.Size := RastSize (Rp^.BitMap^.BytesPerRow * 8, Rp^.BitMap^.Rows * 8);
rp^.TmpRas := tr;
end;

Procedure DetachTmpRas (rp : RastPortPtr; tr : TmpRasPtr);

begin
FreeRaster (tr^.RasPtr, rp^.BitMap^.BytesPerRow * 8, Rp^.BitMap^.Rows * 8);
rp^.tmpRas := nil;
end;

Procedure DoRead (Buffer : Address; Length : Integer);

var
	ReadResult : Integer;
begin
	ReadResult := DOSRead(CFH, Buffer, Length);
	if ReadResult <> Length then
		Exit (10);
end;

Procedure ReadJunk;
var h : Array [1..1024] of char;

begin
while Header.CkSize > 1024 do
	begin
	DoRead (Adr(h), 1024);
	Header.CkSize := Header.CkSize - 1024;
	end;
DoRead (Adr(h), Header.CkSize);
end;

Procedure DeComp (Sourcebuf : ^Byte; Dest : BitMapPtr);

var
	destbuf		: ^Byte;
	n		: byte;
	plane,
	linelen,
	rowbytes,
	i,j		: Short;
	PtD		: Short;

begin
PtD := BMH.nPlanes-1;
if BMH.Masking = mskHasMask then Ptd := BMH.nPlanes;
linelen := BMH.w div 8;
for i := 0 to BMH.h-1 do
    for plane := 0 to PtD do
      begin
      if not((Plane = PtD) and (BMH.Masking = mskHasMask)) then
	begin
	destbuf := Address(Integer(Dest^.Planes[plane]) + i * LineLen);
	if (BMH.compression = cmpByteRun1) then
		begin
		rowbytes := linelen;
		while (rowbytes > 0) do
		    begin
		    n := sourcebuf^;
		    inc(sourcebuf);
		    case n of
			{ PCQ doesn't use signed byte values, so I have to
			  change the case and calculations slightly from
			  the Reference Manual. } {|}
		0..127:	begin
			Inc (n);
			movmem(sourcebuf,destbuf,n);
			rowbytes := rowbytes - n;
			destbuf := Address(Integer(destbuf) + n);
			sourcebuf := Address(Integer(sourcebuf) + n);
			end;
		129..255: begin
			n := 257 - n;
			rowbytes := rowbytes - n;
			setmem(destbuf, n, sourcebuf^);
			inc(sourcebuf);
			destbuf := Address(Integer(destbuf) + n);
		end 
	    end  { * case * }
	end  { * while * }
	end  { * if compressed * }
      else
	begin
        movmem (sourcebuf,destbuf,linelen);
	Sourcebuf := Address(Integer(sourcebuf) + linelen);
	destbuf := Address(Integer(destbuf) + linelen);
        end;
    end;  { * if mask plane * }
  end;  { * for * }
end;

Procedure CMAPtoVPort (CC : Short; DVPort : ViewPortPtr; Sc : VColMapPtr);

begin
while cc >= 0 do
	begin
	SetRGB4(DVPort, cc, Sc^[cc][0] shr 4,
		Sc^[cc][1] shr 4, Sc^[cc][2] shr 4);
	Dec (cc);
	end;
End;

Function OpenILBM (filespec : string) : FileHandle;

Var	ID : Integer;

Begin
CFH := DOSOpen(filespec,MODE_OLDFILE);
if CFH = nil then OpenILBM := nil;
DORead(adr(header),sizeof(Chunk));
if (header.ckID <> ID_FORM) then
	begin
	DOSClose(CFH);
	OpenILBM := nil;
	end;
DORead(adr(id),4);
if (id <> ID_ILBM) then
	begin
	DOSClose(CFH);
	OpenILBM := nil;
	end;
CFH := CFH;
CIF := filespec;
OpenILBM := CFH;
end; { OpenILBM }

Function CEReadILBM (
	Var DBMap	: BitMapPtr;	{ DeComp into here }
	NewBM		: Boolean;	{ Should we make a new bitmap? }
	ColDest		: ^Byte;	{ Load the CMAP into here. If nil,
					  put it in DVPort. }
	DVPort		: ViewPortPtr;	{ Colours }
	VMDest		: Address) : Boolean;	{ Address of ViewModes }

var
	Buffer		: ^Byte;
	BufferSize	: Integer;
	CheckList	: Short;
	ColourCount	: Short;
	I		: Short;

Begin

if ColDest = nil then
	ColDest := Adr(VColourMap[0,0]);
CheckList := 0;

repeat
DORead(adr(header),sizeof(Chunk));
if odd(header.CkSize) then inc(header.CkSize);
Case header.CkID of
	ID_CMAP:
		begin
		Inc(CheckList);
		DORead(ColDest,header.cksize);
	        colourcount := header.ckSize div 3 - 1;
		end;
	ID_BODY:
		Begin
		Inc(CheckList);
		Buffer := AllocMem(header.ckSize, MEMF_PUBLIC + MEMF_CLEAR);
		if (Buffer = nil) then CEReadILBM := FALSE;
		DORead(Buffer,header.cksize);
		BufferSize := header.cksize;
		end;
	ID_CAMG:
		begin
		Inc(CheckList);
		DORead(VMDest,header.cksize);
		end;
	ID_BMHD:
		begin
		Inc(CheckList);
		DORead(adr(BMH),sizeof(BitMapHeader));
		if not(NewBM) then
		    begin
		    if not((RastSize (BMH.w,1) = DBMap^.BytesPerRow)
			and (BMH.h = DBMap^.Rows)
			and (BMH.nPlanes = DBMap^.Depth)
		      ) then CEReadILBM := FALSE;
		    end
		end;
	else ReadJunk;
	end;
until (header.ckID = ID_BODY);
if (CheckList < 4) then CEReadILBM := FALSE;
if NewBM then DBMap := MakeBitMap (BMH.w, BMH.h, BMH.nPlanes);
DeComp (Buffer, DBMap);
FreeMem (Buffer, BufferSize);
if ColDest = Adr(VColourMap[0,0]) then CMAPtoVPort (ColourCount, DVPort,
		Adr(VColourMap));
CEReadILBM := TRUE;
end;

Procedure CloseILBM;

begin
DOSClose (CFH);
end;
