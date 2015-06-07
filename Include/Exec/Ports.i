{
    Ports.i for PCQ Pascal

    This file defines ports and messages, which are used for inter-
    task communications using the routines defined toward the
    bottom of this file.
}

{$I "Include:Exec/Nodes.i"}
{$I "Include:Exec/Lists.i"}

type

    PortType = (PASignal, PASoftInt, PAIgnore, PFAction);

{****** MsgPort *****************************************************}

    MsgPort = record
	mp_Node		: Node;
	mp_Flags	: PortType;
	mp_SigBit	: Byte;		{ signal bit number    }
	mp_SigTask	: Address;	{ task to be signalled (TaskPtr) }
	mp_MsgList	: List;		{ message linked list  }
    end;
    MsgPortPtr = ^MsgPort;

{****** Message *****************************************************}

    Message = record
	mn_Node		: Node; 
	mn_ReplyPort	: MsgPortPtr;	{ message reply port }
	mn_Length	: Short;	{ message len in bytes }
    end;
    MessagePtr = ^Message;

Procedure AddPort(port : MsgPortPtr);
    External;

Function FindPort(name : String): MsgPortPtr;
    External;

Function GetMsg(port : MsgPortPtr): MessagePtr;
    External;

Procedure PutMsg(port : MsgPortPtr; mess : MessagePtr);
    External;

Procedure RemPort(port : MsgPortPtr);
    External;

Procedure ReplyMsg(mess : MessagePtr);
    External;

Function WaitPort(port : MsgPortPtr): MessagePtr;
    External;
