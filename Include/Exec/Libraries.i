{
    Libraries.i for PCQ Pascal

    This file defines the library structure, plus all the constants
    and routines used for libraries.
}

{$I "Include:Exec/Nodes.i"}

const
    LIB_VECTSIZE	= 6;
    LIB_RESERVED	= 4;
    LIB_BASE		= -LIB_VECTSIZE;
    LIB_USERDEF		= LIB_BASE - (LIB_RESERVED * LIB_VECTSIZE);
    LIB_NONSTD		= LIB_USERDEF;

    LIB_OPEN		= -6;
    LIB_CLOSE		= -12;
    LIB_EXPUNGE		= -18;
    LIB_EXTFUNC		= -24;

type
    Library = Record
	lib_Node	: Node;
	lib_Flags	: Byte;
	lib_Pad		: Byte;
	lib_NegSize	: Short;	{ Number of bytes before library }
	lib_PosSize	: Short;	{ Number of bytes after library }
	lib_Version	: Short;
	lib_Revision	: Short;
	lib_IDString	: String;
	lib_Sum		: Integer;	{ Library checksum }
	lib_OpenCnt	: Short;	{ Current clients }
    end;
    LibraryPtr = ^Library;

const
    LIBF_SUMMING	= 1;	{ Library is checksumming }
    LIBF_CHANGED	= 2;	{ Lib has been changed }
    LIBF_SUMUSED	= 4;	{ Should use checksum }
    LIBF_DELEXP		= 8;	{ Delayed expunge }

Procedure AddLibrary(lib : LibraryPtr);
    External;

Procedure CloseLibrary(lib : LibraryPtr);
    External;

Function MakeFunctions(target, functionarray, dispbase : Address) : Integer;
    External;

Function MakeLibrary(vec, struct, init : Address;
			dSize : Integer;
			segList : Address) : LibraryPtr;
    External;

Function OpenLibrary(libName : String; version : Integer) : LibraryPtr;
    External;

Procedure RemLibrary(library : LibraryPtr);
    External;

Function SetFunction(library : LibraryPtr;
			funcOff : Integer;
			funcEntry : Address) : Address;
    External;

Procedure SumLibrary(library : LibraryPtr);
    External;

