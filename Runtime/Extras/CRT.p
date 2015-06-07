External;

{
	CRT.p

	These routines are a simple attempt to mimic the Turbo Pascal
    CRT routines.  See ConsoleTest.p for an example of using these.
    The WhereX/Y routines should go in CRT2.p, but they are small and
    require the complete definition for the consoleset.
}

{$I "Include:Exec/IO.i"}
{$I "Include:Utils/IOUtils.i"}
{$I "Include:Devices/ConUnit.i"}
{$I "Include:Intuition/Intuition.i"}
{$I "Include:Exec/Devices.i"}
{$I "Include:Utils/ConsoleIO.i"}
{$I "Include:Exec/Interrupts.i" for Forbid and Permit }

TYPE
    ConsoleSet = record
		     WritePort,
		     ReadPort	: MsgPortPtr;
		     WriteRequest,
		     ReadRequest : IOStdReqPtr;
		     Window	: WindowPtr; { not yet used }
		     Buffer	: Char;
		 end;
    ConsoleSetPtr = ^ConsoleSet;

Procedure CleanSet(con : ConsoleSetPtr);
begin
    with con^ do begin
	if ReadRequest <> Nil then
	    DeleteStdIO(ReadRequest);
	if WriteRequest <> Nil then
	    DeleteStdIO(WriteRequest);
	if ReadPort <> Nil then
	    DeletePort(ReadPort);
	if WritePort <> Nil then
	    DeletePort(WritePort);
    end;
end;

Function AttachConsole(w : WindowPtr) : ConsoleSetPtr;
var
    con : ConsoleSetPtr;
    Error : Boolean;
begin
    New(con);
    if con = Nil then
	AttachConsole := Nil;
    with Con^ do begin
	WritePort := CreatePort(Nil, 0);
	Error := WritePort = Nil;
	ReadPort  := CreatePort(Nil, 0);
	Error := Error or (ReadPort = Nil);
	if not Error then begin
	    WriteRequest := CreateStdIO(WritePort);
	    Error := Error or (WriteRequest = Nil);
	    ReadRequest := CreateStdIO(ReadPort);
	    Error := Error or (ReadRequest = Nil);
	end;
	if Error then begin
	    CleanSet(con);
	    Dispose(con);
	    AttachConsole := Nil;
	end;
	Window := w;
    end;
    with con^.WriteRequest^ do begin
	io_Data := Address(w);
	io_Length := SizeOf(Window);
    end;
    Error := OpenDevice("console.device", 0,
			IORequestPtr(con^.WriteRequest), 0) <> 0;
    if Error then begin
	CleanSet(con);
	Dispose(con);
	AttachConsole := Nil;
    end;
    with con^ do begin
	ReadRequest^.io_Device := WriteRequest^.io_Device;
	ReadRequest^.io_Unit := WriteRequest^.io_Unit;
    end;
    QueueRead(con^.ReadRequest, Adr(con^.Buffer));
    AttachConsole := Con;
end;

Function ReadKey(con : ConsoleSetPtr) : Char;
begin
    with con^ do
	ReadKey := ConGetChar(ReadPort, ReadRequest, Adr(Buffer));
end;

Function KeyPressed(con : ConsoleSetPtr) : Boolean;
begin
    with con^ do
	KeyPressed := CheckIO(IORequestPtr(ReadRequest)) <> Nil;
end;

Procedure WriteString(con : ConsoleSetPtr; Str : String);
begin
    ConPutStr(con^.WriteRequest, Str);
end;

Function MaxX(con : ConsoleSetPtr) : Short;
var
    CU : ConUnitPtr;
begin
    CU := ConUnitPtr(con^.WriteRequest^.io_Unit);
    MaxX := CU^.cu_XMax;
end;

Function MaxY(con : ConsoleSetPtr) : Short;
var
    CU : ConUnitPtr;
begin
    CU := ConUnitPtr(con^.WriteRequest^.io_Unit);
    MaxY := CU^.cu_YMax;
end;

Function WhereX(con : ConsoleSetPtr) : Short;
var
    CU : ConUnitPtr;
begin
    CU := ConUnitPtr(con^.WriteRequest^.io_Unit);
    WhereX := CU^.cu_XCP;
end;

Function WhereY(con : ConsoleSetPtr) : Short;
var
    CU : ConUnitPtr;
begin
    CU := ConUnitPtr(con^.WriteRequest^.io_Unit);
    WhereY := CU^.cu_YCP;
end;

Procedure TextColor(con : ConsoleSetPtr; pen : Byte);
var
    CU : ConUnitPtr;
begin
    CU := ConUnitPtr(con^.WriteRequest^.io_Unit);
    CU^.cu_FgPen := pen;
end;

Procedure TextBackground(con : ConsoleSetPtr; pen : Byte);
var
    CU : ConUnitPtr;
begin
    CU := ConUnitPtr(con^.WriteRequest^.io_Unit);
    CU^.cu_BgPen := pen;
end;

Procedure DetachConsole(con : ConsoleSetPtr);
var
    TempMsg : MessagePtr;
    Error   : Integer;
begin
    with con^ do begin
	Forbid;
	if CheckIO(IORequestPtr(ReadRequest)) = Nil then begin
	    Error := AbortIO(IORequestPtr(ReadRequest));
	    Permit;
	    TempMsg := WaitPort(ReadPort);
	    TempMsg := GetMsg(ReadPort);
	end else
	    Permit;
	CloseDevice(IORequestPtr(WriteRequest));
    end;
    CleanSet(con);
    Dispose(con);
end;
