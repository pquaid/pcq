Program BOBTest;

{
    This program is based on BobTest.c from the original RKM
    example set.  It simply creates a BOB, then moves it
    around the window until you close the window.

    Besides Intuition BOBs, this program demonstrates the use
    of PCQ's CHIP keyword to specify that a global variable or
    typed constant should be placed in the Amiga's chip memory.

}

{$I "Include:Graphics/Gfx.i"}
{$I "Include:Graphics/Rastport.i"}
{$I "Include:Graphics/View.i"}
{$I "Include:Exec/Exec.i"}
{$I "Include:Graphics/Gels.i"}
{$I "Include:Intuition/Intuition.i"}
{$I "Include:Graphics/Graphics.i"}
{$I "Include:Graphics/Pens.i"}

Const
    ScreenDepth  = 3;

    ObjectWidth  = 48; { Three words wide  }
    ObjectHeight = 30; { Thirty lines tall }

    ObjectWords  = (ObjectWidth + 15) div 16;

    Memory_Flags = MEMF_PUBLIC or MEMF_CHIP or MEMF_CLEAR;

Var
    w	: WindowPtr;
    s	: ScreenPtr;
    rp	: RastPortPtr;
    vp	: ViewPortPtr;

Const
    TestFont : TextAttr = ("topaz.font", 8, 0, 0);

    ns	: NewScreen = (
	0,0,			{ start position               }
	320, 200, ScreenDepth,
	0, 1,			{ detail pen, block pen        }
	0,			{ viewing mode (was HIRES)     }
	CUSTOMSCREEN_f,		{ screen type                  }
	@TestFont,		{ font to use                  }
	"GELS Example Program",	{ default title for screen     }
	Nil,			{ pointer to additional gadgets }
	Nil
	);

    WINDOWFLAGS = GIMMEZEROZERO or WINDOWDRAG or WINDOWSIZING or
		  WINDOWDEPTH or WINDOWCLOSE or ACTIVATE;

    nw	: NewWindow = (
        20, 20,                 { start position               }
        220, 150,               { width, height                }
        -1, -1,                 { detail pen, block pen        }
        CLOSEWINDOW_f,		{ IDCMP flags                  }
        WINDOWFLAGS,		{ window flags                 }
        Nil,                    { pointer to first user gadget }
        Nil,                    { pointer to user checkmark    } 
        "Bouncing BOB",         { window title         } 
        Nil,                    { pointer to screen    (later) }
        Nil,                    { pointer to superbitmap       }
        30,20,-1,-1,            { sized window }
        CUSTOMSCREEN_f          { type of screen in which to open }   
        );


    Images : CHIP Array [0..Pred(ObjectWords*ObjectHeight*Pred(ScreenDepth))] of Short = (
		$FFFF, $0000, $FFFF,
		$FFFF, $0000, $FFFF,
		$FFFF, $0000, $FFFF,
		$FFFF, $0000, $FFFF,
		$FFFF, $0000, $FFFF,
		$FFFF, $0000, $FFFF,
		$FFFF, $0000, $FFFF,
		$FFFF, $0000, $FFFF,
		$FFFF, $0000, $FFFF,
		$FFFF, $0000, $FFFF,
		$FFFF, $0000, $FFFF,
		$FFFF, $0000, $FFFF,
		$FFFF, $0000, $FFFF,
		$FFFF, $0000, $FFFF,
		$FFFF, $0000, $FFFF,
		$FFFF, $0000, $FFFF,
		$FFFF, $0000, $FFFF,
		$FFFF, $0000, $FFFF,
		$FFFF, $0000, $FFFF,
		$FFFF, $0000, $FFFF,
		$FFFF, $0000, $FFFF,
		$FFFF, $0000, $FFFF,
		$FFFF, $0000, $FFFF,
		$FFFF, $0000, $FFFF,
		$FFFF, $0000, $FFFF,
		$FFFF, $0000, $FFFF,
		$FFFF, $0000, $FFFF,
		$FFFF, $0000, $FFFF,
		$FFFF, $0000, $FFFF,
		$FFFF, $0000, $FFFF,

		$0000, $FFFF, $FFFF,
		$0000, $FFFF, $FFFF,
		$0000, $FFFF, $FFFF,
		$0000, $FFFF, $FFFF,
		$0000, $FFFF, $FFFF,
		$0000, $FFFF, $FFFF,
		$0000, $FFFF, $FFFF,
		$0000, $FFFF, $FFFF,
		$0000, $FFFF, $FFFF,
		$0000, $FFFF, $FFFF,
		$0000, $FFFF, $FFFF,
		$0000, $FFFF, $FFFF,
		$0000, $FFFF, $FFFF,
		$0000, $FFFF, $FFFF,
		$0000, $FFFF, $FFFF,
		$0000, $FFFF, $FFFF,
		$0000, $FFFF, $FFFF,
		$0000, $FFFF, $FFFF,
		$0000, $FFFF, $FFFF,
		$0000, $FFFF, $FFFF,
		$0000, $FFFF, $FFFF,
		$0000, $FFFF, $FFFF,
		$0000, $FFFF, $FFFF,
		$0000, $FFFF, $FFFF,
		$0000, $FFFF, $FFFF,
		$0000, $FFFF, $FFFF,
		$0000, $FFFF, $FFFF,
		$0000, $FFFF, $FFFF,
		$0000, $FFFF, $FFFF,
		$0000, $FFFF, $FFFF);


