{
    Display.i for PCQ Pascal

    include define file for display control registers 
}

const

{ bplcon0 defines }

    MODE_640	= $8000;
    PLNCNTMSK	= $7;		{ how many bit planes? }
				{ 0 = none, 1->6 = 1->6, 7 = reserved }
    PLNCNTSHFT  = 12;		{ bits to shift for bplcon0 }
    PF2PRI	= $40;		{ bplcon2 bit }
    COLORON	= $0200;	{ disable color burst }
    DBLPF	= $400;
    HOLDNMODIFY	= $800;
    INTERLACE	= 4;		{ interlace mode for 400 }

{ bplcon1 defines }

    PFA_FINE_SCROLL		= $F;
    PFB_FINE_SCROLL_SHIFT	= 4;
    PF_FINE_SCROLL_MASK		= $F;

{ display window start and stop defines }

    DIW_HORIZ_POS	= $7F;	{ horizontal start/stop }
    DIW_VRTCL_POS	= $1FF;	{ vertical start/stop }
    DIW_VRTCL_POS_SHIFT	= $7;

{ Data fetch start/stop horizontal position }

    DFTCH_MASK	= $FF;

{ vposr bits }

    VPOSRLOF	= $8000;

