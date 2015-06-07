Program DeadKeysPlus;

{
    This program is the same as an older program called DeadKeys,
which used the DeadKeyConvert() and RawKeyConvert() functions to
get keystrokes in a very compatible way.  To that I have added
mostly useless menus, which are an example of the use of the
BuildMenu routines.  These, in turn, exercise the Intuition menu
functions.
    To make a long story short, if you are looking for an example
of DeadKeyConvert() or BuildMenu it's in here somewhere.

    Although you would certainly want the code to be more modular
and you would need to design a data structure, this is the barest
bones of a text editor.
}

{$I "Include:Exec/Interrupts.i"}
{$I "Include:Exec/Libraries.i"}
{$I "Include:Exec/Ports.i"}
{$I "Include:Exec/IO.i"}
{$I "Include:Exec/Devices.i"}
{$I "Include:Utils/IOUtils.i"}
{$I "Include:Intuition/Intuition.i"}
{$I "Include:Devices/InputEvent.i"}
{$I "Include:Utils/ConsoleUtils.i"}
{$I "Include:Utils/ConsoleIO.i"}
{$I "Include:Utils/DeadKeyConvert.i"}
{$I "Include:Utils/BuildMenu.i"}

var
    w  : WindowPtr;
    s  : Address;

Function OpenTheScreen : Boolean;
var
    ns : NewScreenPtr;
begin
    new(ns);
    with ns^ do begin
	LeftEdge := 0;
	TopEdge  := 0;
	Width    := 640;
	Height   := 200;
	Depth    := 2;
	DetailPen := 3;
	BlockPen  := 2;
	ViewModes := 32768;
	SType     := CUSTOMSCREEN_f;
	Font      := Nil;
	DefaultTitle := "Press ESC or choose Quit to End the Demonstration";
	Gadgets   := nil;
	CustomBitMap := nil;
    end;
    s := OpenScreen(ns);
    dispose(ns);
    OpenTheScreen := s <> nil;
end;

Function OpenTheWindow : Boolean;
var
    nw : NewWindowPtr;
begin
    new(nw);
    with nw^ do begin
	LeftEdge := 0;
	TopEdge := 2;
	Width := 640;
	Height := 198;

	DetailPen := -1;
	BlockPen  := -1;
	IDCMPFlags := RAWKEY_f + MENUPICK_f;
	Flags := SMART_REFRESH + ACTIVATE +
			BORDERLESS + BACKDROP;
	FirstGadget := Nil;
	CheckMark := Nil;
	Title := "";
	Screen := s;
	BitMap := Nil;
	MinWidth := 0;
	MaxWidth := -1;
	MinHeight := 0;
	MaxHeight := -1;
	WType := CUSTOMSCREEN_f;
    end;

    w := OpenWindow(nw);
    dispose(nw);
    OpenTheWindow := w <> nil;
end;

var
    IMessage	: IntuiMessagePtr;
    Buffer	: Array [0..9] of Char;
    Length	: Integer;
    Leave	: Boolean;
    WriteReq	: IOStdReqPtr;
    WritePort	: MsgPortPtr;

Function AddTheMenus : Boolean;
begin
    InitializeMenu(w);
    NewMenu("Project");
    NewItem("New ",'N');
    NewItem("Load",'L');
    NewItem("Save",'S');
    NewItem("Quit",'Q');
    NewMenu("Action");
    NewItem("Defoliate      ",'D');
    NewItem("Repack Bearings",'R');
    NewItem("Mince        >>",'\0');
    NewSubItem("Slice   ", '1');
    NewSubItem("Dice    ", '2');
    NewSubItem("Julienne", '3');
    NewItem("Floss          ",'F');
    AttachMenu;
    AddTheMenus := True;
end;

Procedure LoseTheMenus;
begin
    DetachMenu;
end;

Procedure OpenEverything;
var
    Error : Short;
