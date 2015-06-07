Program EasyIFF;

{
	EasyExample - A simple ILBM file viewer by Christian A. Weber
	This program is in the public domain, use at your own risk.
	Requires the iff.library in the LIBS: dircetory.

    This Pascal program is Weber's C program EasyExample.c re-written
    in PCQ Pascal.

}

{$I "Include:Graphics/GFXBase.i"}
{$I "Include:Intuition/Intuition.i"}
{$I "Include:Libraries/IFF.i"}
{$I "Include:Exec/Libraries.i"}
{$I "Include:Graphics/View.i"}
{$I "Include:Libraries/DOS.i"}
{$I "Include:Utils/StringLib.i"}
{$I "Include:Utils/Parameters.i"}

Const
    GfxBase	: GfxBasePtr = Nil;
    IFile	: IFFFILE = Nil;
    MyScreen	: ScreenPtr = Nil;

Const
    NS	: NewScreen = (0,0,0,0,0,0,0,0, CUSTOMSCREEN_f or SCREENQUIET_f,
			Nil, "Simple ILBM viewer by Christian A. Weber",
			Nil,Nil);



Procedure SetOverscan(Screen : ScreenPtr);
{ Adjust the screen position for overscan }
var
    cols,rows	: Short;
    x,y		: Short;

    vp		: ViewPortPtr;

begin
    x := Screen^.Width;
    y := Screen^.Height;

    vp := @Screen^.SViewPort;

    cols := GfxBase^.NormalDisplayColumns div 2;
    rows := GfxBase^.NormalDisplayRows;
    if rows > 300 then
	rows := rows div 2;
    x := x - cols;
    if (vp^.Modes and HIRES) <> 0 then
	x := x - cols;
    y := y - rows;
    if (vp^.Modes and LACE) <> 0 then
	y := y - rows;
    x := x div 2;
    if x < 0 then
	x := 0;
    y := y div 2;
    if y < 0 then
	y := 0;
    if y > 32 then
	y := 32;

	{ Correct overscan HAM color distortions }

    if (vp^.Modes and HAM) <> 0 then begin
	if ViewPtr(GfxBase^.ActiView)^.DxOffset-x < 96 then
	    x := View(GfxBase^.ActiView^).DxOffset-96;
    end;
    vp^.DxOffset := -x;
    vp^.DyOffset := -y;
    MakeScreen(Screen);
    RethinkDisplay();
end;


Procedure Fail(Error : String);	{ Print error message, free resources and exit }
begin
    Writeln(Error, ', IFFError = ', IFFError);

    if IFile <> Nil then
	CloseIFF(IFile);
    if MyScreen <> Nil then
	CloseScreen(MyScreen);

    if IFFBase <> Nil then
	CloseLibrary(IFFBase);	{ MUST ALWAYS BE CLOSED !! }
    CloseLibrary(LibraryPtr(GfxBase));
    Exit(0);
end;

var
    Count,i	: Short;
    BMHD	: BitMapHeaderPtr;
    ColorTable	: Array [0..127] of Short;
    FileName	: String;
begin
    FileName := AllocString(256);
    GetParam(1,FileName);

    if (strlen(FileName) = 0) or streq(FileName,"?") then begin
	Writeln("Format: EasyIFF filename");
	exit(10);
    end;

    GfxBase := GfxBasePtr(OpenLibrary("graphics.library",0));

    IFFBase := OpenLibrary(IFFNAME, IFFVERSION);
    if IFFBase = Nil then begin
	Writeln('Copy the iff.library to your LIBS: directory!');
	Exit(10);
    end;

    Write('Loading file ', FileName, ' ...');

    IFile := OpenIFF(FileName);
    if IFile = Nil then
	Fail("Error opening file");
    BMHD := GetBMHD(IFile);
    if BMHD = Nil then
	Fail("BitMapHeader not found");

    with NS do begin
	Width      := BMHD^.w;
	Height     := BMHD^.h;
	Depth      := BMHD^.nPlanes;
	ViewModes  := GetViewModes(IFile);
    end;

    MyScreen := OpenScreen(@NS);
    if MyScreen = Nil then
	Fail("Can't open screen!");
    SetOverscan(MyScreen);

    Count := GetColorTab(IFile, @ColorTable);
    if count > 32 then
	count := 32;	{ Some HAM pictures have 64 colors ?! }
    LoadRGB4(@MyScreen^.SViewPort,@ColorTable,Count);

    if not DecodePic(IFile,@MyScreen^.SBitMap) then
	Fail("Can't decode picture");

    Delay(200);
    Fail("done");	 { Normal termination }
end.

