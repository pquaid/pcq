{
	InputEvent.i for PCQ Pascal

	input event definitions 
}

{$I "Include:Devices/Timer.i"}


const

{------ constants -------------------------------------------------}
  
{   --- InputEvent.ie_Class --- }
{ A NOP input event }
    IECLASS_NULL	= $00;
{ A raw keycode from the keyboard device }
    IECLASS_RAWKEY	= $01;
{ The raw mouse report from the game port device }
    IECLASS_RAWMOUSE	= $02;
{ A private console event }
    IECLASS_EVENT	= $03;
{ A Pointer Position report }
    IECLASS_POINTERPOS	= $04;
{ A timer event }
    IECLASS_TIMER	= $06;
{ select button pressed down over a Gadget (address in ie_EventAddress) }
    IECLASS_GADGETDOWN	= $07;
{ select button released over the same Gadget (address in ie_EventAddress) }
    IECLASS_GADGETUP	= $08;
{ some Requester activity has taken place.  See Codes REQCLEAR and REQSET }
    IECLASS_REQUESTER	= $09;
{ this is a Menu Number transmission (Menu number is in ie_Code) }
    IECLASS_MENULIST	= $0A;
{ User has selected the active Window's Close Gadget }
    IECLASS_CLOSEWINDOW	= $0B;
{ this Window has a new size }
    IECLASS_SIZEWINDOW	= $0C;
{ the Window pointed to by ie_EventAddress needs to be refreshed }
    IECLASS_REFRESHWINDOW = $0D;
{ new preferences are available }
    IECLASS_NEWPREFS	= $0E;
{ the disk has been removed }
    IECLASS_DISKREMOVED	= $0F;
{ the disk has been inserted }
    IECLASS_DISKINSERTED = $10;
{ the window is about to be been made active }
    IECLASS_ACTIVEWINDOW = $11;
{ the window is about to be made inactive }
    IECLASS_INACTIVEWINDOW = $12;


{ the last class }

    IECLASS_MAX		= $12;



{   --- InputEvent.ie_Code ---	 }
{ IECLASS_RAWKEY }
    IECODE_UP_PREFIX		= $80;
    IECODE_KEY_CODE_FIRST	= $00;
    IECODE_KEY_CODE_LAST	= $77;
    IECODE_COMM_CODE_FIRST	= $78;
    IECODE_COMM_CODE_LAST	= $7F;
  
{ IECLASS_ANSI }
    IECODE_C0_FIRST		= $00;
    IECODE_C0_LAST		= $1F;
    IECODE_ASCII_FIRST		= $20;
    IECODE_ASCII_LAST		= $7E;
    IECODE_ASCII_DEL		= $7F;
    IECODE_C1_FIRST		= $80;
    IECODE_C1_LAST		= $9F;
    IECODE_LATIN1_FIRST		= $A0;
    IECODE_LATIN1_LAST		= $FF;
  
{ IECLASS_RAWMOUSE }
    IECODE_LBUTTON		= $68;	{ also uses IECODE_UP_PREFIX }
    IECODE_RBUTTON		= $69;
    IECODE_MBUTTON		= $6A;
    IECODE_NOBUTTON		= $FF;
  
{ IECLASS_EVENT }
    IECODE_NEWACTIVE		= $01;	{ active input window changed }

{ IECLASS_REQUESTER Codes }
{ REQSET is broadcast when the first Requester (not subsequent ones) opens
 * in the Window
 }
    IECODE_REQSET		= $01;
{ REQCLEAR is broadcast when the last Requester clears out of the Window }
    IECODE_REQCLEAR		= $00;

  
{   --- InputEvent.ie_Qualifier --- }
    IEQUALIFIER_LSHIFT		= $0001;
    IEQUALIFIER_RSHIFT		= $0002;
    IEQUALIFIER_CAPSLOCK	= $0004;
    IEQUALIFIER_CONTROL		= $0008;
    IEQUALIFIER_LALT		= $0010;
    IEQUALIFIER_RALT		= $0020;
    IEQUALIFIER_LCOMMAND	= $0040;
    IEQUALIFIER_RCOMMAND	= $0080;
    IEQUALIFIER_NUMERICPAD	= $0100;
    IEQUALIFIER_REPEAT		= $0200;
    IEQUALIFIER_INTERRUPT	= $0400;
    IEQUALIFIER_MULTIBROADCAST	= $0800;
    IEQUALIFIER_MIDBUTTON	= $1000;
    IEQUALIFIER_RBUTTON		= $2000;
    IEQUALIFIER_LEFTBUTTON	= $4000;
    IEQUALIFIER_RELATIVEMOUSE	= $8000;

    IEQUALIFIERB_LSHIFT		= 0;
    IEQUALIFIERB_RSHIFT		= 1;
    IEQUALIFIERB_CAPSLOCK	= 2;
    IEQUALIFIERB_CONTROL	= 3;
    IEQUALIFIERB_LALT		= 4;
    IEQUALIFIERB_RALT		= 5;
    IEQUALIFIERB_LCOMMAND	= 6;
    IEQUALIFIERB_RCOMMAND	= 7;
    IEQUALIFIERB_NUMERICPAD	= 8;
    IEQUALIFIERB_REPEAT		= 9;
    IEQUALIFIERB_INTERRUPT	= 10;
    IEQUALIFIERB_MULTIBROADCAST	= 11;
    IEQUALIFIERB_MIDBUTTON	= 12;
    IEQUALIFIERB_RBUTTON	= 13;
    IEQUALIFIERB_LEFTBUTTON	= 14;
    IEQUALIFIERB_RELATIVEMOUSE	= 15;
  
{------ InputEvent ------------------------------------------------}

type

    InputEvent = record
	ie_NextEvent	: ^InputEvent;	{ the chronologically next event }
	ie_Class	: Byte;		{ the input event class }
	ie_SubClass	: Byte;		{ optional subclass of the class }
	ie_Code		: Short;	{ the input event code }
	ie_Qualifier	: Short;	{ qualifiers in effect for the event}
	ie_addr_xy	: Integer;	{ addr or pointer position }
	ie_TimeStamp	: TimeVal;	{ the system tick at the event }
    end;
    InputEventPtr = ^InputEvent;

