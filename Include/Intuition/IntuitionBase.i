{
	IntuitionBase.i for PCQ Pascal

	the IntuitionBase structure and supporting structures
}

{$I "Include:Exec/Libraries.i"}
{$I "Include:Intuition/Intuition.i"}
{$I "Include:Exec/Interrupts.i"}
{$I "Include:Graphics/GFX.i"}

{ these types and constants are used in the forbidden part of IntuitionBase.
 * see below for an explanation that these are NOT supported for your use.
 * They will certainly change in subsequent releases, and are provided
 * for education, debugging, and information.
 }

Const

{ these are the display modes for which we have corresponding parameter
 *  settings in the config arrays
 }

    DMODECOUNT		= $0002;	{ how many modes there are }
    HIRESPICK		= $0000;
    LOWRESPICK		= $0001;

    EVENTMAX 		= 10;		{ size of event array }

{ these are the system Gadget defines }

    RESCOUNT		= 2;
    HIRESGADGET		= 0;
    LOWRESGADGET	= 1;

    GADGETCOUNT		= 8;
    UPFRONTGADGET	= 0;
    DOWNBACKGADGET	= 1;
    SIZEGADGET		= 2;
    CLOSEGADGET		= 3;
    DRAGGADGET		= 4;
    SUPFRONTGADGET	= 5;
    SDOWNBACKGADGET 	= 6;
    SDRAGGADGET		= 7;

{ jimm: 1/10/86: Intuition Locking }
{ Let me say it again: don't even think about using this information
 * in a program.
 }

    ISTATELOCK		= 0;	{ Intuition() not re-entrant		}
    LAYERINFOLOCK	= 1;	{ dummy lock used to check protocol	}
    GADGETSLOCK		= 2;	{ gadget lists, refresh, flags		}
    LAYERROMLOCK	= 3;	{ (dummy) for lock layerrom		}
    VIEWLOCK		= 4;	{ access to ViewLord			}
    IBASELOCK		= 5;	{ protexts IBase pointers and lists	}
    RPLOCK		= 6;	{ use of IBase->RP			}
    NUMILOCKS		= 7;

{ ======================================================================== }
{ === Intuition Geometric Primitives ===================================== }
{ ======================================================================== }

Type

    FatIntuiMessage = record
	IM		: IntuiMessage;
	PrevKeys	: Integer;
    end;
    FatIntuiMessagePtr = ^FatIntuiMessage;

    IBox = record
	Left	: Short;
	Top	: Short;
	Width	: Short;
	Height	: Short;
    end;
    IBoxPtr = ^IBox;

    PenPair = record
	DetailPen	: Byte;
	BlockPen	: Byte;
    end;
    PenPairPtr = ^PenPair;

{ ======================================================================== }
{ === Gadget Environments ================================================ }
{ ======================================================================== }

{ environment for a whole list of gadgets. note that information for both
 * layers of a G00 window are included.
 }

    GListEnv = record
	ge_Screen	: ScreenPtr;
	ge_Window	: WindowPtr;
	ge_Requester	: RequesterPtr;
	ge_RastPort	: RastPortPtr;	{ rastport used to render gadget   }
	ge_Layer	: LayerPtr;	{ layer for gadget (border, if G00)}
	ge_GZZLayer	: LayerPtr;	{ interior layer for G00 windows   }
	ge_Pens		: PenPair;	{ pens for rendering gadget	    }
	ge_Domain	: IBox;
			{ window, screen, requester, rel. to window/screen }
	ge_GZZdims	: IBox;	{ interior window area		    }
    end;
    GListEnvPtr = ^GListEnv;

{ information for a gadget in its environment. includes relatively
 * correct size, container for propgadgets, correct layer for this gadget,
 * and back pointers to the environment and gadget itself
 }

    GadgetInfo = record
	gi_Environ	: GListEnvPtr;	{ environment for this gadget	    }
	gi_Gadget	: GadgetPtr;	{ gadget this info is for	    }
	gi_Box		: IBox;		{ actual dimensions of gadget	    }
	gi_Container	: IBox;		{ inner container dimensions	    }
	gi_Layer	: LayerPtr;	{ correct layer for this gadget    }
	gi_NewKnob	: IBox;		{ place to draw new slider knob    }
    end;
    GadgetInfoPtr = ^GadgetInfo;

Const
    NUM_IEVENTS		= 4;

