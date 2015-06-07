External;

{
	Profile.p of PCQ Pascal

    This file implements the PCQ execution profiler.  In order
    to minimize conflicts with program variables and routine
    names, the normal program with look for names beginning
    with _p%, which are explicitly exported using the $A
    directive near the bottom of the program.  For the same
    reason, the $SP directive is used to ensure that no other
    names get exported.

    This version of the execution profiler uses a vertical
    blank counter, which is relatively fast but doesn't have
    much resolution.  A preliminary version used the timer
    device's MICROHZ unit, but doing a DoIO every time was
    just too slow.

    The profiler is designed so that most modifications can take
    place in this file - with any luck, you should be able to
    customize the system without having to modify the compiler
    itself.
}

{$I "Include:Exec/Ports.i"}
{$I "Include:Exec/Tasks.i"}
{$I "Include:Exec/Libraries.i"}
{$I "Include:Exec/ExecBase.i"}
{$I "Include:Graphics/Graphics.i"}
{$I "Include:Graphics/View.i"}
{$I "Include:Utils/TaskUtils.i"}
{$I "Include:Utils/StringLib.i"}
{$I "Include:Utils/Break.i"}

{$SP}

type

    TagPtr		= ^TagArea;
    RegistrationPtr	= ^Registration;

    Registration = record
	TotalTime	: Integer;
	TotalCalls	: Integer;
	Tag		: TagPtr;
    end;

    TagArea = record
	Registration	: RegistrationPtr;
	Name		: String;
    end;

    ProcCallPtr = ^ProcCall;

    ProcCall = record
	Registration	: RegistrationPtr;
	StartTime	: Integer;
    end;

Const
    VBlank_Count : Integer = 0;
    KillSubTask  : Boolean = False;
    SubTaskPtr   : TaskPtr = Nil;

var
    Registry	: Array [0..999] of Registration;
    NextReg	: Integer;

    ProcStack	: Array [0..499] of ProcCall;
    NextProc	: Integer;

    SaveExit	: Address;

{
    This routine runs as a seperate task (NOT a process).
    It runs at a very high priority, so it shouldn't do
    much before it waits.
}

Procedure Counter_SubTask;
begin
    repeat
	WaitTOF;
	Inc(VBlank_Count);
    until KillSubTask;

    KillSubTask := False;
    if Wait(0) = 0 then;  { Wait for the end }
end;

{
    OpenTimer initializes whatever the routines are using as
    a timer.  In this case it just creates a high-priority
    task and returns.
}

Procedure OpenTimer;
begin
    GfxBase := OpenLibrary("graphics.library",0);
    if GfxBase = Nil then
	Exit(20);

    SubTaskPtr := CreateTask("PCQ_Pro",12,Adr(Counter_SubTask),1000);
end;

Procedure ReportProfiles;
    Forward;


{
    PreRegister is called by the main routine instead of
    Register.  It initializes the whole system.
}

Procedure PreRegister(CallTag : TagPtr);
begin
    SaveExit := ExitProc;
    ExitProc := @ReportProfiles;

    NextReg  := 1;
    NextProc := 1;

    CallTag^.Registration := @Registry[0];
    with Registry[0] do begin
	TotalTime := 0;
	TotalCalls := 1;
	Tag := CallTag;
    end;

    ProcStack[0].Registration := @Registry[0];

    OpenTimer;

    ProcStack[0].StartTime := VBlank_Count;
end;

{
    Register

    This routine is called at the entrance to each routine.  It
    allocates a Registration slot for the routine if it doesn't
    already have one, takes care of the elapsed time for the
    previous routine, and marks the start time for the current
    routine.
}

Procedure Register(CallTag : TagPtr);
var
    LeaveReg,
    EnterReg	: RegistrationPtr;
    LeaveProc,
    EnterProc	: ProcCallPtr;
