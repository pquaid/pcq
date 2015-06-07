{
	CIA.i for PCQ Pascal

	registers and bits in the Complex Interface Adapter (CIA) chip
}

{
 * ciaa is on an ODD address (e.g. the low byte) -- $bfe001
 * ciab is on an EVEN address (e.g. the high byte) -- $bfd000
 *
 * do this to get the definitions:
 *    extern struct CIA ciaa, ciab;
}

Type

    CIA = record
	ciapra		: Byte;
	pad0		: Array [0..254] of Byte;
	ciaprb		: Byte;
	pad1		: Array [0..254] of Byte;
	ciaddra		: Byte;
	pad2		: Array [0..254] of Byte;
	ciaddrb		: Byte;
	pad3		: Array [0..254] of Byte;
	ciatalo		: Byte;
	pad4		: Array [0..254] of Byte;
	ciatahi		: Byte;
	pad5		: Array [0..254] of Byte;
	ciatblo		: Byte;
	pad6		: Array [0..254] of Byte;
	ciatbhi		: Byte;
	pad7		: Array [0..254] of Byte;
	ciatodlow	: Byte;
	pad8		: Array [0..254] of Byte;
	ciatodmid	: Byte;
	pad9		: Array [0..254] of Byte;
	ciatodhi	: Byte;
	pad10		: Array [0..254] of Byte;
	unusedreg	: Byte;
	pad11		: Array [0..254] of Byte;
	ciasdr		: Byte;
	pad12		: Array [0..254] of Byte;
	ciaicr		: Byte;
	pad13		: Array [0..254] of Byte;
	ciacra		: Byte;
	pad14		: Array [0..254] of Byte;
	ciacrb		: Byte;
    end;
    CIAPtr = ^CIA;


Const

{ interrupt control register bit numbers }

    CIAICRB_TA		= 0;
    CIAICRB_TB		= 1;
    CIAICRB_ALRM	= 2;
    CIAICRB_SP		= 3;
    CIAICRB_FLG		= 4;
    CIAICRB_IR		= 7;
    CIAICRB_SETCLR	= 7;

{ control register A bit numbers }

    CIACRAB_START	= 0;
    CIACRAB_PBON	= 1;
    CIACRAB_OUTMODE 	= 2;
    CIACRAB_RUNMODE 	= 3;
    CIACRAB_LOAD	= 4;
    CIACRAB_INMODE	= 5;
    CIACRAB_SPMODE	= 6;
    CIACRAB_TODIN	= 7;

{ control register B bit numbers }

    CIACRBB_START	= 0;
    CIACRBB_PBON	= 1;
    CIACRBB_OUTMODE 	= 2;
    CIACRBB_RUNMODE 	= 3;
    CIACRBB_LOAD	= 4;
    CIACRBB_INMODE0 	= 5;
    CIACRBB_INMODE1 	= 6;
    CIACRBB_ALARM	= 7;
 
{ interrupt control register masks }

    CIAICRF_TA		= $01;
    CIAICRF_TB		= $02;
    CIAICRF_ALRM	= $04;
    CIAICRF_SP		= $08;
    CIAICRF_FLG		= $10;
    CIAICRF_IR		= $80;
    CIAICRF_SETCLR	= $80;

{ control register A register masks }

    CIACRAF_START	= $01;
    CIACRAF_PBON	= $02;
    CIACRAF_OUTMODE	= $04;
    CIACRAF_RUNMODE	= $08;
    CIACRAF_LOAD	= $10;
    CIACRAF_INMODE	= $20;
    CIACRAF_SPMODE	= $40;
    CIACRAF_TODIN	= $80;
 
{ control register B register masks }

    CIACRBF_START	= $01;
    CIACRBF_PBON	= $02;
    CIACRBF_OUTMODE	= $04;
    CIACRBF_RUNMODE	= $08;
    CIACRBF_LOAD	= $10;
    CIACRBF_INMODE0	= $20;
    CIACRBF_INMODE1	= $40;
    CIACRBF_ALARM	= $80;