var
    s1, s2	: VSprite;	{ dummy sprites for gels list }
    mygelsinfo	: GelsInfo;	{ gelsinfo to link into system rastport }
    collisiontable	: collTable;

    v	: VSprite;
    b	: Bob;

    i	: Short;

    UsedMemory	: RememberPtr;

    xspeed	: Short;
    yspeed	: Short;

    BackBuffer	: CHIP Array [0..Pred(Succ(ObjectWords) * ObjectHeight * ScreenDepth)] of Short;

    CMask	: CHIP Array [0..Pred(ObjectWords * ObjectHeight)] of Short;
    BorderMask	: CHIP Array [0..Pred(ObjectWords)] of Short;


Procedure InitializeBOB;
begin
    with MyGelsInfo do begin
	nextLine  := Nil;
	lastColor := Nil;
	collHandler := @collisiontable;
    end;

    InitGels(@s1, @s2, @MyGelsInfo);
    rp^.GelsInfo := @MyGelsInfo;

    with v do begin
	X       := 20;
	Y       := 4;
	Flags   := OVERLAY + SAVEBACK;
	Height  := ObjectHeight;
	Width   := ObjectWords;
	Depth   := ScreenDepth;

	MeMask  := 1;
	HitMask := 1;

	ImageData := @Images;	{ Point VSprite to image data }
	CollMask  := @CMask;	{ Point to collision mask area }
	BorderLine := @BorderMask; { Point to border mask area }

	InitMasks(@v);		{ Set up collision & border masks }

	PlanePick := $03;     { Just use first two planes }
	PlaneOnOff := 4;      { Set third plane solid }
    end;

        { ****************** now initialize the Bob variables ******* }       

    with b do begin
	Flags := 0;
	SaveBuffer := @BackBuffer;  { show where to save background }
	ImageShadow := @CMask;   { collision and shadow are same }
	Before := Nil;        { dont care about drawing order }
	After := Nil; 

	BobComp := Nil;       { not animation component }
	DBuffer := Nil;       { not double buffered }

	BobVSprite := @v;      { link to the VSprite }
    end;

    v.VSBob := @b;		{ Link the VSprite to the BOB }

    AddBob(@b, rp);		{ Add to the GELS list }
    SortGList(rp);		{ Sort it for drawing }
    WaitTOF;			{ Sync with beam }
    DrawGList(rp,vp);		{ Draw the BOBs, etc. }
end;

Procedure MoveBOB;
var
    M : MessagePtr;
begin
    while true do begin
	Inc(b.BobVSprite^.Y,yspeed);
        if b.BobVSprite^.Y > (w^.GZZHeight - ObjectHeight) then
	    yspeed := -yspeed
	else
	    Inc(yspeed);

	Inc(b.BobVSprite^.X,xspeed);
        if (b.BobVSprite^.X >= (w^.GZZWidth - ObjectWidth)) or
	   (b.BobVSprite^.X <= 0) then
	    xspeed := -xspeed;

        SortGList(rp);
        WaitTOF;
        DrawGList(rp,vp);
	M := GetMsg(w^.UserPort);
	if M <> Nil then begin
	    ReplyMsg(M);
	    return;
	end;
    end;
end;


Procedure Setup;
var
    i : Short;
    p : Byte;
begin
    UsedMemory := Nil;	{ To keep track of allocations }

    GfxBase := OpenLibrary("graphics.library", 0);
    if GfxBase = Nil then begin
	Writeln("Unable to open graphics library");
	exit(20);
    end;

    s := OpenScreen(@ns);
    nw.Screen := s;

    w := OpenWindow(@nw);            { open a window }
    rp := w^.RPort;
    vp := ViewPortAddress(w);

    xspeed := 2;
    yspeed := 0;

    SetRGB4(vp,5, 0, 0,12);	{ Set flag colors to blue...}
    SetRGB4(vp,6,15,15,15);	{ white }
    SetRGB4(vp,7,12, 0, 0);	{ red }

    { Draw some sort of pattern in the window to show that }
    { we aren't messing it up.                             }

    p := 1;
    SetAPen(rp,p);
    for i := 0 to w^.GZZWidth do begin
	Move(rp,i,0);
	Draw(rp,w^.GZZWidth - i,w^.GZZheight);
	p := Succ(p) and 3;
	SetAPen(rp,p);
    end;
    for i := 0 to w^.GZZheight do begin
	Move(rp, 0, i);
	Draw(rp, w^.GZZWidth, w^.GZZheight - i);
	p := Succ(p) and 3;
	SetAPen(rp,p);
    end;
end;

begin
    SetUp;
    InitializeBOB;
    MoveBOB; 

    RemBob(@b);

    FreeRemember(UsedMemory,True);
    CloseWindow(w);
    CloseScreen(s);
    CloseLibrary(GfxBase);
end.
