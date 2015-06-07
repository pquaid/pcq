{

	ConfigRegs.i for PCQ Pascal

	register and bit definitions for expansion boards
}

{
** Expansion boards are actually organized such that only one nibble per
** word (16 bits) are valid information.  This table is structured
** as LOGICAL information.  This means that it never corresponds
** exactly with a physical implementation.
**
** The expansion space is logically split into two regions:
** a rom portion and a control portion.	 The rom portion is
** actually stored in one's complement form (except for the
** er_type field).
}

Type

    ExpansionRom = record
	er_Type		: Byte;
	er_Product	: Byte;
	er_Flags	: Byte;
	er_Reserved03	: Byte;
	er_Manufacturer	: Short;
	er_SerialNumber	: Integer;
	er_InitDiagVec	: Short;
	er_Reserved0c	: Byte;
	er_Reserved0d	: Byte;
	er_Reserved0e	: Byte;
	er_Reserved0f	: Byte;
    end;
    ExpansionRomPtr = ^ExpansionRom;


    ExpansionControl = record
	ec_Interrupt	: Byte;		{ interrupt control register }
	ec_Reserved11	: Byte;
	ec_BaseAddress	: Byte;		{ set new config address }
	ec_Shutup	: Byte;		{ don't respond, pass config out }
	ec_Reserved14	: Byte;
	ec_Reserved15	: Byte;
	ec_Reserved16	: Byte;
	ec_Reserved17	: Byte;
	ec_Reserved18	: Byte;
	ec_Reserved19	: Byte;
	ec_Reserved1a	: Byte;
	ec_Reserved1b	: Byte;
	ec_Reserved1c	: Byte;
	ec_Reserved1d	: Byte;
	ec_Reserved1e	: Byte;
	ec_Reserved1f	: Byte;
    end;
    ExpansionControlPtr = ^ExpansionControl;

{
** many of the constants below consist of a triplet of equivalent
** definitions: xxMASK is a bit mask of those bits that matter.
** xxBIT is the starting bit number of the field.  xxSIZE is the
** number of bits that make up the definition.	This method is
** used when the field is larger than one bit.
**
** If the field is only one bit wide then the xxB_xx and xxF_xx convention
** is used (xxB_xx is the bit number, and xxF_xx is mask of the bit).
}

Const

{ manifest constants }

    E_SLOTSIZE		= $10000;
    E_SLOTMASK		= -1;
    E_SLOTSHIFT		= 16;

{ these define the two free regions of Zorro memory space.
** THESE MAY WELL CHANGE FOR FUTURE PRODUCTS!
}

    E_EXPANSIONBASE	= $e80000;
    E_EXPANSIONSIZE	= $080000;
    E_EXPANSIONSLOTS	= 8;

    E_MEMORYBASE	= $200000;
    E_MEMORYSIZE	= $800000;
    E_MEMORYSLOTS	= 128;



{ ec_Type definitions }

{ board type -- ignore "old style" boards }

    ERT_TYPEMASK	= $c0;
    ERT_TYPEBIT		= 6;
    ERT_TYPESIZE	= 2;
    ERT_NEWBOARD	= $c0;


{ type field memory size }

    ERT_MEMMASK		= $07;
    ERT_MEMBIT		= 0;
    ERT_MEMSIZE		= 3;

{ other bits defined in type field }

    ERTB_CHAINEDCONFIG	= 3;
    ERTB_DIAGVALID	= 4;
    ERTB_MEMLIST	= 5;

    ERTF_CHAINEDCONFIG	= 8;
    ERTF_DIAGVALID	= 16;
    ERTF_MEMLIST	= 32;


{ er_Flags byte -- for those things that didn't fit into the type byte }

    ERFB_MEMSPACE	= 7;		{ wants to be in 8 meg space.	Also
					** implies that board is moveable
					}
    ERFB_NOSHUTUP	= 6;		{ board can't be shut up.  Must not
					** be a board.	Must be a box that
					** does not pass on the bus.
					}

    ERFF_MEMSPACE	= 128;
    ERFF_NOSHUTUP	= 64;


{ interrupt control register }

    ECIB_INTENA		= 1;
    ECIB_RESET		= 3;
    ECIB_INT2PEND	= 4;
    ECIB_INT6PEND	= 5;
    ECIB_INT7PEND	= 6;
    ECIB_INTERRUPTING	= 7;

    ECIF_INTENA		= 2;
    ECIF_RESET		= 8;
    ECIF_INT2PEND	= 16;
    ECIF_INT6PEND	= 32;
    ECIF_INT7PEND	= 64;
    ECIF_INTERRUPTING	= 128;


{**************************************************************************
**
** these are the specifications for the diagnostic area.  If the Diagnostic
** Address Valid bit is set in the Board Type byte (the first byte in
** expansion space) then the Diag Init vector contains a valid offset.
**
** The Diag Init vector is actually a word offset from the base of the
** board.  The resulting address points to the base of the DiagArea
** structure.  The structure may be physically implemented either four,
** eight, or sixteen bits wide.	 The code will be copied out into
** ram first before being called.
**
** The da_Size field, and both code offsets (da_DiagPoint and da_BootPoint)
** are offsets from the diag area AFTER it has been copied into ram, and
** "de-nibbleized" (if needed).	 Inotherwords, the size is the size of
** the actual information, not how much address space is required to
** store it.
**
** All bits are encoded with uninverted logic (e.g. 5 volts on the bus
** is a logic one).
**
** If your board is to make use of the boot facility then it must leave
** its config area available even after it has been configured.	 Your
** boot vector will be called AFTER your board's final address has been
** set.
**
***************************************************************************}

Type

    DiagArea = record
	da_Config	: Byte;		{ see below for definitions }
	da_Flags	: Byte;		{ see below for definitions }
	da_Size		: Short;	{ the size (in bytes) of the total diag area }
	da_DiagPoint	: Short;	{ where to start for diagnostics, or zero }
	da_BootPoint	: Short;	{ where to start for booting }
	da_Name		: Short;	{ offset in diag area where a string }
					{   identifier can be found (or zero if no }
					{   identifier is present). }

	da_Reserved01	: Short;	{ two words of reserved data.	must be zero. }
	da_Reserved02	: Short;
    end;
    DiagAreaPtr = ^DiagArea;

Const

{ da_Config definitions }

    DAC_BUSWIDTH	= $C0;	{ two bits for bus width }
    DAC_NIBBLEWIDE	= $00;
    DAC_BYTEWIDE	= $40;
    DAC_WORDWIDE	= $80;

    DAC_BOOTTIME	= $30;	{ two bits for when to boot }
    DAC_NEVER		= $00;	{ obvious }
    DAC_CONFIGTIME	= $10;	{ call da_BootPoint when first configing the }
				{   the device }
    DAC_BINDTIME	= $20;	{ run when binding drivers to boards }

{
** These are the calling conventions for Diag or Boot area
**
** A7 -- points to at least 2K of stack
** A6 -- ExecBase
** A5 -- ExpansionBase
** A3 -- your board's ConfigDev structure
** A2 -- Base of diag/init area that was copied
** A0 -- Base of your board
**
** Your board should return a value in D0.  If this value is NULL, then
** the diag/init area that was copied in will be returned to the free
** memory pool.
}

