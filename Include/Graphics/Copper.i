{
    Copper.i for PCQ Pascal

    This file defines the types, constants and routines necessary for
    using Copper lists.  Note that the C macros CEND, CINIT, etc. were
    renamed _CEND, _CINIT, _CMOVE, and _CWAIT to avoid name conflicts
    with the actual graphics routines.  Also note that you'll have to
    open GfxBase before you can use any of these routines.
}

const

    COPPER_MOVE	= 0;	{ pseude opcode for move #XXXX,dir }
    COPPER_WAIT	= 1;	{ pseudo opcode for wait y,x }
    CPRNXTBUF	= 2;	{ continue processing with next buffer }
    CPR_NT_LOF	= $8000; { copper instruction only for short frames }
    CPR_NT_SHT	= $4000; { copper instruction only for long frames }

type

{ Note: The combination VWaitAddr and HWaitAddr replace a three way
 	union in C.  The three possibilities are:

	nxtList : CopListPtr;  or

	VWaitPos : Short;
	HWaitPos : Short;  or

	DestAddr : Short;
	DestData : Short;
}

    CopIns = record
	OpCode	: Short; { 0 = move, 1 = wait }
	VWaitAddr : Short; { vertical or horizontal wait position }
	HWaitData : Short; { destination address or data to send }
    end;
    CopInsPtr = ^CopIns;

{ structure of cprlist that points to list that hardware actually executes }

    cprlist = Record
	Next	: ^cprlist;
	start	: ^Short;	{ start of copper list }
	MaxCount : Short;	{ number of long instructions }
    end;
    cprlistptr = ^cprlist;

    CopList = record
	Next	: ^CopList;	{ next block for this copper list }
	_CopList : ^CopList;	{ system use }
	_ViewPort : Address;	{ system use }
	CopIns	: CopInsPtr;	{ start of this block }
	CopPtr	: CopInsPtr;	{ intermediate ptr }
	CopLStart : ^Short;	{ mrgcop fills this in for Long Frame}
	CopSStart : ^Short;	{ mrgcop fills this in for Short Frame}
	Count	: Short;	{ intermediate counter }
	MaxCount : Short;	{ max # of copins for this block }
	DyOffset : Short;	{ offset this copper list vertical waits }
    end;
    CopListPtr = ^CopList;


    UCopList = Record
	Next	: ^UCopList;
	FirstCopList : CopListPtr;	{ head node of this copper list }
	CopList	: CopListPtr;		{ node in use }
    end;
    UCopListPtr = ^UCopList;


    copinit = record
	diagstrt : Array [0..3] of Short; { copper list for first bitplane }
	sprstrtup : Array [0..(2*8*2)+2+(2*2)+1] of Short;
	sprstop	: Array [0..1] of Short;
    end;
    copinitptr = ^copinit;

Procedure CBump(c : UCopListPtr);
    External;

Procedure CMove(c : UCopListPtr; a : Address; v : Short);
    External;

Procedure CWait(c : UCopListPtr; v, h : Short);
    External;

Procedure FreeCopList(coplist : CopListPtr);
    External;

Procedure FreeCprList(cpr : cprlistptr);
    External;

Function UCopperListInit(UCopList : UCopListPtr; n : Short) : UCopListPtr;
    External;

Procedure _CEND(c : UCopListPtr);
    External;

Function _CINIT(UCopList : UCopListPtr; n : Short) : UCopListPtr;
    External;

Procedure _CMOVE();
    External;

Procedure _CWAIT(UCopList : UCopListPtr; v, h : Short);
    External;