begin
    EnterReg := CallTag^.Registration;
    if EnterReg = Nil then begin
	with Registry[NextReg] do begin
	    TotalTime := 0;
	    Tag := CallTag;
	end;
	EnterReg := @Registry[NextReg];
	CallTag^.Registration := EnterReg;

	Inc(NextReg);
    end;

    Inc(EnterReg^.TotalCalls);

    with ProcStack[NextProc] do begin
	Registration := EnterReg;
	StartTime := VBlank_Count;
    end;

    LeaveProc := @ProcStack[Pred(NextProc)];
    LeaveReg := LeaveProc^.Registration;

    LeaveReg^.TotalTime := LeaveReg^.TotalTime +
				(VBlank_Count - LeaveProc^.StartTime);

    Inc(NextProc);
end;


{
    Deregister is called at the exit of every routine.  It
    calculates the elapsed time, and adds it to the routine's
    total.  It also pops the procedure execution off the stack.
}

Procedure Deregister;
var
    LeaveReg,
    EnterReg	: RegistrationPtr;
    LeaveProc,
    EnterProc	: ProcCallPtr;
begin

{$A	move.l	d0,-(sp) }

    Dec(NextProc);

    LeaveReg := ProcStack[NextProc].Registration;

    if NextProc > 0 then
	ProcStack[Pred(NextProc)].StartTime := VBlank_Count;

    LeaveReg^.TotalTime := LeaveReg^.TotalTime +
				(VBlank_Count - ProcStack[NextProc].StartTime);

{$A	move.l	(sp)+,d0 }

end;

{
    ReportProfiles is a normal exit procedure called at the
    program's termination.  It writes the names of all the
    routines, and all the other information.
}

Procedure ReportProfiles;
type
    AdrPtr	= ^Address;
var
    Reg		: Integer;
    TotalTicks	: Integer;
    i		: Integer;
    LeaveReg	: RegistrationPtr;
    SysBase	: ExecBasePtr;
begin

    ExitProc := SaveExit;

    while NextProc > 1 do begin
	Dec(NextProc);
	LeaveReg := ProcStack[NextProc].Registration;

	LeaveReg^.TotalTime := LeaveReg^.TotalTime +
			(VBlank_Count - ProcStack[NextProc].StartTime);
    end;

    { Inform the sub task that it can die now }

    KillSubTask := True;

    Writeln;
    Writeln('    Routine                 Calls    Total    Ticks    %');
    Writeln('                                    seconds  Per Call');
    Writeln('-------------------------------------------------------------');

    Reg := 0;
    TotalTicks := 0;
    while Reg < NextReg do begin
	with Registry[Reg] do
	    TotalTicks := TotalTicks + TotalTime;
	Inc(Reg);
    end;
    if TotalTicks < 1 then
	TotalTicks := 1;

    Reg := 0;

    SysBase := AdrPtr(4)^;

    while Reg < NextReg do begin

	if CheckBreak then
	    return;

	with Registry[Reg] do begin
	    Write(Tag^.Name);
	    for i := Succ(strlen(Tag^.Name)) to 25 do
		Write(' ');

	    Write(TotalCalls:7);

	    Writeln(TotalTime / SysBase^.VBlankFrequency:5:3,
		    TotalTime / TotalCalls:7:3,
		    TotalTime * 100.0 / TotalTicks:5:1);
	end;
	Inc(Reg);
    end;

    if SubTaskPtr <> Nil then begin

	{ It should be ready to leave by now }

	repeat until not KillSubTask;

	DeleteTask(SubTaskPtr);
    end;
    CloseLibrary(GfxBase);
end;

{$A
_p%PreRegister	equ	_PreRegister
_p%Register	equ	_Register
_p%Deregister	equ	_Deregister
_p%ReportProfiles equ	_ReportProfiles

	XDEF	_p%PreRegister
	XDEF	_p%Register
	XDEF	_p%Deregister
	XDEF	_p%ReportProfiles
}

