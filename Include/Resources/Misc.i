{
	Misc.i for PCQ Pascal

	external declarations for misc system resources
}

{$I "Include:Exec/Libraries.i"}


{*******************************************************************
*
* Resource structures
*
*******************************************************************}

Const

    MR_SERIALPORT	= 0;
    MR_SERIALBITS	= 1;
    MR_PARALLELPORT	= 2;
    MR_PARALLELBITS	= 3;

    NUMMRTYPES		= 4;

Type

    MiscResource = record
	mr_Library	: Library;
	mr_AllocArray	: Array [0..NUMMRTYPES-1] of Integer;
    end;
    MiscResourcePtr = ^MiscResource;

Const

    MR_ALLOCMISCRESOURCE	= LIB_BASE;
    MR_FREEMISCRESOURCE		= LIB_BASE + LIB_VECTSIZE;


    MISCNAME		= "misc.resource";
