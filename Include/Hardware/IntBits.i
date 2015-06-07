{
	IntBits.i for PCQ Pascal

	bits in the interrupt enable (and interrupt request) register
}

Const

    INTB_SETCLR		= 15;	{ Set/Clear control bit. Determines if bits }
				{ written with a 1 get set or cleared. Bits }
				{ written with a zero are allways unchanged }
    INTB_INTEN		= 14;	{ Master interrupt (enable only ) }
    INTB_EXTER		= 13;	{ External interrupt }
    INTB_DSKSYNC	= 12;	{ Disk re-SYNChronized }
    INTB_RBF		= 11;	{ serial port Receive Buffer Full }
    INTB_AUD3		= 10;	{ Audio channel 3 block finished }
    INTB_AUD2		= 9;	{ Audio channel 2 block finished }
    INTB_AUD1		= 8;	{ Audio channel 1 block finished }
    INTB_AUD0		= 7;	{ Audio channel 0 block finished }
    INTB_BLIT		= 6;	{ Blitter finished }
    INTB_VERTB		= 5;	{ start of Vertical Blank }
    INTB_COPER		= 4;	{ Coprocessor }
    INTB_PORTS		= 3;	{ I/O Ports and timers }
    INTB_SOFTINT	= 2;	{ software interrupt request }
    INTB_DSKBLK		= 1;	{ Disk Block done }
    INTB_TBE		= 0;	{ serial port Transmit Buffer Empty }


    INTF_SETCLR		= $8000;
    INTF_INTEN		= $4000;
    INTF_EXTER		= $2000;
    INTF_DSKSYNC	= $1000;
    INTF_RBF		= $0800;
    INTF_AUD3		= $0400;
    INTF_AUD2		= $0200;
    INTF_AUD1		= $0100;
    INTF_AUD0		= $0080;
    INTF_BLIT		= $0040;
    INTF_VERTB		= $0020;
    INTF_COPER		= $0010;
    INTF_PORTS		= $0008;
    INTF_SOFTINT	= $0004;
    INTF_DSKBLK		= $0002;
    INTF_TBE		= $0001;

