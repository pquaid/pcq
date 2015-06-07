{
    ReqTools.i

    This file defines the types, constants and routines
    used in Nico François' reqtools.library
}

{$I "Exec/Lists.i"}
{$I "Exec/Libraries.i"}
{$I "Graphics/Text.i"}
{$I "Utility/TagItem.i"}


Const
    REQTOOLSNAME	= "reqtools.library";
    REQTOOLSVERSION	= 37;

Type
    ReqToolsBase = Record
	LibNode   : Library;
	Flags	  : Byte;
	pad	  : Array [0..2] of Byte;
	SegList   : Address;
   { The following library bases may be read and used by your program }
	IntuitionBase : LibraryPtr;
	GfxBase       : LibraryPtr;
	DOSBase       : LibraryPtr;
   { Next two library bases are only (and always) valid on Kickstart 2.0!
      (1.3 version of reqtools also initializes these when run on 2.0) }
	GadToolsBase  : LibraryPtr;
	UtilityBase   : LibraryPtr;
    end;


{ types of requesters, for rtAllocRequestA() }

Const
    RT_FILEREQ		= 0;
    RT_REQINFO		= 1;
    RT_FONTREQ		= 2;




Type

{***********************
*                      *
*    File requester    *
*                      *
***********************}

{ structure _MUST_ be allocated with rtAllocRequest() }

    rtFileRequesterPtr = ^rtFileRequester;
    rtFileRequester = Record
	ReqPos		: Integer;
	LeftOffset	: Word;
	TopOffset	: Word;
	Flags		: Integer;
	Hook		: HookPtr;
	Dir		: String; { READ ONLY! Change with rtChangeReqAttrA()! }
	MatchPat	: String; { READ ONLY! Change with rtChangeReqAttrA()! }
	DefaultFont	: TextFontPtr;
	WaitPointer	: Integer;
   { Lots of private data follows! HANDS OFF :-) }
    end;

{ returned by rtFileRequestA() if multiselect is enabled,
   free list with rtFreeFileList() }

    rtFileListPtr = ^rtFileList;
    rtFileList = Record
	Next	: rtFileListPtr;
	StrLen	: Integer;   { -1 for directories }
	Name	: String;
    end;


{**********************
*                      *
*    Font requester    *
*                      *
**********************}

{ structure _MUST_ be allocated with rtAllocRequest() }

    ftFontRequesterPtr = ^rtFontRequester;
    rtFontRequester = Record
	ReqPos		: Integer;
	LeftOffset	: Word;
	TopOffset	: Word;
	Flags		: Integer;
	Hook		: HookPtr;
	Attr		: TextAttr;		{ READ ONLY! }
	DefaultFont	: TextFontPtr;
	WaitPointer	: Integer;
   { Lots of private data follows! HANDS OFF :-) }
    end;

{**********************
*                      *
*    Requester Info    *
*                      *
**********************}

{ for rtEZRequestA(), rtGetLongA(), rtGetStringA() and rtPaletteRequestA(),
   _MUST_ be allocated with rtAllocRequest() }

    rtReqInfoPtr = ^rtReqInfo;
    rtReqInfo = Record
	ReqPos		: Integer;
	LeftOffset	: Word;
	TopOffset	: Word;
	Width		: Integer;     { not for rtEZRequestA() }
	ReqTitle	: String;      { currently only for rtEZRequestA() }
	Flags		: Integer;     { only for rtEZRequestA() }
	DefaultFont	: TextFontPtr; { currently only for rtPaletteRequestA() }
	WaitPointer	: Integer;
   { structure may be extended in future }
    end;

{**********************
*                      *
*     Handler Info     *
*                      *
**********************}

{ for rtReqHandlerA(), will be allocated for you when you use
   the RT_ReqHandler tag, never try to allocate this yourself! }

    rtHandlerInfoPtr = ^rtHandlerInfo;
    rtHandlerInfo = record
	private1	: Integer;
	WaitMask	: Integer;
	DoNotWait	: Integer;
   { Private data follows, HANDS OFF :-) }
    end;

{ possible return codes from rtReqHandlerA() }

Const
    CALL_HANDLER	= $80000000;


{************************************
*                                    *
*                TAGS                *
*                                    *
************************************}

    RT_TagBase		= TAG_USER

{** tags understood by most requester functions ***}
{ optional pointer to window }
    RT_Window		= RT_TagBase+1;

{ idcmp flags requester should abort on (useful for IDCMP_DISKINSERTED) }
    RT_IDCMPFlags	= RT_TagBase+2;

{ position of requester window (see below) - default REQPOS_POINTER }
    RT_ReqPos		= RT_TagBase+3;

{ signal mask to wait for abort signal }
    RT_LeftOffset	= RT_TagBase+4;

{ topedge offset of requester relative to position specified by RT_ReqPos }
    RT_TopOffset	= RT_TagBase+5;

{ name of public screen to put requester on (Kickstart 2.0 only!) }
    RT_PubScrName	= RT_TagBase+6;

{ address of screen to put requester on }
    RT_Screen		= RT_TagBase+7;

