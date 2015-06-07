{
    Nodes.i for PCQ Pascal

    This file defines nodes, which are used throughout the Amiga
    system software to link all sorts of things.
}

type

    NodeType = (NTUnknown, NTTask, NTInterrupt, NTDevice, NTMsgPort,
		NTMessage, NTFreeMsg, NTReplyMsg, NTResource, NTLibrary,
		NTMemory, NTSoftInt, NTFont, NTProcess, NTSemaphore);

{ A normal node }

    Node = record
	ln_Succ : ^Node;
	ln_Pred : ^Node;
	ln_Type : NodeType;
	ln_Pri  : Byte;
	ln_Name : String;
    end;
    NodePtr = ^Node;

{  A stripped node, with no type checking }

    MinNode = Record
	mln_Succ,
	mln_Pred : ^MinNode;
    end;
    MinNodePtr = ^MinNode;