{ control register B INMODE masks }

    CIACRBF_IN_PHI2	= 0;
    CIACRBF_IN_CNT	= CIACRBF_INMODE0;
    CIACRBF_IN_TA	= CIACRBF_INMODE1;
    CIACRBF_IN_CNT_TA	= CIACRBF_INMODE0 + CIACRBF_INMODE1;

{
 * Port definitions -- what each bit in a cia peripheral register is tied to
 }

{ ciaa port A (0xbfe001) }

    CIAB_GAMEPORT1	= 7;	{ gameport 1, pin 6 (fire button*) }
    CIAB_GAMEPORT0	= 6;	{ gameport 0, pin 6 (fire button*) }
    CIAB_DSKRDY		= 5;	{ disk ready* }
    CIAB_DSKTRACK0	= 4;	{ disk on track 00* }
    CIAB_DSKPROT	= 3;	{ disk write protect* }
    CIAB_DSKCHANGE	= 2;	{ disk change* }
    CIAB_LED		= 1;	{ led light control (0==>bright) }
    CIAB_OVERLAY	= 0;	{ memory overlay bit }

{ ciaa port B (0xbfe101) -- parallel port }

{ ciab port A (0xbfd000) -- serial and printer control }

    CIAB_COMDTR		= 7;	{ serial Data Terminal Ready* }
    CIAB_COMRTS		= 6;	{ serial Request to Send* }
    CIAB_COMCD		= 5;	{ serial Carrier Detect* }
    CIAB_COMCTS		= 4;	{ serial Clear to Send* }
    CIAB_COMDSR		= 3;	{ serial Data Set Ready* }
    CIAB_PRTRSEL	= 2;	{ printer SELECT }
    CIAB_PRTRPOUT	= 1;	{ printer paper out }
    CIAB_PRTRBUSY	= 0;	{ printer busy }

{ ciab port B (0xbfd100) -- disk control }

    CIAB_DSKMOTOR	= 7;	{ disk motorr* }
    CIAB_DSKSEL3	= 6;	{ disk select unit 3* }
    CIAB_DSKSEL2	= 5;	{ disk select unit 2* }
    CIAB_DSKSEL1	= 4;	{ disk select unit 1* }
    CIAB_DSKSEL0	= 3;	{ disk select unit 0* }
    CIAB_DSKSIDE	= 2;	{ disk side select* }
    CIAB_DSKDIREC	= 1;	{ disk direction of seek* }
    CIAB_DSKSTEP	= 0;	{ disk step heads* }

{ ciaa port A (0xbfe001) }

    CIAF_GAMEPORT1	= 128;
    CIAF_GAMEPORT0	= 64;
    CIAF_DSKRDY		= 32;
    CIAF_DSKTRACK0	= 16;
    CIAF_DSKPROT	= 8;
    CIAF_DSKCHANGE	= 4;
    CIAF_LED		= 2;
    CIAF_OVERLAY	= 1;

{ ciaa port B (0xbfe101) -- parallel port }

{ ciab port A (0xbfd000) -- serial and printer control }

    CIAF_COMDTR		= 128;
    CIAF_COMRTS		= 64;
    CIAF_COMCD		= 32;
    CIAF_COMCTS		= 16;
    CIAF_COMDSR		= 8;
    CIAF_PRTRSEL	= 4;
    CIAF_PRTRPOUT	= 2;
    CIAF_PRTRBUSY	= 1;

{ ciab port B (0xbfd100) -- disk control }

    CIAF_DSKMOTOR	= 128;
    CIAF_DSKSEL3	= 64;
    CIAF_DSKSEL2	= 32;
    CIAF_DSKSEL1	= 16;
    CIAF_DSKSEL0	= 8;
    CIAF_DSKSIDE	= 4;
    CIAF_DSKDIREC	= 2;
    CIAF_DSKSTEP	= 1;
