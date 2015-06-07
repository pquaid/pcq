{
	IOUtils.i

	This file has the NewList, CreatePort, DeletePort, CreateStdIO,
and DeleteStdIO.  You never know when you'll need them....  Note that
the Create functions do _not_ use PCQ's memory routines, and thus if
you fail to Delete them, the memory will be lost to the system.
	The object code for these routines is in PCQ.lib, and the
source is in Runtime/Extras.
}

{$I "Include:Exec/Ports.i"}
{$I "Include:Exec/IO.i"}

Function CreatePort(Name : String; pri : Integer) : MsgPortPtr;
    External;

Procedure DeletePort(port : MsgPortPtr);
    External;

Function CreateStdIO(ioReplyPort : MsgPortPtr) : IOStdReqPtr;
    External;

Procedure DeleteStdIO(Request : IOStdReqPtr);
    External;
