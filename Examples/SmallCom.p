Program SmallCom;

{
    This program is a simplistic terminal program, which has
basically no features, but works reasonably well.  It is an ANSI
compatible terminal to the extent that the console.device is - it
simply passes incoming data, from the keyboard or the serial device,
to the console device.

    To gain some control over the program, you might want to take a look
at the translated characters (after the call to DeadKeyConvert), and
process a few (function keys, for example) instead of sending them on
to the console.device.
}

{$I "Include:Exec/Interrupts.i"}
{$I "Include:Exec/Libraries.i"}
{$I "Include:Exec/Ports.i"}
{$I "Include:Exec/IO.i"}
{$I "Include:Exec/Devices.i"}
{$I "Include:Devices/Console.i"}
{$I "Include:Utils/IOUtils.i"}
{$I "Include:Utils/ConsoleIO.i"}
{$I "Include:Intuition/Intuition.i"}
{$I "Include:Devices/InputEvent.i"}
{$I "Include:Utils/DeadKeyConvert.i"}
{$I "Include:Utils/BuildMenu.i"}
{$I "Include:Devices/Serial.i"}
{$I "Include:Exec/Memory.i"}
{$I "Include:Utils/StringLib.i"}


Type
    ParityType = (no_parity, even_parity, odd_parity);

Const
    w		: WindowPtr = Nil;
    SerialWrite	: IOExtSerPtr = Nil;
    SerialRead	: IOExtSerPtr = Nil;
    ConsoleWrite : IOStdReqPtr = Nil;

    WritingConsole	: Boolean = False;
    WritingSerial	: Boolean = False;

    SerialSendBuffer	: String = Nil;
    ConsoleSendBuffer	: String = Nil;
    SerialReceiveBuffer : String = Nil;
    TranslateBuffer	: String = Nil;

    BaudRate	: Integer = 2400;
    DataBits	: Byte = 8;
    Parity	: ParityType = no_parity;
    StopBits	: Byte = 1;
    HalfDuplex	: Boolean = False;

    QuitStopDie	: Boolean = False;

    BaudRates	: Array [0..7] of Integer = (300, 1200, 2400,
					     4800, 9600, 19200,
					     38400,115200);

var
    IMessage	: IntuiMessage;
    Msg		: MessagePtr;
    TitleBuffer : Array [0..79] of Char;

Procedure MakeWindowTitle;
var
    TitlePtr : String;
    NumBuff  : Array [0..79] of Char;
    Error    : Integer;
begin
    TitlePtr := Adr(TitleBuffer);
    strcpy(TitlePtr, "SmallCom     ");
    Error := IntToStr(Adr(NumBuff), BaudRate);
    strcat(TitlePtr, Adr(NumBuff));
    NumBuff[0] := ' ';
    NumBuff[1] := Chr(DataBits + 48);
    case Parity of
      no_parity	: NumBuff[2] := 'N';
      even_parity : NumBuff[2] := 'E';
      odd_parity  : NumBuff[2] := 'O';
    end;
    NumBuff[3] := Chr(StopBits + 48);
    NumBuff[4] := '\0';
    strcat(TitlePtr, Adr(NumBuff));
    SetWindowTitles(w, TitlePtr, Nil);
end;

Function OpenTheWindow : Boolean;
var
    nw : NewWindowPtr;
begin
    new(nw);
    with nw^ do begin
	LeftEdge := 0;
	TopEdge := 0;
	Width := 320;
	Height := 200;

	DetailPen := -1;
	BlockPen  := -1;
	IDCMPFlags := RAWKEY_f + MENUPICK_f + CLOSEWINDOW_f;
	Flags := SMART_REFRESH + ACTIVATE + WINDOWSIZING + WINDOWDRAG +
			WINDOWDEPTH + WINDOWCLOSE + SIZEBBOTTOM;
	FirstGadget := Nil;
	CheckMark := Nil;
	Title := "";
	Screen := Nil;
	BitMap := Nil;
	MinWidth := 0;
	MaxWidth := -1;
	MinHeight := 0;
	MaxHeight := -1;
	WType := WBENCHSCREEN_f;
    end;

    w := OpenWindow(nw);
    dispose(nw);
    OpenTheWindow := w <> nil;
end;

Procedure AddTheMenus;
begin
    InitializeMenu(w);
    NewMenu("Project");
    NewItem("Quit",'Q');
    NewMenu("Serial");

    NewItem("Baud Rate",'\0');
    NewSubItem("   300", '1');
    NewSubItem("  1200", '2');
    NewSubItem("  2400", '3');
    NewSubItem("  4800", '4');
    NewSubItem("  9600", '5');
    NewSubItem(" 19200", '6');
    NewSubItem(" 38400", '7');
    NewSubItem("115200", '8');

    NewItem("Data Size", '\0');
    NewSubItem("7N2", '\0');
    NewSubItem("7E1", '\0');
    NewSubItem("7O1", '\0');
    NewSubItem("8N1", '\0');

    NewItem("Duplex   ", '\0');
    NewSubItem("Half", 'H');
    NewSubItem("Full", 'F');

    AttachMenu;
