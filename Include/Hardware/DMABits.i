{
	DMABits.i for PCQ Pascal

	include file for defining dma control stuff
}

Const

{ write definitions for dmaconw }

    DMAF_SETCLR		= $8000;
    DMAF_AUDIO   	= $000F;	{ 4 bit mask }
    DMAF_AUD0    	= $0001;
    DMAF_AUD1    	= $0002;
    DMAF_AUD2    	= $0004;
    DMAF_AUD3    	= $0008;
    DMAF_DISK    	= $0010;
    DMAF_SPRITE  	= $0020;
    DMAF_BLITTER 	= $0040;
    DMAF_COPPER  	= $0080;
    DMAF_RASTER  	= $0100;
    DMAF_MASTER  	= $0200;
    DMAF_BLITHOG 	= $0400;
    DMAF_ALL     	= $01FF;	{ all dma channels }

{ read definitions for dmaconr }
{ bits 0-8 correspnd to dmaconw definitions }

    DMAF_BLTDONE 	= $4000;
    DMAF_BLTNZERO	= $2000;

    DMAB_SETCLR  	= 15;
    DMAB_AUD0    	= 0;
    DMAB_AUD1    	= 1;
    DMAB_AUD2    	= 2;
    DMAB_AUD3    	= 3;
    DMAB_DISK    	= 4;
    DMAB_SPRITE  	= 5;
    DMAB_BLITTER 	= 6;
    DMAB_COPPER  	= 7;
    DMAB_RASTER  	= 8;
    DMAB_MASTER  	= 9;
    DMAB_BLITHOG 	= 10;
    DMAB_BLTDONE 	= 14;
    DMAB_BLTNZERO	= 13;
