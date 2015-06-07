{
	Blit.i for PCQ Pascal

	include file for blitter
}

Const

    HSIZEBITS		= 6;
    VSIZEBITS		= 16 - HSIZEBITS;
    HSIZEMASK		= $3F;			{ 2^6 - 1 }
    VSIZEMASK		= $3FF;			{ 2^10 - 1 }

    MAXBYTESPERROW	= 128;

{ definitions for blitter control register 0 }

    ABC		= $80;
    ABNC   	= $40;
    ANBC   	= $20;
    ANBNC  	= $10;
    NABC   	= $08;
    NABNC  	= $04;
    NANBC  	= $02;
    NANBNC 	= $01;

{ some commonly used operations }

    A_OR_B	= ABC + ANBC + NABC + ABNC + ANBNC + NABNC;
    A_OR_C	= ABC + NABC + ABNC + ANBC + NANBC + ANBNC;
    A_XOR_C	= NABC + ABNC + NANBC + ANBNC;
    A_TO_D	= ABC + ANBC + ABNC + ANBNC;

    BC0B_DEST	= 8;
    BC0B_SRCC	= 9;
    BC0B_SRCB	= 10;
    BC0B_SRCA	= 11;
    BC0F_DEST	= $100;
    BC0F_SRCC	= $200;
    BC0F_SRCB	= $400;
    BC0F_SRCA	= $800;

    BC1F_DESC   = 2;		{ blitter descend direction }

    DEST	= $100;
    SRCC	= $200;
    SRCB	= $400;
    SRCA	= $800;

    ASHIFTSHIFT	= 12;		{ bits to right align ashift value }
    BSHIFTSHIFT	= 12;		{ bits to right align bshift value }

{ definations for blitter control register 1 }

    LINEMODE	= $01;
    FILL_OR	= $08;
    FILL_XOR	= $10;
    FILL_CARRYIN = $04;
    ONEDOT	= $02;		{ one dot per horizontal line }
    OVFLAG	= $20;
    SIGNFLAG	= $40;
    BLITREVERSE	= $02;

    SUD		= $10;
    SUL		= $08;
    AUL		= $04;

    OCTANT8	= 24;
    OCTANT7	= 4;
    OCTANT6	= 12;
    OCTANT5	= 28;
    OCTANT4	= 20;
    OCTANT3	= 8;
    OCTANT2	= 0;
    OCTANT1	= 16;

Type

{ stuff for blit qeuer }

    bltnode = record
	n	: ^bltnode;
	func	: Address;		{ Called function in C includes }
	stat	: Char;
	blitsize : Short;
	beamsync : Short;
	cleanup	: Address;
    end;
    bltnodePtr = ^bltnode;


Const

{ defined bits for bltstat }

    CLEANUP	= $40;
    CLEANME	= CLEANUP;
