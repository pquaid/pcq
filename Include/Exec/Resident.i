{
    Resident.i for PCQ Pascal
}

{$I "Include:Exec/Nodes.i"}

type
    Resident = record
	rt_MatchWord	: Short;	{ word to match on (ILLEGAL)	}
	rt_MatchTag	: ^Resident;	{ pointer to the above		}
	rt_EndSkip	: Address;	{ address to continue scan	}
	rt_Flags	: Byte;		{ various tag flags		}
	rt_Version	: Byte;		{ release version number	}
	rt_Type		: Byte;		{ type of module (NT_mumble)	}
	rt_Pri		: Byte;		{ initialization priority	}
	rt_Name		: String;	{ pointer to node name		}
	rt_IdString	: String;	{ pointer to ident string	}
	rt_Init		: Address;	{ pointer to init code		}
    end;
    ResidentPtr = ^Resident;

const
    RTC_MATCHWORD	= $4AFC;

    RTF_AUTOINIT	= 128;
    RTF_COLDSTART	= 1;

{ Compatibility: }

    RTM_WHEN		= 3;
    RTW_NEVER		= 0;
    RTW_COLDSTART	= 1;


Function FindResident(name : String) : ResidentPtr;
    External;

Procedure InitCode(startClass, version : Integer);
    External;

Procedure InitResident(resident : ResidentPtr; segList : Address);
    External;

Procedure SumKickData;
    External;