{ tagdata must hold the address of (!) an APTR variable }
    RT_ReqHandler	= RT_TagBase+8;

{ font to use when screen font is rejected, _MUST_ be fixed-width font!
   (struct TextFont *, not struct TextAttr *!)
   - default GfxBase->DefaultFont }
    RT_DefaultFont	= RT_TagBase+9;

{ boolean to set the standard wait pointer in window - default FALSE }
    RT_WaitPointer	= RT_TagBase+10;

{** tags specific to rtEZRequestA ***}
{ title of requester window - default "Request" or "Information" }
    RTEZ_ReqTitle	= RT_TagBase+20;

{ (RT_TagBase+21) reserved
{ various flags (see below) }
    RTEZ_Flags		= RT_TagBase+22;

{ default response (activated by pressing RETURN) - default TRUE }
    RTEZ_DefaultResponse	= RT_TagBase+23;

{** tags specific to rtGetLongA ***}
{ minimum allowed value - default MININT }
    RTGL_Min		= RT_TagBase+30;

{ maximum allowed value - default MAXINT }
    RTGL_Max		= RT_TagBase+31;

{ suggested width of requester window (in pixels) }
    RTGL_Width		= RT_TagBase+32;

{ boolean to show the default value - default TRUE }
    RTGL_ShowDefault	= RT_TagBase+33;

{** tags specific to rtGetStringA ***}
{ suggested width of requester window (in pixels) }
    RTGS_Width		= RTGL_Width;

{ allow empty string to be accepted - default FALSE }
    RTGS_AllowEmpty	= RT_TagBase+80;

{** tags specific to rtFileRequestA ***}
{ various flags (see below) }
    RTFI_Flags		= RT_TagBase+40;

{ suggested height of file requester }
    RTFI_Height		= RT_TagBase+41;

{ replacement text for 'Ok' gadget (max 6 chars) }
    RTFI_OkText		= RT_TagBase+42;

{** tags specific to rtFontRequestA ***}
{ various flags (see below) }
    RTFO_Flags		= RTFI_Flags;

{ suggested height of font requester }
    RTFO_Height		= RTFI_Height;

{ replacement text for 'Ok' gadget (max 6 chars) }
    RTFO_OkText		= RTFI_OkText;

{ suggested height of font sample display - default 24 }
    RTFO_SampleHeight	= RT_TagBase+60;

{ minimum height of font displayed }
    RTFO_MinHeight	= RT_TagBase+61;

{ maximum height of font displayed }
    RTFO_MaxHeight	= RT_TagBase+62;

{ [(RT_TagBase+63) to (RT_TagBase+66) used below] }

{** tags for rtChangeReqAttrA ***}
{ file requester - set directory }
    RTFI_Dir		= RT_TagBase+50;

{ file requester - set wildcard pattern }
    RTFI_MatchPat	= RT_TagBase+51;

{ file requester - add a file or directory to the buffer }
    RTFI_AddEntry	= RT_TagBase+52;

{ file requester - remove a file or directory from the buffer }
    RTFI_RemoveEntry	= RT_TagBase+53;

{ font requester - set font name of selected font }
    RTFO_FontName	= RT_TagBase+63;

{ font requester - set font size }
    RTFO_FontHeight	= RT_TagBase+64;

{ font requester - set font style }
    RTFO_FontStyle	= RT_TagBase+65;

{ font requester - set font flags }
    RTFO_FontFlags	= RT_TagBase+66;

{** tags for rtPaletteRequestA ***}
{ initially selected color - default 1 }
    RTPA_Color		= RT_TagBase+70;

{** tags for rtReqHandlerA ***}
{ end requester by software control, set tagdata to REQ_CANCEL, REQ_OK or
   in case of rtEZRequest to the return value }
    RTRH_EndRequest	= RT_TagBase+60;

{** tags for rtAllocRequestA **}
{ no tags defined yet }


{***********
* RT_ReqPos *
***********}
    REQPOS_POINTER	= 0;
    REQPOS_CENTERWIN	= 1;
    REQPOS_CENTERSCR	= 2;
    REQPOS_TOPLEFTWIN	= 3;
    REQPOS_TOPLEFTSCR	= 4;

{*****************
* RTRH_EndRequest *
*****************}
    REQ_CANCEL		= 0;
    REQ_OK		= 1;

{**************************************
* flags for RTFI_Flags and RTFO_Flags  *
* or filereq->Flags and fontreq->Flags *
**************************************}
    FREQB_NOBUFFER	= 2;
    FREQF_NOBUFFER	= 1 shl FREQB_NOBUFFER;
    FREQB_DOWILDFUNC	= 11;
    FREQF_DOWILDFUNC	= 1 shl FREQB_DOWILDFUNC;

{****************************************
* flags for RTFI_Flags or filereq->Flags *
****************************************}
    FREQB_MULTISELECT	= 0;
    FREQF_MULTISELECT	= 1 shl FREQB_MULTISELECT;
    FREQB_SAVE		= 1;
    FREQF_SAVE		= 1 shl FREQB_SAVE;
    FREQB_NOFILES	= 3;
    FREQF_NOFILES	= 1 shl FREQB_NOFILES;
    FREQB_PATGAD	= 4;
    FREQF_PATGAD	= 1 shl FREQB_PATGAD;
    FREQB_SELECTDIRS	= 12;
    FREQF_SELECTDIRS	= 1 shl FREQB_SELECTDIRS;

{****************************************
* flags for RTFO_Flags or fontreq->Flags *
****************************************}
    FREQB_FIXEDWIDTH	= 5;
    FREQF_FIXEDWIDTH	= 1 shl FREQB_FIXEDWIDTH;
    FREQB_COLORFONTS	= 6;
    FREQF_COLORFONTS	= 1 shl FREQB_COLORFONTS;
    FREQB_CHANGEPALETTE	= 7;
    FREQF_CHANGEPALETTE	= 1 shl FREQB_CHANGEPALETTE;
    FREQB_LEAVEPALETTE	= 8;
    FREQF_LEAVEPALETTE	= 1 shl FREQB_LEAVEPALETTE;
    FREQB_SCALE		= 9;
    FREQF_SCALE		= 1 shl FREQB_SCALE;
    FREQB_STYLE		= 10;
    FREQF_STYLE		= 1 shl FREQB_STYLE;

{****************************************
* flags for RTEZ_Flags or reqinfo->Flags *
****************************************}
    EZREQB_NORETURNKEY	= 0;
    EZREQF_NORETURNKEY	= 1 shl EZREQB_NORETURNKEY;
    EZREQB_LAMIGAQUAL	= 1;
    EZREQF_LAMIGAQUAL	= 1 shl EZREQB_LAMIGAQUAL;
    EZREQB_CENTERTEXT	= 2;
    EZREQF_CENTERTEXT	= 1 shl EZREQB_CENTERTEXT;

{*******
* hooks *
*******}
    REQHOOK_WILDFILE	= 0;
    REQHOOK_WILDFONT	= 1;




Function rtAllocRequestA(AType : Integer; TagList : TagItemPtr) : Address;
    External;

Procedure rtFreeRequest (Req : Address);
    External;

Procedure rtFreeReqBuffer (Buffer : Address);
    External;

Function rtChangeReqAttrA (req : Address; taglist : TagItemPtr) : Integer;
    External;

Function rtFileRequestA(filereq : rtFileRequesterPtr;
                        filename : String;
                        title    : String;
                        taglist  : TagItemPtr) : Address;
    External;

Procedure rtFreeFileList(filelist : rtFileListPtr);
    External;

Function rtEZRequestA(bodyfmt : String; gadfmt : String;
                      reqinfo : rtReqInfoPtr; argarray : Address;
                      taglist : TagItemPtr) : Integer;
    External;

Function rtGetStringA(buffer : String; maxchars : Integer;
                      title : String; reqinfo : rtReqInfoPtr;
                      taglist : TagItemPtr) : Integer;
    External;

Function rtGetLongA(buffer : Address; title : String;
                    reqinfo : rtReqInfoPtr; taglist : TagItemPtr) : Integer;
    External;

Function rtFontRequestA(fontreq : rtFontRequesterPtr; title : String;
                        taglist : TagItemPtr) : Boolean;
    External;

Function rtPaletteRequestA(title : String; reqinfo : rtReqInfoPtr;
                           taglist : TagItemPtr) : Integer;
    External;

Function rtReqHandlerA (HandlerInfo : rtHandlerInfoPtr;
			sigs : Integer; TagList : TagItemPtr) : Integer;
    External;

Procedure rtSetWaitPointer (Window : Address);
    External;

Function rtGetVScreenSize (Screen : Address; 
                           WidthPtr, HeightPtr : ^Integer) : Integer;
    External;

void  rtSetReqPosition (ULONG, struct NewWindow *,
                        struct Screen *, struct Window *);
void  rtSpread (ULONG *, ULONG *, ULONG, ULONG, ULONG, ULONG);
void  rtScreenToFrontSafely (struct Screen *);

/* functions with varargs in reqtools.lib and reqtoolsnb.lib */

APTR  rtAllocRequest (ULONG, Tag,...);
LONG  rtChangeReqAttr (APTR, Tag,...);
APTR  rtFileRequest (struct rtFileRequester *, char *, char *, Tag,...);
ULONG rtEZRequest (char *, char *, struct rtReqInfo *, struct TagItem *,...);
ULONG rtEZRequestTags (char *, char *, struct rtReqInfo *, APTR, Tag,...);
ULONG rtGetString (UBYTE *, ULONG, char *, struct rtReqInfo *, Tag,...);
ULONG rtGetLong (ULONG *, char *, struct rtReqInfo *, Tag,...);
BOOL  rtFontRequest (struct rtFontRequester *, char *, Tag,...);
LONG  rtPaletteRequest (char *, struct rtReqInfo *, Tag,...);
ULONG rtReqHandler (struct rtHandlerInfo *, ULONG, Tag,...);

#endif /* CLIB_REQTOOLS_PROTOS_H */

