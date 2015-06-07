{
	Timer.i for PCQ Pascal
}

{$I "Include:Exec/IO.i"}

Const

{ unit defintions }
    UNIT_MICROHZ	= 0;
    UNIT_VBLANK		= 1;

    TIMERNAME		= "timer.device";

Type

    timeval = record
	tv_secs		: Integer;
	tv_micro	: Integer;
    end;
    timevalPtr = ^timeval;


    timerequest = record
	tr_node		: IORequest;
	tr_time		: timeval;
    end;
    timerequestPtr = ^timerequest;

Const

{ IO_COMMAND to use for adding a timer }
    TR_ADDREQUEST	= CMD_NONSTD;
    TR_GETSYSTIME	= CMD_NONSTD + 1;
    TR_SETSYSTIME	= CMD_NONSTD + 2;

{  To use any of the routines below, TimerBase must be set to point
   to the timer.device, either by calling CreateTimer or by pulling
   the device pointer from a valid TimeRequest, i.e.

	TimerBase := TimeRequest.io_Device;

    _after_ you have called OpenDevice on the timer.
 }

var
    TimerBase	: Address;

{ Dest := Dest + Source }

Procedure AddTime(VAR Dest, Source : TimeVal);
    External;

Function CmpTime(VAR Dest, Source : TimeVal) : Integer;
    External;

{ Dest := Dest - Source }

Procedure SubTime(VAR Dest, Source : TimeVal);
    External;
