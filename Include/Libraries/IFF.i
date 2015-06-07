{
    IFF.i for PCQ Pascal


    This file defines the constants, procedures and functions used
    to work with Christian Weber's iff.library.
}

{$I "Include:Graphics/GFX.i"}


Var
    IFFBase	: Address;

const
    IFFNAME		= "iff.library";
    IFFVERSION		= 19;			{ Current library version }

type
    IFFFILE	= Address;		{ The IFF 'FileHandle' structure }


{************* ERROR-CODES ********************************************}

Const
    IFF_BADTASK		= -1;		{ IFFError() called by wrong task }
    IFF_CANTOPENFILE	= 16;		{ File not found }
    IFF_READERROR	= 17;		{ Error reading file }
    IFF_NOMEM		= 18;		{ Not enough memory }
    IFF_NOTIFF		= 19;		{ File is not an IFF file }
    IFF_WRITEERROR	= 20;		{ Error writing file }

    IFF_NOILBM		= 24;		{ IFF file is not of type ILBM }
    IFF_NOBMHD		= 25;		{ BMHD chunk not found }
    IFF_NOBODY		= 26;		{ BODY chunk not found }
    IFF_TOOMANYPLANES	= 27;		{ Obsolete since V18.6 }
    IFF_UNKNOWNCOMPRESSION = 28;	{ Unknown compression type }

    IFF_NOANHD		= 29;		{ ANHD chunk not found (since V18.1) }
    IFF_NODLTA		= 30;		{ DLTA chunk not found (since V18.1) }


{************* COMMON IFF IDs *****************************************}

{ List of the most useful IDs, NOT complete, to be continued }

    ID_FORM	= $46798277; { FORM }
    ID_PROP	= $80827980; { PROP }
    ID_LIST	= $76738384; { LIST }
    ID_CAT	= $67658420; { CAT  }

    ID_ANIM	= $65787377; { ANIM }
    ID_ANHD	= $65787268; { ANHD }
    ID_BMHD	= $66777268; { BMHD }
    ID_BODY	= $66796889; { BODY }
    ID_CAMG	= $67657771; { CAMG }
    ID_CLUT	= $67768584; { CLUT }
    ID_CMAP	= $67776580; { CMAP }
    ID_CRNG	= $67827871; { CRNG }
    ID_CTBL	= $67846676; { CTBL }
    ID_DLTA	= $68768465; { DLTA }
    ID_ILBM	= $73766677; { ILBM }
    ID_SHAM	= $83726577; { SHAM }

    ID_8SVX	= $38838688; { 8SVX }
    ID_ATAK	= $65846575; { ATAK }
    ID_NAME	= $78657769; { NAME }
    ID_RLSE	= $82768369; { RLSE }
    ID_VHDR	= $86726882; { VHDR }


{************* STRUCTURES *********************************************}

Type

    Chunk = record		{ Generic IFF chunk structure }
	ckID	: Integer;
	ckSize	: Integer;

	ckData	: Array [0..1] of Byte; { variable sized data }
    end;
    ChunkPtr = ^Chunk;

    BitMapHeader = record	{ BMHD chunk for ILBM files }
	w,h	: Short;
	x,y	: Short;
	nPlanes	: Byte;
	masking	: Byte;
	compression	: Byte;
	pad1	: Byte;
	transparentColor	: Short;
	xAspect,yAspect		: Byte;
	pageWidth,pageHeight	: Short;
    end;
    BitMapHeaderPtr = ^BitMapHeader;

    AnimHeader = record			{ ANHD chunk for ANIM files }
	Operation	: Byte;
	Mask		: Byte;
	W		: Short;
	H		: Short;
	X		: Short;
	Y		: Short;
	AbsTime		: Integer;
	RelTime		: Integer;
	Interleave	: Byte;
	pad0		: Byte;
	Bits		: Integer;
	pad		: Array [0..15] of Byte;
    end;
    AnimHeaderPtr = ^AnimHeader;



{************* FUNCTION DECLARATIONS **********************************}

Function OpenIFF(FileName : String) : IFFFILE;
    External;

Procedure CloseIFF(IFile : IFFFILE);
    External;

Function FindChunk(IFile : IFFFILE; ChunkName : Integer) : Address;
    External;

Function GetBMHD(IFile : IFFFILE) : BitMapHeaderPtr;
    External;

Function GetColorTab(IFile : IFFFILE; ColorTable : Address) : Integer;
    External;

Function DecodePic(IFile : IFFFILE; BMP : BitMapPtr) : Boolean;
    External;

Function SaveBitMap(FileName : String; BMP : BitMapPtr;
		    ColorTable : Address; Flags : Integer) : Boolean;
    External;

Function SaveClip(FileName : String; BMP : BitMapPtr;
		  ColorTable : Address; Flags : Integer;
		  Xoffset, Yoffset, Width, Height : Integer) : Boolean;
    External;

Function IFFError : Integer;
    External;

Function GetViewModes(IFile : IFFFILE) : Integer;
    External;				{ Integer since V18.1 }

Function NewOpenIFF(FileName : String; MemAttr : Integer) : IFFFILE;
    External;				{ Since V16.1 }

Function ModifyFrame(ModForm : Address; BMP : BitMapPtr) : Boolean;
    External;				{ Since V18.1 }

