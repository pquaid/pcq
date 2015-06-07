{
    RunProgram.i

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

    The simplest way to use these routines is by calling RunProgram.
    The call looks something like:

	if RunProgram("path/filename", 4000) then
	    writeln('program ran OK')
	else
	    writeln('problem running program');

    Remember that not all programs can be run with these routines.  PCQ
    programs probably can, but I wouldn't be surprised if there were
    cases that had problems.

    The source code for these routines is in Runtime/Extras
}

{  This address is returned by the "No Wait" functions.  It points to
   a record that keeps track of all the memory and other resources
   allocated by the program, and is the key to these routines.  }

type
    RunProgPtr = Address;




Function RunSegmentNW(ProcName : String;
		      Segment : Address;
		      StackSize : Integer) : RunProgPtr;
    External;
{
    If you already have a segment loaded, run the segment as a process
    and return immediately.  If something went wrong, this routine
    will return Nil.  Otherwise, the new process is already running by
    the time this routine returns.
}




Function RunProgramNW(FileName : String; StackSize : Integer) : RunProgPtr;
    External;
{
    Load a file, then run it as a process.  Return without waiting for
    this new program to complete.  If something goes wrong, this routine
    will return Nil.  Otherwise, the program is running.
}



Procedure FinishProgram(RP : RunProgPtr);
    External;
{
    Wait for the process to finish, then deallocate everything allocated
    by the run routines.  If you started the program with RunSegmentNW
    (i.e. you already had a segment loaded), this routine will not
    UnLoadSeg your segment.  In other words, this routine will deallocate
    everything the run routines allocated, and nothing more.
}



Function RunProgram(FileName : String; StackSize : Integer) : Boolean;
    External;
{
    Run the named program as a process, and wait for that new process
    to finish before returning.  If the process ran OK, this routine
    will return TRUE.  Otherwise it's FALSE.
}



Function RunSegment(ProcName	: String;
		    Segment	: Address;
		    StackSize	: Integer) : Boolean;
    External;
{
    If for some reason you already have a segment loaded, you can
    call this routine to run that segment as a process, then
    wait for the process to finish before returning.  If something
    goes wrong, this routine will return FALSE.  Otherwise it
    returns TRUE.
}




Function ProgramFinished(RP : RunProgPtr) : Boolean;
    External;
{
    If the process indicated by RP is finished, deallocate all the
    memory these routines allocated and return TRUE.  If it's not
    finished, return FALSE.  Like FinishProgram, this routine only
    frees system resources allocated by the RunSomething routines.
}
