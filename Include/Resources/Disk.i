{
	Disk.i for PCQ Pascal

	external declarations for disc resources
}

{$I "Include:Exec/Lists.i"}
{$I "Include:Exec/Ports.i"}
{$I "Include:Exec/Interrupts.i"}
{$I "Include:Exec/Libraries.i"}


{********************************************************************
*
* Resource structures
*
********************************************************************}

Type

    DiscResourceUnit = record
	dru_Message	: Message;
	dru_DiscBlock	: Interrupt;
	dru_DiscSync	: Interrupt;
	dru_Index	: Interrupt;
    end;
    DiscResourceUnitPtr = ^DiscResourceUnit;

    DiscResource = record
	dr_Library	: Library;
	dr_Current	: DiscResourceUnitPtr;
	dr_Flags	: Byte;
	dr_pad		: Byte;
	dr_SysLib	: LibraryPtr;
	dr_CiaResource	: LibraryPtr;
	dr_UnitID	: Array [0..3] of Integer;
	dr_Waiting	: List;
	dr_DiscBlock	: Interrupt;
	dr_DiscSync	: Interrupt;
	dr_Index	: Interrupt;
    end;
    DiscResourcePtr = ^DiscResource;

Const

{ dr_Flags entries }

    DRB_ALLOC0		= 0;	{ unit zero is allocated }
    DRB_ALLOC1		= 1;	{ unit one is allocated }
    DRB_ALLOC2		= 2;	{ unit two is allocated }
    DRB_ALLOC3		= 3;	{ unit three is allocated }
    DRB_ACTIVE		= 7;	{ is the disc currently busy? }

    DRF_ALLOC0		= 1;	{ unit zero is allocated }
    DRF_ALLOC1		= 2;	{ unit one is allocated }
    DRF_ALLOC2		= 4;	{ unit two is allocated }
    DRF_ALLOC3		= 8;	{ unit three is allocated }
    DRF_ACTIVE		= 128;	{ is the disc currently busy? }



{*******************************************************************
*
* Hardware Magic
*
*******************************************************************}


    DSKDMAOFF		= $4000;	{ idle command for dsklen register }


{*******************************************************************
*
* Resource specific commands
*
*******************************************************************}

{
 * DISKNAME is a generic macro to get the name of the resource.
 * This way if the name is ever changed you will pick up the
 *  change automatically.
 }

    DISKNAME		= "disk.resource";


    DR_ALLOCUNIT	= LIB_BASE - 0 * LIB_VECTSIZE;
    DR_FREEUNIT		= LIB_BASE - 1 * LIB_VECTSIZE;
    DR_GETUNIT		= LIB_BASE - 2 * LIB_VECTSIZE;
    DR_GIVEUNIT		= LIB_BASE - 3 * LIB_VECTSIZE;
    DR_GETUNITID	= LIB_BASE - 4 * LIB_VECTSIZE;


    DR_LASTCOMM		= DR_GIVEUNIT;

{*******************************************************************
*
* drive types
*
*******************************************************************}

    DRT_AMIGA		= $00000000;
    DRT_37422D2S	= $55555555;
    DRT_EMPTY		= $FFFFFFFF;