begin
    OpenConsoleDevice;
    if OpenTheScreen then begin
	if OpenTheWindow then begin
	    if AddTheMenus then begin
		WritePort := CreatePort(Nil, 0);
		if WritePort <> Nil then begin
		    WriteReq := CreateStdIO(WritePort);
		    if WriteReq <> Nil then begin
			WriteReq^.io_Data := Address(w);
			WriteReq^.io_Length := SizeOf(Window);
			Error := OpenDevice("console.device", 0,
						IORequestPtr(WriteReq), 0);
			if Error = 0 then
			    return;
			DeleteStdIO(WriteReq);
			Writeln('Could not open the console.device');
		    end else
			Writeln('Could not allocate memory');
		    DeletePort(WritePort);
		end else
		    Writeln('Could not allocate a message port');
		LoseTheMenus;
	    end else
		Writeln('Could not attach the menus');
	    CloseWindow(w);
	end else
	    Writeln('Could not open the window');
	CloseScreen(s);
    end else
	Writeln('Could not open the screen');
    CloseConsoleDevice;
    Exit(20);
end;

Procedure CloseEverything;
begin
    CloseDevice(IORequestPtr(WriteReq));
    DeleteStdIO(WriteReq);
    DeletePort(WritePort);
    LoseTheMenus;
    CloseWindow(w);
    CloseScreen(s);
    CloseConsoleDevice;
end;

Procedure ConvertControl;
begin
    case Ord(Buffer[0]) of
      8 : ConPutStr(WriteReq, "\b\cP");
     13 : ConPutStr(WriteReq, "\n\cL");
     127 : ConPutStr(WriteReq, "\cP");
    else
	ConPutChar(WriteReq, Buffer[0]);
    end;
end;

Procedure ConvertTwoChar;
begin
    case Buffer[1] of
      'A'..'D' : ConWrite(WriteReq, Adr(Buffer), 2);
    end;
end;

begin
    OpenEverything;
    Leave := False;
    repeat
	IMessage := IntuiMessagePtr(WaitPort(w^.UserPort));
	IMessage := IntuiMessagePtr(GetMsg(w^.UserPort));
	if IMessage^.Class = RAWKEY_f then begin
	    if IMessage^.Code < 128 then begin { Key Down }
		Length := DeadKeyConvert(IMessage, Adr(Buffer), 10, Nil);
		case Length of
		  -MaxInt..-1 : ConWrite(WriteReq, "DeadKeyConvert error",20);
		   1 : if Buffer[0] = '\e' then
			   Leave := True
			else begin
			    if (Buffer[0] < ' ') or
				(Ord(Buffer[0]) > 126) then
				ConvertControl
			    else begin
				Buffer[2] := Buffer[0];
				Buffer[0] := '\c';
				Buffer[1] := '@'; { Insert }
				ConWrite(WriteReq, Adr(Buffer), 3);
			    end;
			end;
		   2 : ConvertTwoChar;
		end;
	    end;
	end else if IMessage^.Class = MENUPICK_f then begin
	    if IMessage^.Code = MENUNULL then
		ConWrite(WriteReq, "\nNo item", 8)
	    else begin
		Buffer[0] := Chr(MenuNum(IMessage^.Code) + Ord('0'));
		Buffer[1] := '\n';
		ConWrite(WriteReq, "\nMenu Number: ", 14);
		ConWrite(WriteReq, Adr(Buffer), 2);
		Buffer[0] := Chr(ItemNum(IMessage^.Code) + Ord('0'));
		ConWrite(WriteReq, "Item Number: ", 13);
		ConWrite(WriteReq, Adr(Buffer), 2);
		if SubNum(IMessage^.Code) <> NOSUB then begin
		    Buffer[0] := Chr(SubNum(IMessage^.Code) + Ord('0'));
		    ConWrite(WriteReq, "Sub Number : ", 13);
		    ConWrite(WriteReq, Adr(Buffer), 2);
		end;
		if (MenuNum(IMessage^.Code) = 0) and
		    (ItemNum(IMessage^.Code) = 3) then
		    Leave := True;
	    end;
	end else { Must be CloseWindow }
	    Leave := True;
	ReplyMsg(MessagePtr(IMessage));
    until Leave;
    Forbid;
    repeat
	IMessage := IntuiMessagePtr(GetMsg(w^.UserPort));
    until IMessage = nil;
    Permit;
    CloseEverything;
end.
