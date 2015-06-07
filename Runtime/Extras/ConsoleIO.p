External;

{
	ConsoleIO.p

	This file implements all the normal console.device stuff for
dealing with windows.  They are pulled from the ROM Kernel Manual.
See ConsoleTest.p for an example of using these routines.
}


{$I "Include:Exec/IO.i"}
{$I "Include:Exec/Ports.i"}

Procedure ConPutChar(Request : IOStdReqPtr; Character : Char);
var
    Error : Integer;
begin
    Request^.io_Command := CMD_WRITE;
    Request^.io_Data := Adr(Character);
    Request^.io_Length := 1;
    Error := DoIO(IORequestPtr(Request));
end;

Procedure ConWrite(Request : IOStdReqPtr; Str : String; length : Integer);
var
   Error : Integer;
begin
    Request^.io_Command := CMD_WRITE;
    Request^.io_Data := Str;
    Request^.io_Length := Length;
    Error := DoIO(IORequestPtr(Request));
end;

Procedure ConPutStr(Request : IOStdReqPtr; Str : String);
var
    Error : Integer;
begin
    Request^.io_Command := CMD_WRITE;
    Request^.io_Data := Str;
    Request^.io_Length := -1;
    Error := DoIO(IORequestPtr(Request));
end;

Procedure QueueRead(Request : IOStdReqPtr; Where : String);
begin
    Request^.io_Command := CMD_READ;
    Request^.io_Data := Where;
    Request^.io_Length := 1;
    SendIO(IORequestPtr(Request));
end;

Function ConGetChar(consolePort : MsgPortPtr; Request : IOStdReqPtr;
			WhereTo : String) : Char;
var
    Temp : Char;
    TempMsg : MessagePtr;
begin
    if GetMsg(consolePort) = Nil then begin
	TempMsg := WaitPort(consolePort);
	TempMsg := GetMsg(consolePort);
    end;
    Temp := WhereTo^;
    QueueRead(Request, WhereTo);
    ConGetChar := Temp;
end;
