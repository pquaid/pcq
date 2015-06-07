Program TimeProg;

{

	TimeProg ProgramName

	Accurately times the execution of ProgramName.

	A very simple example of using the timer.device and its
    support functions, as well as using the RunProgram routines.
    Note that this program will not work with programs that require
    the CLI, nor will it work for the standard BCPL programs at all.
}

{$I "Include:Devices/Timer.i"}
{$I "Include:Utils/TimerUtils.i"}
{$I "Include:Utils/RunProgram.i"}
{$I "Include:Libraries/DOSExtens.i"}
{$I "Include:Utils/StringLib.i"}
{$I "Include:Utils/Parameters.i"}


var
    T : TimeRequestPtr;
    StartTime,
    EndTime : TimeVal;

    ProgramName : String;
    ProgPtr	: BPTR;

begin
    ProgramName := AllocString(256);
    GetParam(1, ProgramName);
    if ProgramName^ = '\0' then begin
	Writeln('Usage: TimeProg Progname');
	Exit(10);
    end;

    ProgPtr := LoadSeg(ProgramName);
    if ProgPtr = Nil then begin
	Writeln('Could not load ', ProgramName);
	Exit(10);
    end;

    T := CreateTimer(UNIT_MICROHZ);
	
    if T <> Nil then begin
	GetSysTime(T, StartTime);
	if RunSegment("TimeProg.sub", ProgPtr, 8000) then begin
	    GetSysTime(T, EndTime);
	    SubTime(EndTime, StartTime);
	    Writeln('Difference: ', Float(EndTime.tv_Secs and $FFFF) +
				Float(EndTime.tv_Micro) / 1000000.0:0:8);
	end else
	    Writeln('Could not run the program');
	DeleteTimer(T);
	UnloadSeg(ProgPtr);
    end else
	Writeln('Could not open timer.');
end.
