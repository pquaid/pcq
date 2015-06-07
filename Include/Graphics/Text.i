{
    Text.i for PCQ Pascal
}

{$I "Include:Exec/Ports.i"}

const

{------ Font Styles ------------------------------------------------}

    FS_NORMAL		= 0;	{ normal text (no style bits set) }
    FSB_EXTENDED	= 3;	{ extended face (wider than normal) }
    FSF_EXTENDED	= 8;
    FSB_ITALIC		= 2;	{ italic (slanted 1:2 right) }
    FSF_ITALIC		= 4;
    FSB_BOLD		= 1;	{ bold face text (ORed w/ shifted) }
    FSF_BOLD		= 2;
    FSB_UNDERLINED	= 0;	{ underlined (under baseline) }
    FSF_UNDERLINED	= 1;

{------ Font Flags -------------------------------------------------}
    FPB_ROMFONT		= 0;	{ font is in rom }
    FPF_ROMFONT		= 1;
    FPB_DISKFONT	= 1;	{ font is from diskfont.library }
    FPF_DISKFONT	= 2;
    FPB_REVPATH		= 2;	{ designed path is reversed (e.g. left) }
    FPF_REVPATH		= 4;
    FPB_TALLDOT		= 3;	{ designed for hires non-interlaced }
    FPF_TALLDOT		= 8;
    FPB_WIDEDOT		= 4;	{ designed for lores interlaced }
    FPF_WIDEDOT		= 16;
    FPB_PROPORTIONAL	= 5;	{ character sizes can vary from nominal }
    FPF_PROPORTIONAL	= 32;
    FPB_DESIGNED	= 6;	{ size is "designed", not constructed }
    FPF_DESIGNED	= 64;
    FPB_REMOVED		= 7;	{ the font has been removed }
    FPF_REMOVED		= 128;

{***** TextAttr node, matches text attributes in RastPort *********}

type

    TextAttr = record
	ta_Name	: String;	{ name of the font }
	ta_YSize : Short;	{ height of the font }
	ta_Style : Byte;	{ intrinsic font style }
	ta_Flags : Byte;	{ font preferences and flags }
    end;
    TextAttrPtr = ^TextAttr;

{***** TextFonts node *********************************************}

    TextFont = record
	tf_Message	: Message;	{ reply message for font removal }
					{ font name in LN \    used in this }
	tf_YSize	: Short;	{ font height     |    order to best }
	tf_Style	: Byte;		{ font style      |    match a font }
	tf_Flags	: Byte;		{ preferences and flags	/    request. }
	tf_XSize	: Short;	{ nominal font width }
	tf_Baseline	: Short; { distance from the top of char to baseline }
	tf_BoldSmear	: Short;	{ smear to affect a bold enhancement }

	tf_Accessors	: Short;	{ access count }

	tf_LoChar	: Byte;		{ the first character described here }
	tf_HiChar	: Byte;		{ the last character described here }
	tf_CharData	: Address;	{ the bit character data }

	tf_Modulo	: Short; { the row modulo for the strike font data }
	tf_CharLoc	: Address; { ptr to location data for the strike font }
					{ 2 words: bit offset then size }
	tf_CharSpace	: Address; { ptr to words of proportional spacing data }
	tf_CharKern	: Address;	{ ptr to words of kerning data }
    end;
    TextFontPtr = ^TextFont;

Procedure AddFont(textFont : TextFontPtr);
    External;

Procedure AskFont(rp : Address; textAttr : TextAttrPtr);
    External;	{ rp is a RastPortPtr }

Function AskSoftStyle(rp : Address) : Integer;
    External;	{ rp is a RastPortPtr }

Procedure ClearEOL(rp : Address);
    External;

Procedure ClearScreen(rp : Address);
    External;

Procedure CloseFont(font : TextFontPtr);
    External;

Function OpenFont(textAttr : TextAttrPtr) : TextFontPtr;
    External;

Procedure RemFont(textFont : TextFontPtr);
    External;

Procedure SetFont(rp : Address; font : TextFontPtr);
    External;	{ rp is a RastPortPtr }

Function SetSoftStyle(rp : Address; style, enable : Integer) : Integer;
    External;

Procedure GText(rp : Address; str : String; count : Short);
    External;

Function TextLength(rp : Address; str : String; count : Short) : Short;
    External;

