{
    Memory.i for PCQ Pascal
}

{$I "Include:Exec/Nodes.i"}

type

{***** MemChunk ***************************************************}

    MemChunk = record
	mc_Next	: ^MemChunk;	{ pointer to next chunk }
	mc_Bytes : Integer;	{ chunk byte size	}
    end;
    MemChunkPtr = ^MemChunk;

{***** MemHeader **************************************************}

    MemHeader  = record
	mh_Node		: Node;
	mh_Attributes	: Short;	{ characteristics of this region }
	mh_First	: MemChunkPtr;	{ first free region		}
	mh_Lower	: Address;	{ lower memory bound		}
	mh_Upper	: Address;	{ upper memory bound+1		}
	mh_Free		: Integer;	{ total number of free bytes	}
    end;
    MemHeaderPtr = ^MemHeader;

{***** MemEntry ***************************************************}

    MemEntry = record
	meu_ReqsAddr	: Integer;	{ the AllocMem requirements or addr }
	me_Length	: Integer;	{ the length of this memory region }
    end;
    MemEntryPtr = ^MemEntry;

{***** MemList ****************************************************}

    MemList = record
	ml_Node		: Node;
	ml_NumEntries	: Short;	{ number of entries in this struct }
	ml_ME		: Array [0..0] of MemEntry; { the first entry	}
    end;
    MemListPtr = ^MemList;

{----- Memory Requirement Types ---------------------------}

const
    MEMF_PUBLIC		= 1;
    MEMF_CHIP		= 2;
    MEMF_FAST		= 4;

    MEMF_CLEAR		= $10000;
    MEMF_LARGEST	= $20000;

    MEM_BLOCKSIZE	= 8;
    MEM_BLOCKMASK	= 7;


Procedure AddMemList(size, attr, pri : Integer; base : Address; name : String);
    External;

Function AllocAbs(bytesize : Integer; location : Address) : Address;
    External;

Function Allocate(mem : MemHeaderPtr; bytesize : Integer) : Address;
    External;

Function AllocEntry(mem : MemListPtr) : MemListPtr;
    External;

Function AllocMem(bytesize : Integer; reqs : Integer) : Address;
    External;

Function AvailMem(attr : Integer) : Integer;
    External;

Procedure CopyMem(source, dest : Address; size : Integer);
    External;

Procedure CopyMemQuick(source, dest : Address; size : Integer);
    External;

Procedure Deallocate(header : MemHeaderPtr; block : Address; size : Integer);
    External;

Procedure FreeEntry(memList : MemListPtr);
    External;

Procedure FreeMem(memBlock : Address; size : Integer);
    External;

Procedure InitStruct(table, memory : Address; size : Integer);
    External;

Function TypeOfMem(mem : Address) : Integer;
    External;

