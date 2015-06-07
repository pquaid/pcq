
{
	TaskUtils.i

	Declares the Task support routines CreateTask and DeleteTask.
	The source for these routines is under Runtime/Extras.
}

{$I "Include:Exec/Tasks.i"}

Function CreateTask(name : String; pri : Byte;
			initPC : Address; stackSize : Integer) : TaskPtr;
    External;

Procedure DeleteTask(tc : TaskPtr);
    External;
