External;

{
    RunPrograms.i

    These routines let you run disk files or segments you have loaded
    as seperate processes, which means they can use AmigaDOS just
    like their parent.  Tasks, you will recall, are much simpler but
    can't use any DOS IO routines, which include Write() and Read().

    Programs run with these routines think they were run from the Workbench,
    so they must be able to handle that.  The typical CLI commands like
    "dir" and "copy" will NOT work with these routines.  Most PCQ Pascal
    programs should have no problems.

    Since these programs are run like Workbench programs, you can't just
    pass along a command line.  That lets out running, for example, the
    Pascal compiler...unless you mess around with the Workbench startup
    message, which will be transparent to the compiler.  That would work
    with some PCQ Pascal programs and probably no others.

    Since these routines use the normal PCQ memory allocation schemes,
    the calling program cannot end before all its called programs are
    finished.
}

{$I "Include:Exec/Ports.i"}
{$I "Include:Utils/Parameters.i"}
{$I "Include:Libraries/DOS.i"}
{$I "Include:Utils/IOUtils.i"}
{$I "Include:Utils/TaskUtils.i"}
{$I "Include:Libraries/DOSExtens.i"}

{  This record is used to track the allocations required for these
   routines.  If I add CLI support, this record may include pointers
   to other records, or in fact the records themselves.  }

type
    RunProgRec = Record
	Segment : Address;    { Segment of program if loaded by these routines }
	RPort   : MsgPortPtr; { Port that receives process finished message }
	WBMsg   : WBStartupPtr; { Startup message sent to task }
    end;
    RunProgPtr = ^RunProgRec;

Function RunSegmentNW(ProcName : String;
		      Segment : Address;
		      StackSize : Integer) : RunProgPtr;
{
    If you already have a segment loaded, run the segment as a process
    and return immediately.  If something went wrong, this routine
    will return Nil.  Otherwise, the new process is already running by
    the time this routine returns.
}

var
    RP	: RunProgPtr;
    Child : MsgPortPtr;
begin
    New(RP);
    RP^.RPort := CreatePort(Nil, 0);
    if RP^.RPort = Nil then begin
	Dispose(RP);
	RunSegmentNW := Nil;
    end;
    RP^.Segment := Nil;
    Child := MsgPortPtr(CreateProc(ProcName, 0,Segment,StackSize));
    if Child = Nil then begin
	DeletePort(RP^.RPort);
	Dispose(RP);
	RunSegmentNW := Nil;
    end;
    New(RP^.WBMsg);
    with RP^.WBMsg^ do begin
	with sm_Message do begin
	    mn_ReplyPort := RP^.RPort;
	    mn_Length := SizeOf(WBStartup);
	end;
	sm_Process := Child;
	sm_Segment := RP^.Segment;
	sm_NumArgs := 0;
	sm_ToolWindow := Nil;
	sm_ArgList := Nil;
    end;
    PutMsg(Child, MessagePtr(RP^.WBMsg));
    RunSegmentNW := RP;
end;

Function RunProgramNW(FileName : String; StackSize : Integer) : RunProgPtr;
{
    Load a file, then run it as a process.  Return without waiting for
    this new program to complete.  If something goes wrong, this routine
    will return Nil.  Otherwise, the program is running.
}
var
    Seg : Address;
    RP  : RunProgPtr;
begin
    Seg := LoadSeg(FileName);
    if Seg = Nil then
	RunProgramNW := Nil;
    RP := RunSegmentNW(FileName, Seg, StackSize);
    if RP = Nil then begin
	UnLoadSeg(Seg);
	RunProgramNW := Nil;
    end;
    RP^.Segment := Seg;
    RunProgramNW := RP;
end;

Procedure FinishProgram(RP : RunProgPtr);
{
    Wait for the process to finish, then deallocate everything allocated
    by the run routines.  If you started the program with RunSegmentNW
    (i.e. you already had a segment loaded), this routine will not
    UnLoadSeg your segment.  In other words, this routine will deallocate
    everything the run routines allocated, and nothing more.
}
var
    msg : MessagePtr;
begin
    msg := WaitPort(RP^.RPort);
    msg := GetMsg(RP^.RPort);
    DeletePort(RP^.RPort);
    if RP^.Segment <> Nil then
	UnLoadSeg(RP^.Segment);
    Dispose(RP^.WBMsg);
    Dispose(RP);
end;

Function RunProgram(FileName : String; StackSize : Integer) : Boolean;
{
    Run the named program as a process, and wait for that new process
    to finish before returning.  If the process ran OK, this routine
    will return TRUE.  Otherwise it's FALSE.
}
var
    RP : RunProgPtr;
begin
    RP := RunProgramNW(FileName, StackSize);
    if RP = Nil then
	RunProgram := False;
    FinishProgram(RP);
    RunProgram := True;
end;

Function RunSegment(ProcName	: String;
		    Segment	: Address;
		    StackSize	: Integer) : Boolean;
{
    If for some reason you already have a segment loaded, you can
    call this routine to run that segment as a process, then
    wait for the process to finish before returning.  If something
    goes wrong, this routine will return FALSE.  Otherwise it
    returns TRUE.
}
var
    RP : RunProgPtr;
begin
    RP := RunSegmentNW(ProcName, Segment, StackSize);
    if RP = Nil then
	RunSegment := False;
    FinishProgram(RP);
    RunSegment := True;
end;

Function ProgramFinished(RP : RunProgPtr) : Boolean;
{
    If the process indicated by RP is finished, deallocate all the
    memory these routines allocated and return TRUE.  If it's not
    finished, return FALSE.  Like FinishProgram, this routine only
    frees system resources allocated by the RunSomething routines.
}
begin
    if GetMsg(RP^.RPort) <> Nil then begin
	DeletePort(RP^.RPort);
 	if RP^.Segment <> Nil then
	    UnLoadSeg(RP^.Segment);
	Dispose(RP^.WBMsg);
	Dispose(RP);
	ProgramFinished := True;
    end else
	ProgramFinished := False;
end;
