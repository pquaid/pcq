{
	Intuition.i for PCQ Pascal

	main intuition include file
}

{$I "Include:Graphics/Gfx.i"}
{$I "Include:Graphics/Clip.i"}
{$I "Include:Graphics/View.i"}
{$I "Include:Graphics/RastPort.i"}
{$I "Include:Graphics/Layers.i"}
{$I "Include:Graphics/Text.i"}
{$I "Include:Exec/Ports.i"}
{$I "Include:Devices/Timer.i"}
{$I "Include:Devices/InputEvent.i"}

{ Intuition/Screens and Intuition/Preferences are included later on
  in this file }

Type

{ ======================================================================== }
{ === IntuiText ========================================================== }
{ ======================================================================== }
{ IntuiText is a series of strings that start with a screen location
 *  (always relative to the upper-left corner of something) and then the
 *  text of the string.	 The text is null-terminated.
 }

    IntuiText = record
	FrontPen,
	BackPen		: Byte;		{ the pen numbers for the rendering }
	DrawMode	: Byte;		{ the mode for rendering the text }
	LeftEdge	: Short;	{ relative start location for the text }
	TopEdge		: Short;	{ relative start location for the text }
	ITextFont	: TextAttrPtr;	{ if NULL, you accept the default }
	IText		: String;	{ pointer to null-terminated text }
	NextText	: ^IntuiText;	{ continuation to TxWrite another text }
    end;
    IntuiTextPtr = ^IntuiText;



{ ======================================================================== }
{ === Border ============================================================= }
{ ======================================================================== }
{ Data type Border, used for drawing a series of lines which is intended for
 *  use as a border drawing, but which may, in fact, be used to render any
 *  arbitrary vector shape.
 *  The routine DrawBorder sets up the RastPort with the appropriate
 *  variables, then does a Move to the first coordinate, then does Draws
 *  to the subsequent coordinates.
 *  After all the Draws are done, if NextBorder is non-zero we call DrawBorder
 *  recursively
 }

    Border = record
	LeftEdge,
	TopEdge		: Short;	{ initial offsets from the origin }
	FrontPen,
	BackPen		: Byte;		{ pens numbers for rendering }
	DrawMode	: Byte;		{ mode for rendering }
	Count		: Byte;		{ number of XY pairs }
	XY		: Address;	{ vector coordinate pairs rel to LeftTop}
	NextBorder	: ^Border;	{ pointer to any other Border too }
    end;
    BorderPtr = ^Border;





{ ======================================================================== }
{ === Image ============================================================== }
{ ======================================================================== }
{ This is a brief image structure for very simple transfers of 
 * image data to a RastPort
 }

Type

    Image = record
	LeftEdge	: Short;	{ starting offset relative to some origin }
	TopEdge		: Short;	{ starting offsets relative to some origin }
	Width		: Short;	{ pixel size (though data is word-aligned) }
	Height,
	Depth		: Short;	{ pixel sizes }
	ImageData	: Address;	{ pointer to the actual word-aligned bits }

    { the PlanePick and PlaneOnOff variables work much the same way as the
     * equivalent GELS Bob variables.  It's a space-saving 
     * mechanism for image data.  Rather than defining the image data
     * for every plane of the RastPort, you need define data only 
     * for the planes that are not entirely zero or one.  As you 
     * define your Imagery, you will often find that most of the planes 
     * ARE just as color selectors.  For instance, if you're designing 
     * a two-color Gadget to use colors two and three, and the Gadget 
     * will reside in a five-plane display, bit plane zero of your 
     * imagery would be all ones, bit plane one would have data that 
     * describes the imagery, and bit planes two through four would be 
     * all zeroes.  Using these flags allows you to avoid wasting all 
     * that memory in this way:	 first, you specify which planes you 
     * want your data to appear in using the PlanePick variable.  For 
     * each bit set in the variable, the next "plane" of your image 
     * data is blitted to the display.	For each bit clear in this 
     * variable, the corresponding bit in PlaneOnOff is examined.  
     * If that bit is clear, a "plane" of zeroes will be used.	
     * If the bit is set, ones will go out instead.  So, for our example:
     *	 Gadget.PlanePick = 0x02;
     *	 Gadget.PlaneOnOff = 0x01;
     * Note that this also allows for generic Gadgets, like the 
     * System Gadgets, which will work in any number of bit planes.  
     * Note also that if you want an Image that is only a filled 
     * rectangle, you can get this by setting PlanePick to zero 
     * (pick no planes of data) and set PlaneOnOff to describe the pen 
     * color of the rectangle.	
     }

	PlanePick,
	PlaneOnOff	: Byte;

    { if the NextImage variable is not NULL, Intuition presumes that 
     * it points to another Image structure with another Image to be 
     * rendered
     }

	NextImage	: ^Image;
    end;
    ImagePtr = ^Image;



{ ======================================================================== }
{ === MenuItem =========================================================== }
{ ======================================================================== }

Type

    MenuItem = record
	NextItem	: ^MenuItem;	{ pointer to next in chained list } 
	LeftEdge,
	TopEdge		: Short;	{ position of the select box } 
	Width,
	Height		: Short;	{ dimensions of the select box } 
	Flags		: Short;	{ see the defines below } 
 
	MutualExclude	: Integer;	{ set bits mean this item excludes that } 
 
	ItemFill	: Address;	{ points to Image, IntuiText, or NULL } 
 
    { when this item is pointed to by the cursor and the items highlight 
     *	mode HIGHIMAGE is selected, this alternate image will be displayed 
     }

	SelectFill	: Address;	{ points to Image, IntuiText, or NULL }

	Command		: Char;		{ only if appliprog sets the COMMSEQ flag }

	SubItem		: ^MenuItem;	{ if non-zero, DrawMenu shows "->" }

    { The NextSelect field represents the menu number of next selected 
     *	item (when user has drag-selected several items)
     }

	NextSelect	: Short;
    end;
    MenuItemPtr = ^MenuItem;

Const