end;


Function CreateExtIO(ioReplyPort : MsgPortPtr; Size : Integer) : Address;
var
    Request : IOStdReqPtr;
begin
    if ioReplyPort = Nil then
	CreateExtIO := Nil;

    Request := AllocMem(Size, MEMF_CLEAR + MEMF_PUBLIC);
    if Request = Nil then
	CreateExtIO := Nil;

    with Request^.io_Message.mn_Node do begin
	ln_Type := NTMessage;
	ln_Pri := 0;
    end;
    Request^.io_Message.mn_ReplyPort := ioReplyPort;
    CreateExtIO := Request;
end;


Procedure DeleteExtIO(Request : Address; Size : Integer);
var
    Req : IOStdReqPtr;
begin
    Req := Request;
    with Req^ do begin
	io_Message.mn_Node.ln_Type := NodeType($FF);
	io_Device := Address(-1);
	io_Unit := Address(-1);
    end;
    FreeMem(Request, Size);
end;


Procedure Die;
var
    Error : Integer;
begin
    if SerialWrite <> Nil then begin
	if CheckIO(SerialRead) = Nil then begin
	    Error := AbortIO(SerialRead);
	    Error := WaitIO(SerialRead);
	end;
	CloseDevice(SerialWrite);
	DeleteExtIO(SerialWrite, SizeOf(IOExtSer));
	if SerialRead <> Nil then
	    DeleteExtIO(SerialRead, SizeOf(IOExtSer));
    end;

    if ConsoleWrite <> Nil then begin
	CloseDevice(ConsoleWrite);
	DeleteStdIO(ConsoleWrite);
    end;
    if w <> Nil then begin
	DetachMenu;
	DisposeMenu;
	Forbid;
	while GetMsg(w^.UserPort) <> Nil do;
	Permit;
	CloseWindow(w);
    end;
    Exit(0);
end;

Procedure SendSerial(IO : IOExtSerPtr; Data : Address; Size : Integer);
var
    Error : Short;
begin
    with IO^.IOSer do begin
	io_Data := Data;
	io_Length := Size;
	io_Command := CMD_WRITE;
    end;
    Error := DoIO(IO);
end;

Procedure QueueSerialRead;
var
    Waiting : Integer;
begin
    with SerialRead^.IOSer do begin
	io_Command := SDCMD_QUERY;
	Waiting := DoIO(SerialRead);
	Waiting := io_Actual;
	if Waiting = 0 then
	    Waiting := 1
	else if Waiting > 80 then
	    Waiting := 80;
	io_Length := Waiting;
	io_Command := CMD_READ;
	io_Data := SerialReceiveBuffer;
    end;
    SendIO(SerialRead);
end;


Procedure SetSerialParams;
var
    Error : Short;
begin
    with SerialWrite^ do begin
	io_ReadLen	:= DataBits;
	io_BrkTime	:= 750000;
	io_Baud		:= BaudRate;
	io_WriteLen	:= DataBits;
	io_StopBits	:= StopBits;
	io_RBufLen	:= 4000;
	io_TermArray.TermArray0 := $51040303;
	io_TermArray.TermArray1 := $03030303;
	io_CtlChar	:= SER_DEFAULT_CTLCHAR;
	case parity of
	  no_parity	: io_SerFlags := 0;
	  even_parity	: io_SerFlags := SERF_PARTY_ON;
	  odd_parity	: io_SerFlags := SERF_PARTY_ON + SERF_PARTY_ODD;
	end;
	IOSer.io_Command := SDCMD_SETPARAMS;
    end;
    if CheckIO(SerialRead) = Nil then begin
	Error := AbortIO(SerialRead);
	Error := WaitIO(SerialRead);
    end;
    Error := DoIO(SerialWrite);
    if Error <> 0 then
	ConWrite(ConsoleWrite, "\nError setting serial port paramters\n",37);
    QueueSerialRead;
    MakeWindowTitle;
end;


Function OpenSerialDevice : Boolean;
var
    Error : Short;
