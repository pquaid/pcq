{
    Tasks.i for PCQ Pascal

    Every Amiga Task has one of these Task structures associated with it.
    To find yours, use FindTask(Nil).  AmigaDOS processes tack a few more
    values on to the end of this structure, which is the difference between
    Tasks and Processes.
}

{$I "Include:exec/nodes.i"}
{$I "Include:exec/lists.i"}

type
  
    Task = record
	tc_Node		: Node;
	tc_Flags	: Byte;
	tc_State	: Byte;
	tc_IDNestCnt	: Byte;		{ intr disabled nesting		}
	tc_TDNestCnt	: Byte;		{ task disabled nesting		}
	tc_SigAlloc	: Integer;	{ sigs allocated		}
	tc_SigWait	: Integer;	{ sigs we are waiting for	}
	tc_SigRecvd	: Integer;	{ sigs we have received		}
	tc_SigExcept	: Integer;	{ sigs we will take excepts for	}
	tc_TrapAlloc	: Short;	{ traps allocated		}
	tc_TrapAble	: Short;	{ traps enabled			}
	tc_ExceptData	: Address;	{ points to except data		}
	tc_ExceptCode	: Address;	{ points to except code		}
	tc_TrapData	: Address;	{ points to trap data		}
	tc_TrapCode	: Address;	{ points to trap code		}
	tc_SPReg	: Address;	{ stack pointer			}
	tc_SPLower	: Address;	{ stack lower bound		}
	tc_SPUpper	: Address;	{ stack upper bound + 2		}
	tc_Switch	: Address;	{ task losing CPU		}
	tc_Launch	: Address;	{ task getting CPU		}
	tc_MemEntry	: List;		{ allocated memory 		}
	tc_UserData	: Address;	{ per task data			}
    end;
    TaskPtr = ^Task;

{----- Flag Bits ------------------------------------------}

const
    TB_PROCTIME		= 0;
    TB_STACKCHK		= 4;
    TB_EXCEPT		= 5;
    TB_SWITCH		= 6;
    TB_LAUNCH		= 7;

    TF_PROCTIME		= 1;
    TF_STACKCHK		= 16;
    TF_EXCEPT		= 32;
    TF_SWITCH		= 64;
    TF_LAUNCH		= 128;

{----- Task States ----------------------------------------}

    TS_INVALID		= 0;
    TS_ADDED		= 1;
    TS_RUN		= 2;
    TS_READY		= 3;
    TS_WAIT		= 4;
    TS_EXCEPT		= 5;
    TS_REMOVED		= 6;

{----- Predefined Signals -------------------------------------}

    SIGB_ABORT		= 0;
    SIGB_CHILD		= 1;
    SIGB_BLIT		= 4;
    SIGB_SINGLE		= 4;
    SIGB_DOS		= 8;

    SIGF_ABORT		= 1;
    SIGF_CHILD		= 2;
    SIGF_BLIT		= 16;
    SIGF_SINGLE		= 16;
    SIGF_DOS		= 256;



Procedure AddTask(task : TaskPtr; initialPC, finalPC : Address);
    External;

Function AllocSignal(signalNum : Integer) : Integer;
    External;

Function AllocTrap(trapNum : Integer) : Integer;
    External;

Function FindTask(name : String) : TaskPtr;
    External;

Procedure FreeSignal(signalNum : Integer);
    External;

Procedure FreeTrap(signalNum : Integer);
    External;

Procedure RemTask(task : TaskPtr);
    External;

Function SetExcept(newSignals, signalMask : Integer) : Integer;
    External;

Function SetSignal(newSignals, signalMask : Integer) : Integer;
    External;

Function SetTaskPri(task : TaskPtr; priority : Integer) : Integer;
    External;

Procedure Signal(task : TaskPtr; signals : Integer);
    External;

Function Wait(signals : Integer) : Integer;
    External;

