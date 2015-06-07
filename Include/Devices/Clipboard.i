{
	Clipboard.i for PCQ Pascal

	clipboard device command definitions 
}

{$I "Include:Exec/Nodes.i"}
{$I "Include:Exec/Lists.i"}
{$I "Include:Exec/Ports.i"}

const
    CBD_POST		= CMD_NONSTD + 0;
    CBD_CURRENTREADID	= CMD_NONSTD + 1;
    CBD_CURRENTWRITEID	= CMD_NONSTD + 2;

    CBERR_OBSOLETEID	= 1;

type

    ClipboardUnitPartial = record
	cu_Node		: Node;		{ list of units }
	cu_UnitNum	: Integer;	{ unit number for this unit }
    { the remaining unit data is private to the device }
    end;
    ClipboardUnitPartialPtr = ^ClipboardUnitPartial;


    IOClipReq = record
	io_Message	: Message;
	io_Device	: Address;	{ device node pointer	}
	io_Unit		: Address;	{ unit (driver private)	}
	io_Command	: Short;	{ device command	}
	io_Flags	: Byte;		{ including QUICK and SATISFY }
	io_Error	: Byte;		{ error or warning num	}
	io_Actual	: Integer;	{ number of bytes transferred }
	io_Length	: Integer;	{ number of bytes requested }
	io_Data		: Address;	{ either clip stream or post port }
	io_Offset	: Integer;	{ offset in clip stream	}
	io_ClipID	: Integer;	{ ordinal clip identifier }
    end;
    IOClipReqPtr = ^IOClipReq;

const
    PRIMARY_CLIP	= 0;	{ primary clip unit }

type

    SatisfyMsg = record
	sm_Msg	: Message;	{ the length will be 6 }
	sm_Unit	: Short;	{ which clip unit this is }
	sm_ClipID : Integer;	{ the clip identifier of the post }
    end;
    SatisfyMsgPtr = ^SatisfyMsg;

