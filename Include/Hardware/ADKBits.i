{
	ADKBits.i for PCQ Pascal

	bit definitions for adkcon register
}

Const

    ADKB_SETCLR		= 15;	{ standard set/clear bit }
    ADKB_PRECOMP1	= 14;	{ two bits of precompensation }
    ADKB_PRECOMP0	= 13;
    ADKB_MFMPREC	= 12;	{ use mfm style precompensation }
    ADKB_UARTBRK	= 11;	{ force uart output to zero }
    ADKB_WORDSYNC	= 10;	{ enable DSKSYNC register matching }
    ADKB_MSBSYNC	= 9;	{ (Apple GCR Only) sync on MSB for reading }
    ADKB_FAST		= 8;	{ 1 -> 2 us/bit (mfm), 2 -> 4 us/bit (gcr) }
    ADKB_USE3PN		= 7;	{ use aud chan 3 to modulate period of ?? }
    ADKB_USE2P3		= 6;	{ use aud chan 2 to modulate period of 3 }
    ADKB_USE1P2		= 5;	{ use aud chan 1 to modulate period of 2 }
    ADKB_USE0P1		= 4;	{ use aud chan 0 to modulate period of 1 }
    ADKB_USE3VN		= 3;	{ use aud chan 3 to modulate volume of ?? }
    ADKB_USE2V3		= 2;	{ use aud chan 2 to modulate volume of 3 }
    ADKB_USE1V2		= 1;	{ use aud chan 1 to modulate volume of 2 }
    ADKB_USE0V1		= 0;	{ use aud chan 0 to modulate volume of 1 }

    ADKF_SETCLR		= $8000;
    ADKF_PRECOMP1	= $4000;
    ADKF_PRECOMP0	= $2000;
    ADKF_MFMPREC	= $1000;
    ADKF_UARTBRK	= $0800;
    ADKF_WORDSYNC	= $0400;
    ADKF_MSBSYNC	= $0200;
    ADKF_FAST		= $0100;
    ADKF_USE3PN		= $0080;
    ADKF_USE2P3		= $0040;
    ADKF_USE1P2		= $0020;
    ADKF_USE0P1		= $0010;
    ADKF_USE3VN		= $0008;
    ADKF_USE2V3		= $0004;
    ADKF_USE1V2		= $0002;
    ADKF_USE0V1		= $0001;

    ADKF_PRE000NS	= 0;			{ 000 ns of precomp }
    ADKF_PRE140NS	= ADKF_PRECOMP0;	{ 140 ns of precomp }
    ADKF_PRE280NS	= ADKF_PRECOMP1;	{ 280 ns of precomp }
    ADKF_PRE560NS	= ADKF_PRECOMP0 + ADKF_PRECOMP1; { 560 ns of precomp }

