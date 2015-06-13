Program CEView;

{
	CEView.p

			Cat'sEye

			November 4th AD 1990

	This was derived from View.p which, in turn, was derived from...

	VIEW.C - tiny ILBM viewer (c) 1986 DJH

	Note that there is now only ONE way to call this program;
	from CLI, as in : "CEView filespec."

	Pascal Version ported October 21st, AD 1990 Cat'sEye

	The main difference between this and View.p is that this uses
	ILBM.i.

}

{$I "Include:Exec/Interrupts.i"}
{$I "Include:CEUtils/Intuistuff.i"}
{$I "Include:CEUtils/GFXStuff.i"}
{$I "Include:Utils/Parameters.i"}
{$I "Include:Utils/Break.i"}

Var	GfxBase		: Address;
	NS		: NewScreen;
	S		: ScreenPtr;
	W		: WindowPtr;
	NW		: NewWindow;
	I		: Short;
	FS		: String;
	Cbm		: BitMapPtr;
	VCM		: VColMap;
	Dst		: ^Byte;

{- - - - - - - - - - - - - - - - M A I N - - - - - - - - - - - - - - - - - }

Begin

Dst := nil;
GfxBase := OpenLibrary("graphics.library",0);
fs := AllocString (100);
GetParam (1, fs);
if OpenILBM (FS) = nil then exit (15);
FreeString (fs);
if CEReadILBM (	Cbm,		{ bit map }
		TRUE,		{ we want a new bit map }
		Adr (VCM[0,0]),	{ colours }
		nil,		{ view port }
		Adr (NS.ViewModes)) = false then exit (16);
With NS do
	begin
	LeftEdge	:= 0;
	TopEdge		:= 0;
	Width		:= BMH.w;
	Height		:= BMH.h;
	Depth		:= BMH.nPlanes;
	DetailPen	:= 0;
	BlockPen	:= 0;
	SType		:= CUSTOMSCREEN_f + CUSTOMBITMAP_f + SCREENQUIET_f;
	Font		:= nil;
	DefaultTitle	:= nil;
	Gadgets		:= nil;
	CustomBitMap	:= CBm;
	end;
s := OpenScreen(Adr(NS));
CMAPtoVPort (31, Adr(S^.SViewPort), Adr(VCM));
With NW do
	begin
	LeftEdge	:= 0;
	TopEdge		:= 0;
	IDCMPFlags	:= CLOSEWINDOW_f;
	Flags		:= WINDOWDRAG + WINDOWDEPTH + WINDOWCLOSE;
	Title		:= "CEView";
	BlockPen	:= 1;
	DetailPen	:= 2;
	Screen		:= nil;
	FirstGadget	:= nil;
	BitMap		:= nil;
	CheckMark	:= nil;
	WType		:= WBENCHSCREEN_f;
	Height		:= 10;
	Width		:= 200;
	end;
W := OpenWindow (Adr(Nw));
if W = nil then
	begin
	CloseScreen(s);
	exit(10);
	end;
if WaitPort(w^.UserPort) = nil then;
Forbid;
	CloseWindow(w);
	CloseScreen(s);
	FreeBitMap (Cbm, BMH.w, BMH.h, BMH.nPlanes);
	CloseLibrary(GfxBase);
Permit;
CloseILBM;
end.
