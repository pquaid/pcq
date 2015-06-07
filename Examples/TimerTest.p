Program TimerTest;

{
	A very simple example of using the timer.device and its
    support functions.
}

{$I "Include:Devices/Timer.i"}
{$I "Include:Utils/TimerUtils.i"}

var
    T : TimeRequestPtr;
    StartTime,
    EndTime : TimeVal;

begin
    T := CreateTimer(UNIT_VBLANK);
    if T <> Nil then begin
	GetSysTime(T, StartTime);
	Writeln('Started at ', Float(StartTime.tv_Secs and $FFFF) +
				(Float(StartTime.tv_Micro) / 1000000.0):0:8);
	Writeln('Wait about 4 seconds....');
	WaitTimer(T, 4, 0);
	GetSysTime(T, EndTime);
	Writeln('Ended at   ', Float(EndTime.tv_Secs and $FFFF) + 
				(Float(EndTime.tv_Micro) / 1000000.0):0:8);
	SubTime(EndTime, StartTime);
	Writeln('Difference: ', Float(EndTime.tv_Secs and $FFFF) +
				Float(EndTime.tv_Micro) / 1000000.0:0:8);
	DeleteTimer(T);
    end else
	Writeln('Could not open timer.');
end.
