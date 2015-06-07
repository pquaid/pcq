{
    Lists.i for PCQ Pascal

    This file defines Exec system lists, which are used to link
    various things.  Exec provides several routines to handle list
    processing (defined at the bottom of this file), so you can
    use these routines to save yourself the trouble of writing a list
    package.
}

{$I "Include:Exec/Nodes.i"}

Type

{ normal, full featured list }

    List = record
	lh_Head		: NodePtr;
	lh_Tail		: NodePtr;
	lh_TailPred	: NodePtr;
	lh_Type		: Byte;
	l_pad		: Byte;
    end;
    ListPtr = ^List;

{ minimum list -- no type checking possible }

    MinList = record
	mlh_Head	: MinNodePtr;
	mlh_Tail	: MinNodePtr;
	mlh_TailPred	: MinNodePtr;
    end;
    MinListPtr = ^MinList;


Procedure AddHead(list : ListPtr; node : NodePtr);
    External;

Procedure AddTail(list : ListPtr; node : NodePtr);
    External;

Procedure Enqueue(list : ListPtr; node : NodePtr);
    External;

Function FindName(start : ListPtr; name : String) : NodePtr;
    External;

Procedure Insert(list : ListPtr; node, listNode : NodePtr);
    External;

Procedure NewList(list : ListPtr);
    External;

Function RemHead(list : ListPtr) : NodePtr;
    External;

Procedure Remove(node : NodePtr);
    External;

Function RemTail(list : ListPtr) : NodePtr;
    External;

