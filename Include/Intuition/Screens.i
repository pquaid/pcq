{
	Screens.i for PCQ Pascal
}

{$I "Include:Graphics/Gfx.i"}
{$I "Include:Graphics/Clip.i"}
{$I "Include:Graphics/View.i"}
{$I "Include:Graphics/RastPort.i"}
{$I "Include:Graphics/Layers.i"}
{$I "Include:Graphics/Text.i"}

{ ======================================================================== }
{ === Screen ============================================================= }
{ ======================================================================== }

Type

    Screen = record
	NextScreen	: ^Screen;	{ linked list of screens }
	FirstWindow	: Address;	{ linked list Screen's Windows }

	LeftEdge,
	TopEdge		: Short;	{ parameters of the screen }
	Width,
	Height		: Short;	{ parameters of the screen }

	MouseY,
	MouseX		: Short;	{ position relative to upper-left }

	Flags		: Short;	{ see definitions below }

	Title		: String;	{ null-terminated Title text }
	DefaultTitle	: String;	{ for Windows without ScreenTitle }

    { Bar sizes for this Screen and all Window's in this Screen }
	BarHeight,
	BarVBorder,
	BarHBorder,
	MenuVBorder,
	MenuHBorder	: Byte;
	WBorTop,
	WBorLeft,
	WBorRight,
	WBorBottom	: Byte;

	Font		: TextAttrPtr;	{ this screen's default font	   }

    { the display data structures for this Screen (note the prefix S)}
	SViewPort	: ViewPort;	{ describing the Screen's display }
	SRastPort	: RastPort;	{ describing Screen rendering	   }
	SBitMap		: BitMap;	{ extra copy of RastPort BitMap   }
	LayerInfo	: Layer_Info;	{ each screen gets a LayerInfo	   }

    { You supply a linked-list of Gadgets for your Screen.
     *	This list DOES NOT include system Gadgets.  You get the standard
     *	system Screen Gadgets by default
     }

	FirstGadget	: Address;

	DetailPen,
	BlockPen	: Byte;		{ for bar/border/gadget rendering }

    { the following variable(s) are maintained by Intuition to support the
     * DisplayBeep() color flashing technique
     }
	SaveColor0	: Short;

    { This layer is for the Screen and Menu bars }
	BarLayer	: LayerPtr;

	ExtData		: Address;
	UserData	: Address;
			{ general-purpose pointer to User data extension }
    end;
    ScreenPtr = ^Screen;


Const

{ The screen flags have the suffix "_f" added to avoid conflicts with
  routine names. }

{ --- FLAGS SET BY INTUITION --------------------------------------------- }
{ The SCREENTYPE bits are reserved for describing various Screen types
 * available under Intuition.  
 }
    SCREENTYPE_f	= $000F;	{ all the screens types available	}
{ --- the definitions for the Screen Type ------------------------------- }
    WBENCHSCREEN_f	= $0001;	{ Ta Da!  The Workbench		}
    CUSTOMSCREEN_f	= $000F;	{ for that special look		}

    SHOWTITLE_f		= $0010;	{ this gets set by a call to ShowTitle() }

    BEEPING_f		= $0020;	{ set when Screen is beeping		}

    CUSTOMBITMAP_f	= $0040;	{ if you are supplying your own BitMap }

    SCREENBEHIND_f	= $0080;	{ if you want your screen to open behind
					 * already open screens
					 }
    SCREENQUIET_f	= $0100;	{ if you do not want Intuition to render
					 * into your screen (gadgets, title)
					 }

    STDSCREENHEIGHT	= -1;		{ supply in NewScreen.Height		}


{ ======================================================================== }
{ === NewScreen ========================================================== }
{ ======================================================================== }

Type

    NewScreen = record
	LeftEdge,
	TopEdge,
	Width,
	Height,
	Depth		: Short;	{ screen dimensions }

	DetailPen,
	BlockPen	: Byte;		{ for bar/border/gadget rendering }

	ViewModes	: Short;	{ the Modes for the ViewPort (and View) }

	SType		: Short;	{ the Screen type (see defines above) }
    
	Font		: TextAttrPtr;	{ this Screen's default text attributes }
    
	DefaultTitle	: String;	{ the default title for this Screen }
    
	Gadgets		: Address;	{ your own Gadgets for this Screen }
    
    { if you are opening a CUSTOMSCREEN and already have a BitMap 
     * that you want used for your Screen, you set the flags CUSTOMBITMAP in
     * the Type field and you set this variable to point to your BitMap
     * structure.  The structure will be copied into your Screen structure,
     * after which you may discard your own BitMap if you want
     }

	CustomBitMap	: BitMapPtr;
    end;
    NewScreenPtr = ^NewScreen;
