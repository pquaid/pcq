 {
 *
 *
 * StickStuff.i for PCQ Pascal V1.1d
 * by Cat'sEye
 *
 * October 22nd AD 1990
 * 
 * Theived from :
 * Super big bitmap explorer.
 * Jon would call this a parlor trick.
 *
 * Leo L. Schwab		8607.30
 *
 *
 }

{$I "Include:exec/memory.i"}
{$I "Include:exec/devices.i"}
{$I "Include:devices/gameport.i"}
{$I "Include:devices/inputevent.i"}
{$I "Include:utils/IOUtils.i"}

const	gpt	: GamePortTrigger = (3, 1, 0, 0);

	{ CEJS : Cat'sEye JoyStick }

var	CEJS_JoyReport	: InputEvent;
	CEJS_GameIO	: IOStdReqPtr;
	CEJS_GamePort	: MsgPortPtr;

type

    InputEventXY = record
	ie_NextEvent	: ^InputEvent;
	ie_Class	: Byte;
	ie_SubClass	: Byte;
	ie_Code		: Short;
	ie_Qualifier	: Short;
	ie_X, ie_Y	: Short;
	ie_TimeStamp	: TimeVal;
    end;
    InputEventXYPtr = ^InputEventXY;

Procedure ReadStick (var X, Y : Short; var Trig : Boolean);

{
	Puts the values from the joystick into X, Y and Trig.
	Very Straightforward.
}

var IEXY : InputEventXY;

begin
	SendIO (CEJS_GameIO);
	if DoIO (CEJS_GameIO) <> 0 then;
	Trig := (CEJS_JoyReport.ie_Code = IECODE_LBUTTON);
	IEXY := InputEventXY (CEJS_JoyReport);
	if IEXY.ie_X > 127 then X := - (256 - IEXY.ie_X) else X := IEXY.ie_X;
	if IEXY.ie_Y > 127 then Y := - (256 - IEXY.ie_Y) else Y := IEXY.ie_Y;
end;

Procedure CloseStick;

{
	Closes the joystick. Frees up CEJS_GameIO, etc. Call this when you're
	done, thanks.
}

begin
	if CEJS_GameIO <> nil then
		begin
		if (CEJS_GameIO^.io_Device) <> nil then CloseDevice (CEJS_GameIO);
		DeleteStdIO (CEJS_GameIO);
		end;
	if (CEJS_GamePort) <> nil then DeletePort (CEJS_GamePort);
end;

Function OpenStick : Boolean;

{
	Initializes my variables so's they'll work with a standard
	9pin joystick. Call OpenStick before any other Stick calls!
}

var
	StickType	: Byte;
	OS		: Integer;

begin
	CEJS_GamePort := CreatePort (nil, 0);
	if CEJS_GamePort = nil then OpenStick := FALSE;
	CEJS_GameIO := CreateStdIO (CEJS_GamePort);
	if CEJS_GameIO = nil then OpenStick := FALSE;
	OS := OpenDevice ("gameport.device", 1, CEJS_GameIO, 0);
	if OS <> 0 then OpenStick := FALSE;
	StickType := GPCT_RELJOYSTICK;
	CEJS_GameIO^.io_Command := GPD_SETCTYPE;
	CEJS_GameIO^.io_Length := 1;
	CEJS_GameIO^.io_Data := Adr(StickType);
	OS := (DoIO (CEJS_GameIO));
	if OS <> 0 then OpenStick := FALSE;
	CEJS_GameIO^.io_Command := GPD_SETTRIGGER;
	CEJS_GameIO^.io_Length := sizeof (GamePortTrigger);
	CEJS_GameIO^.io_Data := Adr(gpt);
	OS := (DoIO (CEJS_GameIO));
	if OS <> 0 then OpenStick := FALSE;
	CEJS_GameIO^.io_Command := GPD_READEVENT;
	CEJS_GameIO^.io_Length := sizeof (InputEvent);
	CEJS_GameIO^.io_Data := Adr(CEJS_JoyReport);
	OpenStick := TRUE;
end;
