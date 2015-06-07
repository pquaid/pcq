External;

{
	DeadKeyConvert.p

	When you want Intuition to send you keystrokes, you either get just
    the simple key-cap type keys (i.e. no cursor or function keys) or you
    get keycodes, which tell you nothing about what was on the key the
    user pressed.  DeadKeyConvert allows you to receive RAWKEY messages,
    then translate them into their ANSI key sequences.  These are known as
    cooked keys, and a single keystroke might be converted into as many as
    four characters (including the CSI).  See the ROM Kernel Manual and the
    Enhancer manual for details.
	The difference between this and RawKeyConvert is that this also
    handles the deadkeys - for example, pressing ALT-K, releasing it, and
    pressing o gives you an o with an umlaut.
	Also note that some keys will come back with a length of zero - the
    shift and alt keys, for example.  You can probably ignore them.
	Finally, I'll point out that, since this function calls RawKeyConvert,
    you need to call OpenConsoleDevice (defined in ConsoleUtils) before using
    it.
}

{$I "Include:Utils/ConsoleUtils.i"}
{$I "Include:Devices/InputEvent.i"}
{$I "Include:Intuition/Intuition.i"}

Function DeadKeyConvert(msg : IntuiMessagePtr; Buffer : String;
			BufSize : Integer; KeyMap : Address) : Integer;
var
    Event : InputEvent;
    Temp  : ^Address;
begin
    if msg^.Class <> RAWKEY_f then
	DeadKeyConvert := -2;
    with Event do begin
	ie_NextEvent := Nil;
	ie_Class := IECLASS_RAWKEY;
	ie_SubClass := 0;
	ie_Code := msg^.Code;
	ie_Qualifier := msg^.Qualifier;
	Temp := msg^.IAddress;
	ie_addr_xy := Integer(Temp^);
    end;
    DeadKeyConvert := RawKeyConvert(Adr(Event), Buffer, BufSize, KeyMap);
end;
