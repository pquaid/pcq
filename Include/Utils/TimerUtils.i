{
	TimerUtils.i

	This file declares CreateTimer, WaitTimer, and DeleteTimer.
    They allow you to use the timer.device with relatively little
    overhead.  Note that, unlike the examples from the ROM Kernel
    Manual, these routines use the VBlank unit.  Therefore they
    require much less overhead, but you should not use these routines
    for times of less than half a second.
	The source for these routines is in Runtime/Extras.
}

{$I "Include:Exec/Ports.i"}
{$I "Include:Devices/Timer.i"}

Function CreateTimer(Unit : Integer) : TimeRequestPtr;
    External;

Function SetTimer(WhichTimer : TimeRequestPtr;
			Seconds, Microseconds : Integer) : MsgPortPtr;
    External;

Procedure WaitTimer(WhichTimer : TimeRequestPtr;
			Seconds, Microseconds : Integer);
    External;

Procedure GetSysTime(WhichTimer : TimeRequestPtr; VAR TV : TimeVal);
    External;

Procedure DeleteTimer(WhichTimer : TimeRequestPtr);
    External;