begin
    SerialWrite := CreateExtIO(w^.UserPort, SizeOf(IOExtSer));
    if SerialWrite = Nil then
	OpenSerialDevice := False;
    SerialRead := CreateExtIO(w^.UserPort, SizeOf(IOExtSer));
    if SerialWrite = Nil then begin
	DeleteExtIO(SerialWrite, SizeOf(IOExtSer));
	SerialWrite := Nil;
	OpenSerialDevice := False;
    end;

    with SerialWrite^ do begin
	io_ReadLen	:= DataBits;
	io_BrkTime	:= 750000;
	io_Baud		:= BaudRate;
	io_WriteLen	:= DataBits;
	io_StopBits	:= StopBits;
	io_RBufLen	:= 4000;
	io_SerFlags	:= 0;
	io_SerFlags	:= 0;
    end;

    Error := OpenDevice("serial.device", 0, SerialWrite, 0);

    if Error = 0 then begin
	SerialRead^ := SerialWrite^;
	QueueSerialRead;
	SetSerialParams;
	OpenSerialDevice := True;
    end else begin
	DeleteExtIO(SerialWrite, SizeOf(IOExtSer));
	DeleteExtIO(SerialRead, SizeOf(IOExtSer));
	SerialWrite := Nil;
	OpenSerialDevice := False;
    end;
end;


Function OpenConsoleDevice : Boolean;
var
    Error : Short;
begin
    ConsoleWrite := CreateStdIO(w^.UserPort);
    if ConsoleWrite = Nil then
	OpenConsoleDevice := False;

    with ConsoleWrite^ do begin
	io_Data := w;
	io_Length := SizeOf(Window);
    end;

    Error := OpenDevice("console.device", 0, ConsoleWrite, 0);
    if Error = 0 then
	ConsoleBase := ConsoleWrite^.io_Device
    else
	DeleteStdIO(ConsoleWrite);
    OpenConsoleDevice := Error = 0;
end;


Procedure OpenEverything;
begin
    SerialSendBuffer	:= AllocString(80);
    ConsoleSendBuffer	:= AllocString(80);
    SerialReceiveBuffer := AllocString(80);
    TranslateBuffer	:= AllocString(80);
    
    if not OpenTheWindow then
	Die;

    AddTheMenus;

    if not OpenConsoleDevice then
	Die;

    if not OpenSerialDevice then
	Die;
end;


Procedure ProcessIntuitionMsg;
var
    IMessage	: IntuiMessage;
    IPtr	: IntuiMessagePtr;

    Procedure ProcessMenu;
    var
	MenuNumber	: Short;
	ItemNumber	: Short;
	SubItemNumber	: Short;
    begin
	if IMessage.Code = MENUNULL then
	    return;

	MenuNumber := MenuNum(IMessage.Code);
	ItemNumber := ItemNum(IMessage.Code);
	SubItemNumber := SubNum(IMessage.Code);

	case MenuNumber of
	  0 : if ItemNumber = 0 then
		 QuitStopDie := True;
	  1 : begin
		  case ItemNumber of
		    0 : BaudRate := BaudRates[SubItemNumber];
		    1 : case SubItemNumber of
			  0 : begin
				  DataBits := 7;
				  Parity   := no_parity;
				  StopBits := 2;
			      end;
			  1 : begin
				  DataBits := 7;
				  Parity   := even_parity;
				  StopBits := 1;
			      end;
			  2 : begin
				  DataBits := 7;
				  Parity   := odd_parity;
				  StopBits := 1;
			      end;
			  3 : begin
				  DataBits := 8;
				  Parity   := no_parity;
				  StopBits := 1;
			      end;
			end;
		    2 : HalfDuplex := SubItemNumber = 0;
		  end;
		  if ItemNumber < 2 then
		      SetSerialParams;
	      end;
	end;
    end;


    Procedure ProcessKeypress;
    var
	Length	: Short;
	Buffer	: Array [0..79] of Char;
    begin
	if IMessage.Code < 128 then begin
	    Length := DeadKeyConvert(Adr(IMessage), TranslateBuffer, 79, Nil);
	    if Length > 0 then begin
		if HalfDuplex then
		    ConWrite(ConsoleWrite, TranslateBuffer, Length);
		SendSerial(SerialWrite, TranslateBuffer, Length);
	    end;
	end;
    end;

begin
    IPtr := IntuiMessagePtr(Msg);
    IMessage := IPtr^;
    ReplyMsg(Msg);

    case IMessage.Class of
      MENUPICK_f : ProcessMenu;
      RAWKEY_f   : ProcessKeypress;
      CLOSEWINDOW_f : QuitStopDie := True;
    end;
end;

Procedure ProcessSerialInput;
begin
    with SerialRead^.IOSer do begin
	if io_Actual > 0 then
	    ConWrite(ConsoleWrite, SerialReceiveBuffer, io_Actual);
    end;
    QueueSerialRead;
end;

begin
    OpenEverything;
    repeat
	Msg := WaitPort(w^.UserPort);
	Msg := GetMsg(w^.UserPort);
	if Msg = MessagePtr(SerialRead) then
	    ProcessSerialInput
	else
	    ProcessIntuitionMsg;
    until QuitStopDie;
    Die;
end.
