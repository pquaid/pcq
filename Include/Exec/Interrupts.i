{
    Interrupts.i for PCQ Pascal
}

{$I "Include:Exec/Nodes.i"}
{$I "Include:Exec/Lists.i"}

type
    Interrupt = record
	is_Node	: Node;
	is_Data : Address;	{ Server data segment }
	is_Code	: Address;	{ Server code entry }
    end;
    InterruptPtr = ^Interrupt;

    IntVector = record		{ For EXEC use ONLY! }
	iv_Data	: Address;
	iv_Code	: Address;
	iv_Node	: NodePtr;
    end;
    IntVectorPtr = ^IntVector;

    SoftIntList = record	{ For EXEC use ONLY! }
	sh_List	: List;
	sh_Pad	: Short;
    end;
    SoftIntListPtr = ^SoftIntList;

const
    SIH_PRIMASK	= $F0;

{ this is a fake INT definition, used only for AddIntServer and the like }

    INTB_NMI	= 15;
    INTF_NMI	= $0080;

Procedure AddIntServer(intNum : Integer; Int : InterruptPtr);
    external;

Procedure Cause(Int : InterruptPtr);
    external;

Procedure Disable;
    External;

Procedure Enable;
    External;

Procedure Forbid;
    external;

Procedure Permit;
    external;

Procedure RemIntServer(intNum : Integer; Int : InterruptPtr);
    external;

Function SetIntVector(intNum : Integer; Int : InterruptPtr) : InterruptPtr;
    external;

Function SuperState() : Address;
    external;

Procedure UserState(s : Address);
    external;
