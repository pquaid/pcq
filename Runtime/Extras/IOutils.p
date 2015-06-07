External;

{
	IOUtils.p

	This file has the NewList, CreatePort, DeletePort, CreateStdIO,
and DeleteStdIO.  You never know when you'll need them....  Note that
the Create functions do _not_ use PCQ's memory routines, and thus if
you fail to Delete them, the memory will be lost to the system.
}

{$I "Include:Exec/Ports.i"}
{$I "Include:Exec/Tasks.i"}
{$I "Include:Exec/IO.i"}
{$I "Include:Exec/Memory.i"}

Function CreatePort(Name : String; pri : Integer) : MsgPortPtr;
var
    sigBit : Byte;
    port   : MsgPortPtr;
begin
    sigBit := AllocSignal(-1);
    if sigBit = -1 then
	CreatePort := nil;
    port := AllocMem(SizeOf(MsgPort), MEMF_CLEAR + MEMF_PUBLIC);
    if port = nil then begin
	FreeSignal(sigBit);
	CreatePort := nil;
    end;
    with Port^ do begin
	mp_Node.ln_Name := Name;
	mp_Node.ln_Pri := pri;
	mp_Node.ln_Type := NTMsgPort;

	mp_Flags := PASignal;
	mp_SigBit := sigBit;
	mp_SigTask := FindTask(nil);
    end;
    if name <> nil then
	AddPort(port)
    else
	NewList(Adr(Port^.mp_MsgList));
    CreatePort := port;
end;

Procedure DeletePort(port : MsgPortPtr);
begin
    if port^.mp_Node.ln_Name <> nil then
	RemPort(port);
    port^.mp_Node.ln_Type := NodeType($FF);
    port^.mp_MsgList.lh_Head := NodePtr(-1);
    FreeSignal(Port^.mp_SigBit);
    FreeMem(port, SizeOf(MsgPort));
end;

Function CreateStdIO(ioReplyPort : MsgPortPtr) : IOStdReqPtr;
var
    Request : IOStdReqPtr;
begin
    if ioReplyPort = Nil then
	CreateStdIO := Nil;

    Request := AllocMem(SizeOf(IOStdReq), MEMF_CLEAR + MEMF_PUBLIC);
    if Request = Nil then
	CreateStdIO := Nil;

    with Request^.io_Message.mn_Node do begin
	ln_Type := NTMessage;
	ln_Pri := 0;
    end;
    Request^.io_Message.mn_ReplyPort := ioReplyPort;
    CreateStdIO := Request;
end;

Procedure DeleteStdIO(Request : IOStdReqPtr);
begin
    Request^.io_Message.mn_Node.ln_Type := NodeType($FF);
    Request^.io_Device := Address(-1);
    Request^.io_Unit := Address(-1);
    FreeMem(Request, SizeOf(IOStdReq));
end;
