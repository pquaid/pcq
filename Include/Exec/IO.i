{
     IO.i for PCQ Pascal

    This file defines the constants and types required to use
    Amiga device IO routines, which are also defined here.
}

{$I "Include:Exec/Ports.i"}

type
    IORequest = record
	io_Message	: Message;
	io_Device	: Address;	    { device node pointer  }
	io_Unit		: Address;	    { unit (driver private)}
	io_Command	: Short;	    { device command }
	io_Flags	: Byte;
	io_Error	: Byte;		    { error or warning num }
    end;
    IORequestPtr = ^IORequest;

    IOStdReq = record
	io_Message	: Message;
	io_Device	: Address;	    { device node pointer  }
	io_Unit		: Address;	    { unit (driver private)}
	io_Command	: Short;	    { device command }
	io_Flags	: Byte;
	io_Error	: Byte;		    { error or warning num }
	io_Actual	: Integer;	    { actual number of bytes transferred }
	io_Length	: Integer;	    { requested number bytes transferred}
	io_Data		: Address;	    { points to data area }
	io_Offset	: Integer;	    { offset for block structured devices }
    end;
    IOStdReqPtr = ^IOStdReq;


{ library vector offsets for device reserved vectors }

const
    DEV_BEGINIO	= -30;
    DEV_ABORTIO	= -36;

{ io_Flags defined bits }

    IOB_QUICK	= 0;
    IOF_QUICK	= 1;

    CMD_INVALID	= 0;
    CMD_RESET	= 1;
    CMD_READ	= 2;
    CMD_WRITE	= 3;
    CMD_UPDATE	= 4;
    CMD_CLEAR	= 5;
    CMD_STOP	= 6;
    CMD_START	= 7;
    CMD_FLUSH	= 8;

    CMD_NONSTD	= 9;

{
    These functions are defined to accept Address's, because they
    need to handle IORequestPtrs and IOStdReqPtrs, and I wanted
    to avoid all those type conversions
}

Function AbortIO(io : Address) : Integer;
    External;

Procedure BeginIO(io : Address);
    External;

Function CheckIO(io : Address) : Address;
    External;

Function DoIO(io : Address) : Integer;
    External;

Procedure SendIO(io : Address);
    External;

Function WaitIO(io : Address) : Integer;
    External;
