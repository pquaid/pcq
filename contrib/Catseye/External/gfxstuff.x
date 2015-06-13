{
	GfxStuff.x for PCQ Pascal

	Cat'sEye

	The External file for GfxStuff.lib. (Graphics bit from CE.lib)

}

{

Type
	BUserStuff	= Address;	But of course we can't #define this.
					I've put it in my GELS.i file.
}

type
	VColMap = Array [0..32, 0..2] of Byte;
	VcolMapPtr = ^VColMap;

Function MakeBitMap (W, H, D : Integer) : BitMapPtr;

	{ Makes a BitMap, initializes it, allocates a contiguous
	  space for all the planes and initializes them. }

Var	B : BitMapPtr;
	I : Integer;
	C : Address;

Begin
B := AllocMem (SizeOf (BitMap), MEMF_CHIP + MEMF_CLEAR);
B^.Depth := D;
B^.BytesPerRow := RASSIZE (W, 1);
B^.Rows := H;
B^.Flags := 0;
C := AllocMem (RASSIZE (W, H) * B^.Depth, MEMF_CHIP + MEMF_CLEAR);
for i := 0 to D-1 do
	B^.Planes[i] := Address(Integer(C) + RASSIZE (W, H) * i);
MakeBitMap := B;
end;

Procedure FreeBitMap (B : BitMapPtr);

	{ Frees a BitMap made with MakeBitMap(). }

Begin
FreeMem (B^.Planes[0], B^.Rows * B^.Depth * B^.BytesPerRow);
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

Procedure AttachTmpRas (rp : RastPortPtr; tr : TmpRasPtr; bmp : BitMapPtr);

	{ A thimble-minded procedure to attach a TmpRas to a
	  RastPort, so you can do Areas and other junk into
	  it. }

Var	b	: BitMapPtr;

begin
new (tr);
b := Rp^.BitMap;
bmp := MakeBitMap (b^.BytesPerRow * 8, b^.Rows, 1);
tr^.RasPtr := Bmp^.Planes[0];
tr^.Size := Bmp^.BytesPerRow * 8 * Bmp^.Rows;
rp^.TmpRas := tr;
end;

Procedure DetachTmpRas (rp : RastPortPtr; tr : TmpRasPtr; bmp: BitMapPtr);

	{ Gets rid of a RastPort's TmpRas, if it was Attached()
	  with the above procedure. }

begin
FreeBitMap (bmp);
rp^.tmpRas := nil;
dispose (tr);
end;

Procedure DeComp (Sourcebuf : ^Byte; Dest : BitMapPtr; BMH : BitMapHeader);

var
	destbuf		: ^Byte;
	n		: byte;
	plane,
	linelen,
	rowbytes,
	i,j		: Short;
	PtD		: Short;

	Procedure SetMem (ou : Address; combien: integer; que : byte);
	
	var	I : integer;
		c : ^byte;
	
	begin
	c := ou;
	for I := 1 to combien do
		begin
		c^ := que;
		inc(c);
		end;
	end;

begin
PtD := BMH.nPlanes-1;
if BMH.Masking = mskHasMask then Ptd := BMH.nPlanes;
linelen := RasSize (BMH.w, 1);
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
			CopyMem(sourcebuf,destbuf,n);
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
        Copymem (sourcebuf,destbuf,linelen);
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

Function CEReadILBM (
	Cfh		: FileHandle;
	Var DBMap	: BitMapPtr;	{ DeComp into here }
	NewBM		: Boolean;	{ Should we make a new bitmap? }
	ColDest		: BytePtr;	{ Load the CMAP into here. If nil,
					  put it in DVPort. }
	DVPort		: ViewPortPtr;	{ Colours }
	Var BMH		: BitMapHeader;
	VMDest		: ShortPtr) : Boolean; { Address of ViewModes }

var
	Buffer		: BytePtr;
	BufferSize	: Integer;
	Header		: Chunk;
	CheckList	: Short;
	ColourCount	: Short;
	I		: Short;
	InVM		: Integer;
	VColourMap	: VColMap;

Begin
VMDest^ := 0;	{ just to be safe }
if ColDest = nil then
	ColDest := Adr(VColourMap[0,0]);
CheckList := 0;
repeat
ReadCkHead (cfh, Header);
Case header.CkID of
	ID_CMAP:
		begin
		Inc(CheckList);
		DORead(cfh, ColDest, header.cksize);
	        colourcount := header.ckSize div 3 - 1;
		end;
	ID_BODY:
		Begin
		Inc(CheckList);
		Buffer := AllocMem(header.ckSize, MEMF_PUBLIC + MEMF_CLEAR);
		if (Buffer = nil) then CEReadILBM := FALSE;
		DORead(cfh, Buffer, header.cksize);
		BufferSize := header.cksize;
		end;
	ID_CAMG:
		begin
		Inc(CheckList);
		DORead(cfh, Adr(InVM), header.cksize);
		VMDest^ := InVM and
			((not (VP_HIDE or SPRITES or GENLOCK_AUDIO
			or GENLOCK_VIDEO)) and $0000FFFF);
		end;
	ID_BMHD:
		begin
		Inc(CheckList);
		DORead(cfh, adr(BMH), header.CkSize); {sizeof(BitMapHeader));}
		if not(NewBM) then
		    begin
		    if not((RasSize (BMH.w,1) = DBMap^.BytesPerRow)
			and (BMH.h = DBMap^.Rows)
			and (BMH.nPlanes = DBMap^.Depth)
		      ) then CEReadILBM := FALSE;
		    end
		end;
	else
		begin
		ReadJunk (cfh, header);
		end
	end;
until (header.ckID = ID_BODY);
if (CheckList < 4) then CEReadILBM := FALSE;
if NewBM then DBMap := MakeBitMap (BMH.w, BMH.h, BMH.nPlanes);
DeComp (Buffer, DBMap, BMH);
FreeMem (Buffer, BufferSize);
if ColDest = Adr(VColourMap[0,0]) then CMAPtoVPort (ColourCount, DVPort,
		Adr(VColourMap));
CEReadILBM := TRUE;
end;
