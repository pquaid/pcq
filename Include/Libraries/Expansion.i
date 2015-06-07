{
	Expansion.i for PCQ Pascal

	external definitions for expansion.library
}

Const
    EXPANSIONNAME	= "expansion.library";

{ flags for the AddDosNode() call }
    ADNB_STARTPROC	= 0;

    ADNF_STARTPROC	= 1;

Var
    ExpansionBase : Address;


Function AddDosNode(bootPri : Short; flags : Short;
			deviceNode : Address) : Boolean;
    External;
    { deviceNode is actually a DeviceNodePtr }

Function AllocBoardMem(slotSpec : Short) : Short;
    External;

Function AllocExpansionMem(numSlots, slotOffset : Short) : Short;
    External;

Procedure FreeBoardMem(startSlot, slotSpec : Short);
    External;

Procedure FreeExpansionMem(startSlot, numSlots : Short);
    External;

Function MakeDosNode(parameterPkt : Address) : Address; { DeviceNodePtr }
    External;

Function ReadExpansionByte(board : Address; offset : Integer) : Short;
    External;

Function ReadExpansionRom(board : Address; configDev : Address) : Boolean;
    External;

Function WriteExpansionByte(board : Address; offset : Integer;
				value : Byte) : Boolean;
    External;