{ ======================================================================== }
{ === IntuitionBase ====================================================== }
{ ======================================================================== }
{
 * Be sure to protect yourself against someone modifying these data as
 * you look at them.  This is done by calling:
 *
 * lock = LockIBase(0), which returns an Integer.  When done call
 * UnlockIBase(lock) where lock is what LockIBase() returned.
 }

Type

    IntuitionBase = record
{ IntuitionBase should never be directly modified by programs	}
{ even a little bit, guys/gals; do you hear me?	}

	LibNode		: Library;

	ViewLord	: View;

	ActiveWindow	: WindowPtr;
	ActiveScreen	: ScreenPtr;

    { the FirstScreen variable points to the frontmost Screen.	 Screens are
     * then maintained in a front to back order using Screen.NextScreen
     }

	FirstScreen	: ScreenPtr;	{ for linked list of all screens }

	Flags		: Integer;	{ see definitions below }
	MouseY,
	MouseX		: Short;	{ mouse position relative to View }

	Seconds		: Integer;	{ timestamp of most current input event }
	Micros		: Integer;	{ timestamp of most current input event }

    { The following is a snapshot of the "private" part of 
     * Intuition's library data.  It is included for educational
     * use and your debugging only.  It is absolutely guaranteed
     * that this structure will change from release to release.
     *
     * So: don't count on any of the values you find here
     *	   don't even think about changing any of these fields
     *	     (that goes for the "supported" fields above, too).
     *
     * Some work has been done to find the include files
     * that these fields depend on.
     *
     *			jimm: 9/10/86.
     }

	MinXMouse,
	MaxXMouse	: Short;	{ bounded X position for the mouse }
	MinYMouse,
	MaxYMouse	: Short;	{ bounded Y position for the mouse }

	StartSecs,
	StartMicros	: Integer;	{ measure double clicks }

    { --------------- base vectors ----------------------------------- }
    { DO MOVE THESE OFFSETS WITHOUT ADJUSTING EQUATES IN IWORK.ASM 
     * this is automatically handled by standalone program offsets.c
     }

	SysBase		: LibraryPtr;
	GfxBase		: LibraryPtr;
	LayersBase	: LibraryPtr;
	ConsoleDevice	: LibraryPtr;

    { --------------- Sprite Pointer --------------------------------- }
	APointer	: Address;  { the ActiveGroup pointer sprite definition	}
	APtrHeight	: Byte;	{ height of the pointer }
	APtrWidth	: Byte;	{ width in pixels of the pointer (<= 16!)	}
	AXOffset,
	AYOffset	: Byte; { sprite offsets }


    { ---------------- Menu Rendering and Operation ------------------ }
	MenuDrawn	: Short; { menu/item/sub number of current display }
	MenuSelected	: Short; { menu/item/sub number of selected (and highlights)}
	OptionList	: Short; { menu selection	}

    { this is the work RastPort used for building item and subitem displays
     *	you can never count on it being stable, other than that it is
     *	mostly a copy of the active screen's RastPort.
     }

	MenuRPort	: RastPort;
	MenuTmpRas	: TmpRas;
	ItemCRect	: ClipRect;	{ for the item's screen display }
	SubCRect	: ClipRect;	{ for the subitem's screen display }
	IBitMap		: BitMap;	{ for the item's planes }
	SBitMap		: BitMap;	{ for the subitem's planes }

    { ---------------- Input Device Interface ------------------------ }
	InputRequest	: IOStdReq;
	InputInterrupt	: Interrupt;

    { for dynamically allocated input events }
	EventKey	: RememberPtr;
	IEvents		: InputEventPtr;

    { for statically "allocated" input events }
	EventCount	: Short;
	IEBuffer	: Array [0..NUM_IEVENTS-1] of InputEvent;

    { ---------------- Active Gadget Information --------------------- }
	ActiveGadget	: GadgetPtr;
	ActivePInfo	: PropInfoPtr;
	ActiveImage	: ImagePtr;
	GadgetEnv	: GListEnv;	{ environment of the active gadget	}
	Gadget_Info	: GadgetInfo;	{ specific information for active gadget}
	KnobOffset	: Point;	{ position in knob of mouse when selected}

    { ---------------- Verify Functions Support ---------------------- }
    { hold information about getOK wait(), used for breakVerify() }
	getOKWindow	: WindowPtr;
	getOKMessage	: IntuiMessagePtr;

    { ---------------- State Machine --------------------------------- }
	setWExcept,
	GadgetReturn,
	StateReturn	: Short;

    { ----------- Intuition's Rendering for Gadgets, Titles, ... ----- }
    { This will be allocated on init }
	RP		: RastPortPtr;
	ITmpRas		: TmpRas;
	OldClipRegion	: Address;	{ (RegionPtr) locks with RPort }
	OldScroll	: Point;	{ user's Scroll_X/Y}

    { ----------- Frame Rendering for Window Size/Drag --------------- }
	IFrame		: IBox; { window frame for sizing/dragging	}
	hthick,
	vthick		: Short;	{ IFrame thickness		}
	frameChange	: Address;	{ function to change IFrame	}
	sizeDrag	: Address;	{ either ISizeWindow or IMoveWindow }
	FirstPt		: Point;	{ point from which s/d started }
	OldPt		: Point;	{ previous point for s/d	}

    { ---------------- System Gadget Templates ------------------------ }
	SysGadgets	: Array [0..RESCOUNT-1,0..GADGETCOUNT-1] of GadgetPtr;
	CheckImage,
	AmigaIcon	: Array [0..RESCOUNT-1] of ImagePtr;

    { ---------------- Window Drag Rendering ------------------------- }
	apattern	: Array [0..7] of Short;
	bpattern	: Array [0..3] of Short;

    { --- Preferences Section ---------------------------------------------- }
	IPointer	: Address;	{ the INTUITION pointer default sprite definition }
	IPtrHeight	: Byte;		{ height of the pointer }
	IPtrWidth	: Byte;		{ width in pixels of the pointer (<= 16!) }
	IXOffset,
	IYOffset	: Byte;		{ sprite offsets }

	DoubleSeconds,
	DoubleMicros	: Integer;	{ for testing double-click timeout }

    { ---------------- Border Widths --------------------------------- }
	WBorLeft	: Array [0..DMODECOUNT-1] of Byte;
	WBorTop		: Array [0..DMODECOUNT-1] of Byte;
	WBorRight	: Array [0..DMODECOUNT-1] of Byte;
	WBorBottom	: Array [0..DMODECOUNT-1] of Byte;

	BarVBorder	: Array [0..DMODECOUNT-1] of Byte;
	BarHBorder	: Array [0..DMODECOUNT-1] of Byte;
	MenuVBorder	: Array [0..DMODECOUNT-1] of Byte;
	MenuHBorder	: Array [0..DMODECOUNT-1] of Byte;

	color0		: Short;
	color1		: Short;
	color2		: Short;
	color3		: Short;
	color17		: Short;
	color18		: Short;
	color19		: Short;

	SysFont		: TextAttr;

    { WARNING:	 you can easily wipe out Intuition by modifying this pointer 
     * or the Preference data pointed to by this!
     }

	Preferences	: PreferencesPtr;

    { ----------------- Deferred action queue ---------------------- }
	Echoes		: Address;

	ViewInitX,
	ViewInitY	: Short;	{ View initial offsets at startup   }

	CursorDX,
	CursorDY	: Short;	{ for accelerating pointer movement }

	KeyMap		: Address;	{ for the active String Gadget }
    
	MouseYMinimum	: Short;	{ magic	}

	ErrorX,
	ErrorY		: Short;	{ for retaining mouse movement round-off }
    
	IOExcess	: timerequest;

	HoldMinYMouse	: Short;

	WBPort		: MsgPortPtr;
	iqd_FNKUHDPort	: MsgPortPtr;

	WBMessage	: IntuiMessage;
	HitScreen	: ScreenPtr;	{ set by hitUpfront() routine }

    {* jimm:dale: 11/25/85, thought we'd take a chance for glory *}
	SimpleSprite	: Address;
	AttachedSSprite	: Address;
	GotSprite1	: Boolean;

    {* jimm: 1/6/86: Intuition contention *}
	SemaphoreList	: List;	{ chain of the below }
	ISemaphore	: Array [0..NUMILOCKS-1] of SignalSemaphore;

	MaxDisplayHeight : Short;	{ in interlaced mode: 400 or 512 }
	MaxDisplayRow	: Short;	{ MaxDisplayHeight - 1		  }
	MaxDisplayWidth	: Short;	{ copy of GfxBase's NormalDisplayCol }

	Reserved	: Array [0..6] of Integer;
					{ cause one never know, do one? }
    end;
    IntuitionBasePtr = ^IntuitionBase;

