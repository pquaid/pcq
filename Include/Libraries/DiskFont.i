{
	DiskFont.i for PCQ Pascal

	diskfont library definitions
}

{$I "Include:Exec/Nodes.i"}
{$I "Include:Exec/Lists.i"}
{$I "Include:Graphics/Text.i"}

Var
    DiskFontBase : Address;

Const

    MAXFONTPATH		= 256;   { including null terminator }

Type

    FontContents = record
	fc_FileName	: Array [0..MAXFONTPATH-1] of Char;
	fc_YSize	: Short;
	fc_Style	: Byte;
	fc_Flags	: Byte;
    end;
    FontContentsPtr = ^FontContents;

Const

    FCH_ID		= $0f00;

Type

    FontContentsHeader = record
	fch_FileID	: Short;	{ FCH_ID }
	fch_NumEntries	: Short;	{ the number of FontContents elements }
	fch_FC		: Array [0..0] of FontContents;
					{ actual number of elements is NumEntries }
    end;
    FontContentsHeaderPtr = ^FontContentsHeader;

Const

    DFH_ID		= $0f80;
    MAXFONTNAME		= 32;	{ font name including ".font\0" }

Type

    DiskFontHeader = record
    { the following 8 bytes are not actually considered a part of the }
    { DiskFontHeader, but immediately preceed it. The NextSegment is  }
    { supplied by the linker/loader, and the ReturnCode is the code   }
    { at the beginning of the font in case someone runs it...	       }
    {	 ULONG dfh_NextSegment;{ actually a BPTR }
    {	 ULONG dfh_ReturnCode;	 { MOVEQ #0,D0 : RTS }
    { here then is the official start of the DiskFontHeader...	     }
	dfh_DF		: Node;		{ node to link disk fonts }
	dfh_FileID	: Short;	{ DFH_ID }
	dfh_Revision	: Short;	{ the font revision }
	dfh_Segment	: Integer;	{ the segment address when loaded }
	dfh_Name	: Array [0..MAXFONTNAME-1] of Char;
					{ the font name (null terminated) }
	dfh_TF		: TextFont;	{ loaded TextFont structure }
    end;
    DiskFontHeaderPtr = ^DiskFontHeader;

Const

    AFB_MEMORY		= 0;
    AFF_MEMORY		= 1;
    AFB_DISK		= 1;
    AFF_DISK		= 2;

Type

    AvailFont = record
	af_Type		: Short;	{ MEMORY or DISK }
	af_Attr		: TextAttr;	{ text attributes for font }
    end;
    AvailFontPtr = ^AvailFont;

    AvailFontsHeader = record
	afh_NumEntries	: Short;	{ number of AvailFonts elements }
	afh_AF		: Array [0..0] of AvailFont;
					{ actual number in NumEntries }
    end;
    AvailFontsHeaderPtr = ^AvailFontsHeader;

Function AvailFonts(buffer : Address;
		    bufBytes : Integer; types : Integer) : Integer;
    External;

Procedure DisposeFontContents(FCH : FontContentsHeaderPtr);
    External; { version 34 }

Function NewFontContents(fontsLock : Address { Lock };
			fontName : String) : FontContentsHeaderPtr;
    External; { version 34 }

Function OpenDiskFont(TA : TextAttrPtr) : TextFontPtr;
    External;

