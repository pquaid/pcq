External;

{
	TimerUtils.p

	This file declares CreateTimer, WaitTimer, and DeleteTimer.
}

{$I "Include:Exec/Ports.i"}
{$I "Include:Devices/Timer.i"}
{$I "Include:Utils/IOUtils.i"}
{$I "Include:Exec/IO.i"}
{$I "Include:Exec/Devices.i"}

Function CreateTimer(Unit : Integer) : TimeRequestPtr;
var
    Error : Short;
    TimerPort : MsgPortPtr;
    TimeReq : IOStdReqPtr;
begin
    TimerPort := CreatePort(Nil, 0);
    if TimerPort = Nil then
	CreateTimer := Nil;
    TimeReq := CreateStdIO(TimerPort);
    if TimeReq = Nil then begin
	DeletePort(TimerPort);
	CreateTimer := Nil;
    end;
    Error := OpenDevice(TIMERNAME, Unit, IORequestPtr(TimeReq), 0);
    if Error <> 0 then begin
	DeleteStdIO(TimeReq);
	DeletePort(TimerPort);
	CreateTimer := Nil;
    end;
    TimerBase := TimeReq^.io_Device;
    CreateTimer := TimeRequestPtr(TimeReq);
end;

Function SetTimer(WhichTimer : TimeRequestPtr;
			Seconds, Microseconds : Integer) : MsgPortPtr;
var
    TempPort : MsgPortPtr;
begin
    with WhichTimer^ do begin
	TempPort := tr_Node.io_Message.mn_ReplyPort;
	tr_Node.io_Command := TR_ADDREQUEST;	{ add a new timer request }
	tr_Time.tv_Secs := Seconds;		{ seconds }
	tr_Time.tv_Micro := Microseconds;		{ microseconds }
        SendIO(IORequestPtr(WhichTimer));
	SetTimer := TempPort;
    end;
end;

Procedure WaitTimer(WhichTimer : TimeRequestPtr;
			Seconds, Microseconds : Integer);
var
    Error : Short;
begin
    with WhichTimer^ do begin
	tr_Node.io_Command := TR_ADDREQUEST;	{ add a new timer request }
	tr_Time.tv_Secs := Seconds;		{ seconds }
	tr_Time.tv_Micro := Microseconds;		{ microseconds }
	Error := DoIO(IORequestPtr(WhichTimer));
    end;
end;

Procedure GetSysTime(WhichTimer : TimeRequestPtr; VAR TV : TimeVal);
var
    Error : Short;
begin
    WhichTimer^.tr_Node.io_Command := TR_GETSYSTIME;
    Error := DoIO(IORequestPtr(WhichTimer));
    TV := WhichTimer^.tr_Time;
end;
	
Procedure DeleteTimer(WhichTimer : TimeRequestPtr);
var
    WhichPort : MsgPortPtr;
begin
    CloseDevice(IORequestPtr(WhichTimer));
    WhichPort := WhichTimer^.tr_Node.io_Message.mn_ReplyPort;
    DeleteStdIO(IOStdReqPtr(WhichTimer));
    DeletePort(WhichPort);
end;
