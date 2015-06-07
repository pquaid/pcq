External;

{*
 *  Create a task with given name, priority, and stack size.
 *  It will use the default exception and trap handlers for now.
 *}


{$I "Include:Exec/Tasks.i"}
{$I "Include:Exec/Ports.i"}
{$I "Include:Exec/Memory.i"}

Function CreateTask(name : String; pri : Byte;
			initPC : Address; stackSize : Integer) : TaskPtr;
var
    NewTask : TaskPtr;
    DataSize: Integer;
begin
    DataSize := (stackSize and $fffffffc) + 1;

    {
	This should be broken into two allocations: task of PUBLIC
	and stack of PRIVATE
    }

    newTask := AllocMem(SizeOf(Task) + dataSize, MEMF_CLEAR + MEMF_PUBLIC);
    if NewTask = Nil then
	CreateTask := Nil;

    with NewTask^ do begin
	tc_SPLower := Address(Integer(newTask) + SizeOf(Task));
	tc_SPUpper := Address((Integer(tc_SPLower) + dataSize) and $fffffffe);
	tc_SPReg   := tc_SPUpper;
	with tc_Node do begin
	    ln_Type := NTTask;
	    ln_Pri := pri;
	    ln_Name := name;
	end;
    end;
    AddTask(newTask, initPC, Nil);
    CreateTask := NewTask;
end;

Procedure DeleteTask(tc : TaskPtr);
begin
    RemTask(tc);  { does not handle self deletion properly }
    FreeMem(tc, Integer(tc^.tc_SPUpper) - Integer(tc));
end;