{ FLAGS SET BY THE APPLIPROG } 
    CHECKIT	= $0001;	{ whether to check this item if selected } 
    ITEMTEXT	= $0002;	{ set if textual, clear if graphical item } 
    COMMSEQ	= $0004;	{ set if there's an command sequence } 
    MENUTOGGLE	= $0008;	{ set to toggle the check of a menu item } 
    ITEMENABLED	= $0010;	{ set if this item is enabled } 
 
{ these are the SPECIAL HIGHLIGHT FLAG state meanings } 
    HIGHFLAGS	= $00C0;	{ see definitions below for these bits } 
    HIGHIMAGE	= $0000;	{ use the user's "select image" } 
    HIGHCOMP	= $0040;	{ highlight by complementing the selectbox }
    HIGHBOX	= $0080;	{ highlight by "boxing" the selectbox } 
    HIGHNONE	= $00C0;	{ don't highlight } 
 
{ FLAGS SET BY BOTH APPLIPROG AND INTUITION } 
    CHECKED	= $0100;	{ if CHECKIT, then set this when selected } 
 
{ FLAGS SET BY INTUITION } 
    ISDRAWN	= $1000;	{ this item's subs are currently drawn } 
    HIGHITEM	= $2000;	{ this item is currently highlighted } 
    MENUTOGGLED	= $4000;	{ this item was already toggled } 
 

Type

{ ======================================================================== }
{ === Menu =============================================================== }
{ ======================================================================== }

    Menu = record
	NextMenu	: ^Menu;	{ same level }
	LeftEdge,
	TopEdge		: Short;	{ position of the select box }
	Width,
	Height		: Short;	{ dimensions of the select box }
	Flags		: Short;	{ see flag definitions below }
	MenuName	: String;	{ text for this Menu Header }
	FirstItem	: MenuItemPtr;	{ pointer to first in chain }

    { these mysteriously-named variables are for internal use only }

	JazzX,
	JazzY,
	BeatX,
	BeatY		: Short;
    end;
    MenuPtr = ^Menu;


Const

{ FLAGS SET BY BOTH THE APPLIPROG AND INTUITION }
    MENUENABLED	= $0001;	{ whether or not this menu is enabled }

{ FLAGS SET BY INTUITION }
    MIDRAWN	= $0100;	{ this menu's items are currently drawn } 



{ ======================================================================== }
{ === Gadget ============================================================= }
{ ======================================================================== }

Type

    Gadget = record
	NextGadget	: ^Gadget;	{ next gadget in the list }

	LeftEdge,
	TopEdge		: Short;	{ "hit box" of gadget }
	Width,
	Height		: Short;	{ "hit box" of gadget }

	Flags		: Short;	{ see below for list of defines }

	Activation	: Short;	{ see below for list of defines }

	GadgetType	: Short;	{ see below for defines }

    { appliprog can specify that the Gadget be rendered as either as Border
     * or an Image.  This variable points to which (or equals NULL if there's
     * nothing to be rendered about this Gadget)
     }

	GadgetRender	: Address;

    { appliprog can specify "highlighted" imagery rather than algorithmic
     * this can point to either Border or Image data
     }

	SelectRender	: Address;

	GadgetText	: IntuiTextPtr;	{ text for this gadget }

    { by using the MutualExclude word, the appliprog can describe 
     * which gadgets mutually-exclude which other ones.	 The bits 
     * in MutualExclude correspond to the gadgets in object containing 
     * the gadget list.	 If this gadget is selected and a bit is set 
     * in this gadget's MutualExclude and the gadget corresponding to 
     * that bit is currently selected (e.g. bit 2 set and gadget 2 
     * is currently selected) that gadget must be unselected.  
     * Intuition does the visual unselecting (with checkmarks) and 
     * leaves it up to the program to unselect internally
     }

	MutualExclude	: Integer;	{ set bits mean this gadget excludes that gadget }

    { pointer to a structure of special data required by Proportional, 
     * String and Integer Gadgets 
     }

	SpecialInfo	: Address;

	GadgetID	: Short;	{ user-definable ID field }
	UserData	: Address;	{ ptr to general purpose User data (ignored by In) }
    end;
    GadgetPtr = ^Gadget;


Const

{ --- FLAGS SET BY THE APPLIPROG ----------------------------------------- }
{ combinations in these bits describe the highlight technique to be used }

    GADGHIGHBITS	= $0003;
    GADGHCOMP		= $0000;	{ Complement the select box }
    GADGHBOX		= $0001;	{ Draw a box around the image }
    GADGHIMAGE		= $0002;	{ Blast in this alternate image }
    GADGHNONE		= $0003;	{ don't highlight }

{ set this flag if the GadgetRender and SelectRender point to Image imagery, 
 * clear if it's a Border 
 }

    GADGIMAGE 		= $0004;

{ combinations in these next two bits specify to which corner the gadget's
 *  Left & Top coordinates are relative.  If relative to Top/Left,
 *  these are "normal" coordinates (everything is relative to something in
 *  this universe)
 }

    GRELBOTTOM		= $0008;	{ set if rel to bottom, clear if rel top }
    GRELRIGHT		= $0010;	{ set if rel to right, clear if to left }
{ set the RELWIDTH bit to spec that Width is relative to width of screen }
    GRELWIDTH		= $0020;
{ set the RELHEIGHT bit to spec that Height is rel to height of screen }
    GRELHEIGHT		= $0040;

{ the SELECTED flag is initialized by you and set by Intuition.  It 
 * specifies whether or not this Gadget is currently selected/highlighted
 }
    SELECTED		= $0080;


{ the GADGDISABLED flag is initialized by you and later set by Intuition
 * according to your calls to On/OffGadget().  It specifies whether or not 
 * this Gadget is currently disabled from being selected
 }
    GADGDISABLED	= $0100;


{ --- These are the Activation flag bits --------------------------------- }
{ RELVERIFY is set if you want to verify that the pointer was still over
 *  the gadget when the select button was released
 }
    RELVERIFY		= $0001;

{ the flag GADGIMMEDIATE, when set, informs the caller that the gadget
 *  was activated when it was activated.  this flag works in conjunction with
 *  the RELVERIFY flag
 }
    GADGIMMEDIATE	= $0002;

{ the flag ENDGADGET, when set, tells the system that this gadget, when
 * selected, causes the Requester or AbsMessage to be ended.  Requesters or
 *  AbsMessages that are ended are erased and unlinked from the system }

    ENDGADGET		= $0004;

{ the FOLLOWMOUSE flag, when set, specifies that you want to receive
 * reports on mouse movements (ie, you want the REPORTMOUSE function for
 * your Window).  When the Gadget is deselected (immediately if you have
 * no RELVERIFY) the previous state of the REPORTMOUSE flag is restored
 * You probably want to set the GADGIMMEDIATE flag when using FOLLOWMOUSE,
 * since that's the only reasonable way you have of learning why Intuition
 * is suddenly sending you a stream of mouse movement events.  If you don't
 * set RELVERIFY, you'll get at least one Mouse Position event.
 }

    FOLLOWMOUSE		= $0008;

{ if any of the BORDER flags are set in a Gadget that's included in the
 * Gadget list when a Window is opened, the corresponding Border will
 * be adjusted to make room for the Gadget
 }

    RIGHTBORDER		= $0010;
    LEFTBORDER		= $0020;
    TOPBORDER		= $0040;
    BOTTOMBORDER	= $0080;

    TOGGLESELECT	= $0100;	{ this bit for toggle-select mode }

    STRINGCENTER	= $0200;	{ should be a StringInfo flag, but it's OK }
    STRINGRIGHT		= $0400;	{ should be a StringInfo flag, but it's OK }

    LONGINT		= $0800;	{ this String Gadget is actually LONG Int }

    ALTKEYMAP		= $1000;	{ this String has an alternate keymap }

    BOOLEXTEND		= $2000;	{ this Boolean Gadget has a BoolInfo	}


{ --- GADGET TYPES ------------------------------------------------------- }
{ These are the Gadget Type definitions for the variable GadgetType
 * gadget number type MUST start from one.  NO TYPES OF ZERO ALLOWED.
 * first comes the mask for Gadget flags reserved for Gadget typing
 }

    GADGETTYPE		= $FC00;	{ all Gadget Global Type flags (padded) }
    SYSGADGET		= $8000;	{ 1 = SysGadget, 0 = AppliGadget }
    SCRGADGET		= $4000;	{ 1 = ScreenGadget, 0 = WindowGadget }
    GZZGADGET		= $2000;	{ 1 = Gadget for GIMMEZEROZERO borders }
    REQGADGET		= $1000;	{ 1 = this is a Requester Gadget }

{ system gadgets }

    SIZING		= $0010;
    WDRAGGING		= $0020;
    SDRAGGING		= $0030;
    WUPFRONT		= $0040;
    SUPFRONT		= $0050;
    WDOWNBACK		= $0060;
    SDOWNBACK		= $0070;
    CLOSE_f		= $0080;

{ application gadgets }

    BOOLGADGET		= $0001;
    GADGET0002		= $0002;
    PROPGADGET		= $0003;
    STRGADGET		= $0004;


Type

{ ======================================================================== }
{ === BoolInfo======================================================= }
{ ======================================================================== }
{ This is the special data needed by an Extended Boolean Gadget
 * Typically this structure will be pointed to by the Gadget field SpecialInfo
 }

    BoolInfo = record
	Flags	: Short;	{ defined below }
	Mask	: Address; { bit mask for highlighting and selecting
			 * mask must follow the same rules as an Image
			 * plane.  It's width and height are determined
			 * by the width and height of the gadget's 
			 * select box. (i.e. Gadget.Width and .Height).
			 }
	Reserved : Integer;	{ set to 0	}
    end;
    BoolInfoPtr = ^BoolInfo;


Const

{ set BoolInfo.Flags to this flag bit.
 * in the future, additional bits might mean more stuff hanging
 * off of BoolInfo.Reserved.
}
    BOOLMASK	= $0001;	{ extension is for masked gadget }

{ ======================================================================== }
{ === PropInfo =========================================================== }
{ ======================================================================== }
{ this is the special data required by the proportional Gadget
 * typically, this data will be pointed to by the Gadget variable SpecialInfo
 }

Type

    PropInfo = record
	Flags	: Short;	{ general purpose flag bits (see defines below) }

    { You initialize the Pot variables before the Gadget is added to 
     * the system.  Then you can look here for the current settings 
     * any time, even while User is playing with this Gadget.  To 
     * adjust these after the Gadget is added to the System, use 
     * ModifyProp();  The Pots are the actual proportional settings, 
     * where a value of zero means zero and a value of MAXPOT means 
     * that the Gadget is set to its maximum setting.  
     }

	HorizPot	: Short; { 16-bit FixedPoint horizontal quantity percentage }
	VertPot		: Short; { 16-bit FixedPoint vertical quantity percentage }

    { the 16-bit FixedPoint Body variables describe what percentage of 
     * the entire body of stuff referred to by this Gadget is actually 
     * shown at one time.  This is used with the AUTOKNOB routines, 
     * to adjust the size of the AUTOKNOB according to how much of 
     * the data can be seen.  This is also used to decide how far 
     * to advance the Pots when User hits the Container of the Gadget.	
     * For instance, if you were controlling the display of a 5-line 
     * Window of text with this Gadget, and there was a total of 15 
     * lines that could be displayed, you would set the VertBody value to 
     *	   (MAXBODY / (TotalLines / DisplayLines)) = MAXBODY / 3.
     * Therefore, the AUTOKNOB would fill 1/3 of the container, and 
     * if User hits the Cotainer outside of the knob, the pot would 
     * advance 1/3 (plus or minus) If there's no body to show, or 
     * the total amount of displayable info is less than the display area, 
     * set the Body variables to the MAX.  To adjust these after the 
     * Gadget is added to the System, use ModifyProp();	 
     }

	HorizBody	: Short;	{ horizontal Body } 
	VertBody	: Short;	{ vertical Body }

    { these are the variables that Intuition sets and maintains }

	CWidth		: Short;	{ Container width (with any relativity absoluted) }
	CHeight		: Short;	{ Container height (with any relativity absoluted) }
	HPotRes,
	VPotRes		: Short;	{ pot increments }
	LeftBorder	: Short;	{ Container borders }
	TopBorder	: Short;	{ Container borders }
    end;
    PropInfoPtr = ^PropInfo;

Const

{ --- FLAG BITS ---------------------------------------------------------- }
    AUTOKNOB		= $0001;	{ this flag sez:  gimme that old auto-knob }
    FREEHORIZ		= $0002;	{ if set, the knob can move horizontally }
    FREEVERT		= $0004;	{ if set, the knob can move vertically }
    PROPBORDERLESS	= $0008;	{ if set, no border will be rendered }
    KNOBHIT		= $0100;	{ set when this Knob is hit }

    KNOBHMIN		= 6;		{ minimum horizontal size of the Knob }
    KNOBVMIN		= 4;		{ minimum vertical size of the Knob }
    MAXBODY		= -1;		{ maximum body value }
    MAXPOT		= -1;		{ maximum pot value }



{ ======================================================================== }
{ === StringInfo ========================================================= }
{ ======================================================================== }
{ this is the special data required by the string Gadget
 * typically, this data will be pointed to by the Gadget variable SpecialInfo
 }

Type

    StringInfo = record
    { you initialize these variables, and then Intuition maintains them }
	Buffer		: String;	{ the buffer containing the start and final string }
	UndoBuffer	: String;	{ optional buffer for undoing current entry }
	BufferPos	: Short;	{ character position in Buffer }
	MaxChars	: Short;	{ max number of chars in Buffer (including NULL) }
	DispPos		: Short;	{ Buffer position of first displayed character }

    { Intuition initializes and maintains these variables for you }

	UndoPos		: Short;	{ character position in the undo buffer }
	NumChars	: Short;	{ number of characters currently in Buffer }
	DispCount	: Short;	{ number of whole characters visible in Container }
	CLeft,
	CTop		: Short;	{ topleft offset of the container }
	Layer		: LayerPtr;	{ the RastPort containing this Gadget }

    { you can initialize this variable before the gadget is submitted to
     * Intuition, and then examine it later to discover what integer 
     * the user has entered (if the user never plays with the gadget, 
     * the value will be unchanged from your initial setting)
     }

	LongInt		: Integer;

    { If you want this Gadget to use your own Console keymapping, you
     * set the ALTKEYMAP bit in the Activation flags of the Gadget, and then
     * set this variable to point to your keymap.  If you don't set the
     * ALTKEYMAP, you'll get the standard ASCII keymapping.
     }

	AltKeyMap	: Address;
    end;
    StringInfoPtr = ^StringInfo;



{ ======================================================================== }
{ === Requester ========================================================== }
{ ======================================================================== }

Type

    Requester = record
    { the ClipRect and BitMap and used for rendering the requester }
	OlderRequest	: ^Requester;
	LeftEdge,
	TopEdge		: Short;	{ dimensions of the entire box }
	Width,
	Height		: Short;	{ dimensions of the entire box }
	RelLeft,
	RelTop		: Short;	{ for Pointer relativity offsets }

	ReqGadget	: GadgetPtr;	{ pointer to a list of Gadgets }
	ReqBorder	: BorderPtr;	{ the box's border }
	ReqText		: IntuiTextPtr;	{ the box's text }
	Flags		: Short;	{ see definitions below }

    { pen number for back-plane fill before draws }

	BackFill	: Byte;

    { Layer in place of clip rect	}

	ReqLayer	: LayerPtr;

	ReqPad1		: Array [0..31] of Byte;

    { If the BitMap plane pointers are non-zero, this tells the system 
     * that the image comes pre-drawn (if the appliprog wants to define 
     * it's own box, in any shape or size it wants!);  this is OK by 
     * Intuition as long as there's a good correspondence between 
     * the image and the specified Gadgets
     }

	ImageBMap	: BitMapPtr;	{ points to the BitMap of PREDRAWN imagery }
	RWindow		: Address;	{ added.  points back to Window }
	ReqPad2		: Array [0..35] of Byte;
    end;
    RequesterPtr = ^Requester;

Const

{ FLAGS SET BY THE APPLIPROG }
    POINTREL 		= $0001;    { if POINTREL set, TopLeft is relative to pointer}
    PREDRAWN 		= $0002;    { if ReqBMap points to predrawn Requester imagery }
    NOISYREQ 		= $0004;    { if you don't want requester to filter input	   }
{ FLAGS SET BY BOTH THE APPLIPROG AND INTUITION }

{ FLAGS SET BY INTUITION }
    REQOFFWINDOW	= $1000;	{ part of one of the Gadgets was offwindow }
    REQACTIVE		= $2000;	{ this requester is active }
    SYSREQUEST		= $4000;	{ this requester caused by system }
    DEFERREFRESH	= $8000;	{ this Requester stops a Refresh broadcast }



{ ======================================================================== }
{ === IntuiMessage ======================================================= }
{ ======================================================================== }

Type

    IntuiMessage = record
	ExecMessage	: Message;

    { the Class bits correspond directly with the IDCMP Flags, except for the
     * special bit LONELYMESSAGE (defined below)
     }

	Class		: Integer;

    { the Code field is for special values like MENU number }

	Code		: Short;

    { the Qualifier field is a copy of the current InputEvent's Qualifier }

	Qualifier	: Short;

    { IAddress contains particular addresses for Intuition functions, like
     * the pointer to the Gadget or the Screen
     }

	IAddress	: Address;

    { when getting mouse movement reports, any event you get will have the
     * the mouse coordinates in these variables.  the coordinates are relative
     * to the upper-left corner of your Window (GIMMEZEROZERO notwithstanding)
     }

	MouseX,
	MouseY		: Short;

    { the time values are copies of the current system clock time.  Micros
     * are in units of microseconds, Seconds in seconds.
     }

	Seconds,
	Micros		: Integer;

    { the IDCMPWindow variable will always have the address of the Window of 
     * this IDCMP 
     }

	IDCMPWindow	: Address;

    { system-use variable }

	SpecialLink	: ^IntuiMessage;
    end;
    IntuiMessagePtr = ^IntuiMessage;


Const

{ All the IDCMP flags in PCQ Pascal are suffixed by "_f" to
  differentiate them from the Intuition routines of similar names }

{ --- IDCMP Classes ------------------------------------------------------ }
    SIZEVERIFY_f	= $00000001;  {	See the Programmer's Guide  }
    NEWSIZE_f		= $00000002;  {	See the Programmer's Guide  }
    REFRESHWINDOW_f	= $00000004;  {	See the Programmer's Guide  }
    MOUSEBUTTONS_f	= $00000008;  {	See the Programmer's Guide  }
    MOUSEMOVE_f		= $00000010;  {	See the Programmer's Guide  }
    GADGETDOWN_f	= $00000020;  {	See the Programmer's Guide  }
    GADGETUP_f		= $00000040;  {	See the Programmer's Guide  }
    REQSET_f		= $00000080;  {	See the Programmer's Guide  }
    MENUPICK_f		= $00000100;  {	See the Programmer's Guide  }
    CLOSEWINDOW_f	= $00000200;  {	See the Programmer's Guide  }
    RAWKEY_f		= $00000400;  {	See the Programmer's Guide  }
    REQVERIFY_f		= $00000800;  {	See the Programmer's Guide  }
    REQCLEAR_f		= $00001000;  {	See the Programmer's Guide  }
    MENUVERIFY_f	= $00002000;  {	See the Programmer's Guide  }
    NEWPREFS_f		= $00004000;  {	See the Programmer's Guide  }
    DISKINSERTED_f	= $00008000;  {	See the Programmer's Guide  }
    DISKREMOVED_f	= $00010000;  {	See the Programmer's Guide  }
    WBENCHMESSAGE_f	= $00020000;  {	See the Programmer's Guide  }
    ACTIVEWINDOW_f	= $00040000;  {	See the Programmer's Guide  }
    INACTIVEWINDOW_f	= $00080000;  {	See the Programmer's Guide  }
    DELTAMOVE_f		= $00100000;  {	See the Programmer's Guide  }
    VANILLAKEY_f	= $00200000;  {	See the Programmer's Guide  }
    INTUITICKS_f	= $00400000;  {	See the Programmer's Guide  }

{ NOTEZ-BIEN:			0x80000000 is reserved for internal use	  }

{ the IDCMP Flags do not use this special bit, which is cleared when
 * Intuition sends its special message to the Task, and set when Intuition
 * gets its Message back from the Task.	 Therefore, I can check here to
 * find out fast whether or not this Message is available for me to send
 }
    LONELYMESSAGE_f	= $80000000;


{ --- IDCMP Codes -------------------------------------------------------- }
{ This group of codes is for the MENUVERIFY function }

    MENUHOT		= $0001;  { IntuiWants verification or MENUCANCEL    }
    MENUCANCEL		= $0002;  { HOT Reply of this cancels Menu operation }
    MENUWAITING		= $0003;  { Intuition simply wants a ReplyMsg() ASAP }

{ These are internal tokens to represent state of verification attempts
 * shown here as a clue.
 }

    OKOK		= MENUHOT; { guy didn't care			}
    OKABORT		= $0004;   { window rendered question moot	}
    OKCANCEL		= MENUCANCEL; { window sent cancel reply	}

{ This group of codes is for the WBENCHMESSAGE messages }
    WBENCHOPEN		= $0001;
    WBENCHCLOSE		= $0002;



{ ======================================================================== }
{ === Window ============================================================= }
{ ======================================================================== }

Type

    Window = record
	NextWindow	: ^Window;	{ for the linked list in a screen }

	LeftEdge,
	TopEdge		: Short;	{ screen dimensions of window }
	Width,
	Height		: Short;	{ screen dimensions of window }

	MouseY,
	MouseX		: Short;	{ relative to upper-left of window }

	MinWidth,
	MinHeight	: Short;	{ minimum sizes }
	MaxWidth,
	MaxHeight	: Short;	{ maximum sizes }

	Flags		: Integer;	{ see below for defines }

	MenuStrip	: MenuPtr;	{ the strip of Menu headers }

	Title		: String;	{ the title text for this window }

	FirstRequest	: RequesterPtr;	{ all active Requesters }

	DMRequest	: RequesterPtr;	{ double-click Requester }

	ReqCount	: Short;	{ count of reqs blocking Window }

	WScreen		: Address;	{ this Window's Screen }
	RPort		: RastPortPtr;	{ this Window's very own RastPort }

    { the border variables describe the window border.	 If you specify
     * GIMMEZEROZERO when you open the window, then the upper-left of the
     * ClipRect for this window will be upper-left of the BitMap (with correct
     * offsets when in SuperBitMap mode; you MUST select GIMMEZEROZERO when
     * using SuperBitMap).  If you don't specify ZeroZero, then you save
     * memory (no allocation of RastPort, Layer, ClipRect and associated
     * Bitmaps), but you also must offset all your writes by BorderTop,
     * BorderLeft and do your own mini-clipping to prevent writing over the
     * system gadgets
     }

	BorderLeft,
	BorderTop,
	BorderRight,
	BorderBottom	: Byte;
	BorderRPort	: RastPortPtr;


    { You supply a linked-list of Gadgets for your Window.
     * This list DOES NOT include system gadgets.  You get the standard
     * window system gadgets by setting flag-bits in the variable Flags (see
     * the bit definitions below)
     }

	FirstGadget	: GadgetPtr;

    { these are for opening/closing the windows }

	Parent,
	Descendant	: ^Window;

    { sprite data information for your own Pointer
     * set these AFTER you Open the Window by calling SetPointer()
     }

	Pointer		: Address;	{ sprite data }
	PtrHeight	: Byte;		{ sprite height (not including sprite padding) }
	PtrWidth	: Byte;		{ sprite width (must be less than or equal to 16) }
	XOffset,
	YOffset		: Byte;		{ sprite offsets }

    { the IDCMP Flags and User's and Intuition's Message Ports }
	IDCMPFlags	: Integer;	{ User-selected flags }
	UserPort,
	WindowPort	: MsgPortPtr;
	MessageKey	: IntuiMessagePtr;

	DetailPen,
	BlockPen	: Byte;	{ for bar/border/gadget rendering }

    { the CheckMark is a pointer to the imagery that will be used when 
     * rendering MenuItems of this Window that want to be checkmarked
     * if this is equal to NULL, you'll get the default imagery
     }

	CheckMark	: ImagePtr;

	ScreenTitle	: String; { if non-null, Screen title when Window is active }

    { These variables have the mouse coordinates relative to the 
     * inner-Window of GIMMEZEROZERO Windows.  This is compared with the
     * MouseX and MouseY variables, which contain the mouse coordinates
     * relative to the upper-left corner of the Window, GIMMEZEROZERO
     * notwithstanding
     }

	GZZMouseX	: Short;
	GZZMouseY	: Short;

    { these variables contain the width and height of the inner-Window of
     * GIMMEZEROZERO Windows
     }

	GZZWidth	: Short;
	GZZHeight	: Short;

	ExtData		: Address;

	UserData	: Address;	{ general-purpose pointer to User data extension }

    {* jimm: NEW: 11/18/85: this pointer keeps a duplicate of what 
     * Window.RPort->Layer is _supposed_ to be pointing at
     }

	WLayer		: LayerPtr;

    { jimm: NEW 1.2: need to keep track of the font that
     * OpenWindow opened, in case user SetFont's into RastPort
     }

	IFont		: TextFontPtr;
    end;
    WindowPtr = ^Window;

Const

{ --- FLAGS REQUESTED (NOT DIRECTLY SET THOUGH) BY THE APPLIPROG --------- }
    WINDOWSIZING	= $0001;	{ include sizing system-gadget? }
    WINDOWDRAG		= $0002;	{ include dragging system-gadget? }
    WINDOWDEPTH		= $0004;	{ include depth arrangement gadget? }
    WINDOWCLOSE		= $0008;	{ include close-box system-gadget? }

    SIZEBRIGHT		= $0010;	{ size gadget uses right border }
    SIZEBBOTTOM		= $0020;	{ size gadget uses bottom border }

{ --- refresh modes ------------------------------------------------------ }
{ combinations of the REFRESHBITS select the refresh type }
    REFRESHBITS		= $00C0;
    SMART_REFRESH	= $0000;
    SIMPLE_REFRESH	= $0040;
    SUPER_BITMAP	= $0080;
    OTHER_REFRESH	= $00C0;

    BACKDROP		= $0100;   { this is an ever-popular BACKDROP window }

    REPORTMOUSE_f	= $0200;   { set this to hear about every mouse move }

    GIMMEZEROZERO	= $0400;   { make extra border stuff }

    BORDERLESS		= $0800;   { set this to get a Window sans border }

    ACTIVATE		= $1000;   { when Window opens, it's the Active one }

{ FLAGS SET BY INTUITION }
    WINDOWACTIVE  	= $2000;   { this window is the active one }
    INREQUEST     	= $4000;   { this window is in request mode }
    MENUSTATE     	= $8000;   { this Window is active with its Menus on }

{ --- Other User Flags --------------------------------------------------- }
    RMBTRAP		= $00010000;	{ Catch RMB events for your own }
    NOCAREREFRESH	= $00020000;	{ not to be bothered with REFRESH }


{ --- Other Intuition Flags ---------------------------------------------- }
    WINDOWREFRESH	= $01000000;	{ Window is currently refreshing }
    WBENCHWINDOW	= $02000000;	{ WorkBench tool ONLY Window }
    WINDOWTICKED	= $04000000;	{ only one timer tick at a time }

    SUPER_UNUSED	= $FCFC0000;	{ bits of Flag unused yet }


{ --- see struct IntuiMessage for the IDCMP Flag definitions ------------- }




{ ======================================================================== }
{ === NewWindow ========================================================== }
{ ======================================================================== }

Type

    NewWindow = record
	LeftEdge,
	TopEdge		: Short;	{ screen dimensions of window }
	Width,
	Height		: Short;	{ screen dimensions of window }

	DetailPen,
	BlockPen	: Byte;		{ for bar/border/gadget rendering }

	IDCMPFlags	: Integer;	{ User-selected IDCMP flags }

	Flags		: Integer;	{ see Window struct for defines }

    { You supply a linked-list of Gadgets for your Window.
     *	This list DOES NOT include system Gadgets.  You get the standard
     *	system Window Gadgets by setting flag-bits in the variable Flags (see
     *	the bit definitions under the Window structure definition)
     }

	FirstGadget	: GadgetPtr;

    { the CheckMark is a pointer to the imagery that will be used when 
     * rendering MenuItems of this Window that want to be checkmarked
     * if this is equal to NULL, you'll get the default imagery
     }

	CheckMark	: ImagePtr;

	Title		: String;  { the title text for this window }
    
    { the Screen pointer is used only if you've defined a CUSTOMSCREEN and
     * want this Window to open in it.	If so, you pass the address of the
     * Custom Screen structure in this variable.  Otherwise, this variable
     * is ignored and doesn't have to be initialized.
     }

	Screen		: Address;
    
    { SUPER_BITMAP Window?  If so, put the address of your BitMap structure
     * in this variable.  If not, this variable is ignored and doesn't have 
     * to be initialized
     }

	BitMap		: BitMapPtr;

    { the values describe the minimum and maximum sizes of your Windows.
     * these matter only if you've chosen the WINDOWSIZING Gadget option,
     * which means that you want to let the User to change the size of 
     * this Window.  You describe the minimum and maximum sizes that the
     * Window can grow by setting these variables.  You can initialize
     * any one these to zero, which will mean that you want to duplicate
     * the setting for that dimension (if MinWidth == 0, MinWidth will be
     * set to the opening Width of the Window).
     * You can change these settings later using SetWindowLimits().
     * If you haven't asked for a SIZING Gadget, you don't have to
     * initialize any of these variables.
     }

	MinWidth,
	MinHeight	: Short;	{ minimums }
	MaxWidth,
	MaxHeight	: Short;	{ maximums }

    { the type variable describes the Screen in which you want this Window to
     * open.  The type value can either be CUSTOMSCREEN or one of the
     * system standard Screen Types such as WBENCHSCREEN.  See the
     * type definitions under the Screen structure
     }

	WType		: Short;	{ is "Type" in C includes }
    end;
    NewWindowPtr = ^NewWindow;


{$I "Include:Intuition/Screens.i"}
{$I "Include:Intuition/Preferences.i"}

{ ======================================================================== }
{ === Remember =========================================================== }
{ ======================================================================== }
{ this structure is used for remembering what memory has been allocated to
 * date by a given routine, so that a premature abort or systematic exit
 * can deallocate memory cleanly, easily, and completely
 }

Type

    Remember = record
	NextRemember	: ^Remember;
	RememberSize	: Integer;
	Memory		: Address;
    end;
    RememberPtr = ^Remember;



{ ======================================================================== }
{ === Miscellaneous ====================================================== }
{ ======================================================================== }

Const

{ = MENU STUFF =========================================================== }
    NOMENU	= $001F;
    NOITEM	= $003F;
    NOSUB	= $001F;
    MENUNULL	= -1;


{ = =RJ='s peculiarities ================================================= }

{ these defines are for the COMMSEQ and CHECKIT menu stuff.  If CHECKIT,
 * I'll use a generic Width (for all resolutions) for the CheckMark.
 * If COMMSEQ, likewise I'll use this generic stuff
 }

    CHECKWIDTH		= 19;
    COMMWIDTH		= 27;
    LOWCHECKWIDTH	= 13;
    LOWCOMMWIDTH	= 16;


{ these are the AlertNumber defines.  if you are calling DisplayAlert()
 * the AlertNumber you supply must have the ALERT_TYPE bits set to one
 * of these patterns
 }

    ALERT_TYPE		= $80000000;
    RECOVERY_ALERT	= $00000000;	{ the system can recover from this }
    DEADEND_ALERT	= $80000000;	{ no recovery possible, this is it }


{ When you're defining IntuiText for the Positive and Negative Gadgets 
 * created by a call to AutoRequest(), these defines will get you 
 * reasonable-looking text.  The only field without a define is the IText
 * field; you decide what text goes with the Gadget
 }

    AUTOFRONTPEN	= 0;
    AUTOBACKPEN		= 1;
    AUTODRAWMODE	= JAM2;
    AUTOLEFTEDGE	= 6;
    AUTOTOPEDGE		= 3;
    AUTOITEXTFONT	= Nil;
    AUTONEXTTEXT	= Nil;


{ --- RAWMOUSE Codes and Qualifiers (Console OR IDCMP) ------------------- }

    SELECTUP		= IECODE_LBUTTON + IECODE_UP_PREFIX;
    SELECTDOWN		= IECODE_LBUTTON;
    MENUUP		= IECODE_RBUTTON + IECODE_UP_PREFIX;
    MENUDOWN		= IECODE_RBUTTON;
    ALTLEFT		= IEQUALIFIER_LALT;
    ALTRIGHT		= IEQUALIFIER_RALT;
    AMIGALEFT		= IEQUALIFIER_LCOMMAND;
    AMIGARIGHT		= IEQUALIFIER_RCOMMAND;
    AMIGAKEYS		= AMIGALEFT + AMIGARIGHT;

    CURSORUP		= $4C;
    CURSORLEFT		= $4F;
    CURSORRIGHT		= $4E;
    CURSORDOWN		= $4D;
    KEYCODE_Q		= $10;
    KEYCODE_X		= $32;
    KEYCODE_N		= $36;
    KEYCODE_M		= $37;
    KEYCODE_V		= $34;
    KEYCODE_B		= $35;

Function ActivateGadget(Gadget : GadgetPtr;
			Window : WindowPtr;
			Request : RequesterPtr) : Boolean;
    External;

Procedure ActivateWindow(Window : WindowPtr);
    External;

Function AddGadget(Window : WindowPtr;
		   Gadget : GadgetPtr;
		   Position : Short) : Short;
    External;


Function AddGList(Window : WindowPtr; Gadget : GadgetPtr;
		  Position : Short; Numgad : Short;
		  Requester : RequesterPtr) : Short;
    External;

Function AllocRemember(var RememberKey : RememberPtr;
		       Size, Flags : Integer) : Address;
    External;

Function AutoRequest(Window : WindowPtr;
		     BodyText, PositiveText, NegativeText : IntuiTextPtr;
		     PositiveFlags, NegativeFlags : Integer;
		     Width, Height : Short) : Boolean;
    External;

Procedure BeginRefresh(Window : WindowPtr);
    External;

Function BuildSysRequest(window : WindowPtr;
			BodyText, PositiveText,NegativeText : IntuiTextPtr;
			IDCMPFlags : Integer;
			Width, Height : Short) : WindowPtr;
    External;

Function ClearDMRequest(window : WindowPtr) : Boolean;
    External;

Procedure ClearMenuStrip(window : WindowPtr);
    External;

Procedure ClearPointer(window : WindowPtr);
    External;

Procedure CloseScreen(screen : ScreenPtr);
    External;

Procedure CloseWindow(window : WindowPtr);
    External;

Function CloseWorkbench : Boolean;
    External;

Procedure CurrentTime(var Seconds, Micros : Integer);
    External;

Function DisplayAlert(AlertNumber : Integer;
			Str : String; Height : Short) : Boolean;
    External;

Procedure DisplayBeep(screen : ScreenPtr);
    External;

Function DoubleClick(StartSecs, StartMicros,
			CurrentSecs, CurrentMicros : Integer) : Boolean;
    External;

Procedure DrawBorder(rastport : RastPortPtr; Border : BorderPtr;
			LeftOffset, TopOffset : Short);
    External;

Procedure DrawImage(rastport : RastPortPtr; Image : ImagePtr;
			LeftOffset, TopOffset : Short);
    External;

Procedure EndRefresh(window : WindowPtr; Complete : Boolean);
    External;

Procedure EndRequest(requester : RequesterPtr; Window : WindowPtr);
    External;

Procedure FreeRemember(var RememberKey : RememberPtr; ReallyForget : Boolean);
    External;

Procedure FreeSysRequest(window : WindowPtr);
    External;

Function GetDefPrefs(PrefBuffer : PreferencesPtr;
			Size : Short) : PreferencesPtr;
    External;

Function GetPrefs(PrefBuffer : PreferencesPtr; Size : Short) : PreferencesPtr;
    External;

Function GetScreenData(Buffer : Address; Size, SType : Short;
			Screen : ScreenPtr) : Boolean;
    External;

Procedure InitRequester(requester : RequesterPtr);
    External;

Function IntuiTextLength(IText : IntuiTextPtr) : Integer;
    External;

Function ItemAddress(MenuStrip : MenuPtr; MenuNumber : Short) : MenuItemPtr;
    External;

Function ItemNum(MenuNumber : Short) : Short;
    External;

Function LockIBase(LockNumber : Integer) : Integer;
    External;

Procedure MakeScreen(Screen : ScreenPtr);
    External;

Function MenuNum(MenuNumber : Short) : Short;
    External;

Procedure ModifyIDCMP(window : WindowPtr; IDCMPFlags : Integer);
    External;

Procedure ModifyProp(gadget : GadgetPtr; window : WindowPtr;
			requester : RequesterPtr; Flags : Short;
			HorizPot, VertPot, HorizBody, VertBody : Short);
    External;

Procedure MoveScreen(screen : ScreenPtr; DeltaX, DeltaY : Short);
    External;

Procedure MoveWindow(window : WindowPtr; DeltaX, DeltaY : Short);
    External;

Procedure NewModifyProp(gadget : GadgetPtr; window : WindowPtr;
			requester : RequesterPtr; Flags : Short;
			HorizPot, VertPot, HorizBody, VertBody : Short;
			NumGad : Integer);
    External;

Procedure OffGadget(gadget : GadgetPtr;
			window : WindowPtr;
			requester : RequesterPtr);
    External;

Procedure OffMenu(window : WindowPtr; MenuNumber : Short);
    External;

Procedure OnGadget(gadget : GadgetPtr;
			window : WindowPtr;
			requester : RequesterPtr);
    External;

Procedure OnMenu(window : WindowPtr; MenuNumber : Short);
    External;

Function OpenScreen(newscreen : NewScreenPtr) : ScreenPtr;
    External;

Function OpenWindow(newwindow : NewWindowPtr) : WindowPtr;
    External;

Function OpenWorkBench : ScreenPtr;
    External;

Procedure PrintIText(rastport : RastPortPtr; IText : IntuiTextPtr;
			LeftOffset, TopOffset : Short);
    External;

Procedure RefreshGadgets(gadgets : GadgetPtr;
			window : WindowPtr;
			requester : RequesterPtr);
    External;

Procedure RefreshGList(gadgets : GadgetPtr; window : WindowPtr;
			requester : RequesterPtr; NumGad : Short);
    External;

Procedure RefreshWindowFrame(window : WindowPtr);
    External;

Procedure RemakeDisplay;
    External;

Function RemoveGadget(window : WindowPtr; gadget : GadgetPtr) : Short;
    External;

Function RemoveGList(window : WindowPtr; gadget : GadgetPtr;
			NumGad : Short) : Short;
    External;

Procedure ReportMouse(window : WindowPtr; DoIt : Boolean);
    External;

Function Request(requester : RequesterPtr; window : WindowPtr) : Boolean;
    External;

Procedure RethinkDisplay;
    External;

Procedure ScreenToBack(screen : ScreenPtr);
    External;

Procedure ScreenToFront(screen : ScreenPtr);
    External;

Procedure SetDMRequest(window : WindowPtr; DMRequester : RequesterPtr);
    External;

Function SetMenuStrip(window : WindowPtr; Menu : MenuPtr) : Boolean;
    External;

Procedure SetPointer(window : WindowPtr; pointer : Address;
			Height, Width, XOffset, YOffset : Short);
    External;

Function SetPrefs(PrefBuffer : PreferencesPtr; Size : Integer;
			Inform : Boolean) : PreferencesPtr;
    External;
    

Procedure SetWindowTitles(window : WindowPtr;
			WindowTitle, ScreenTitle : String);
    External;

Procedure ShowTitle(screen : ScreenPtr; ShowIt : Boolean);
    External;

Procedure SizeWindow(window : WindowPtr; DeltaX, DeltaY : Short);
    External;

Function SubNum(MenuNumber : Short) : Short;
    External;

Procedure UnlockIBase(Lock : Integer);
    External;

Function ViewAddress : ViewPtr;
    External;

Function ViewPortAddress(window : WindowPtr) : ViewPortPtr;
    External;

Function WBenchToBack : Boolean;
    External;

Function WBenchToFront : Boolean;
    External;

Function WindowLimits(window : WindowPtr; MinWidth, MinHeight,
			MaxWidth, MaxHeight : Short) : Boolean;
    External;

Procedure WindowToBack(window : WindowPtr);
    External;

Procedure WindowToFront(window : WindowPtr);
    External;

