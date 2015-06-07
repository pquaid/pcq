{
	Custom.i for PCQ Pascal
}

Type

    AudChannel = record
	ac_ptr		: Address;	{ ptr to start of waveform data }
	ac_len		: Short;	{ length of waveform in words }
	ac_per		: Short;	{ sample period }
	ac_vol		: Short;	{ volume }
	ac_dat		: Short;	{ sample pair }
	ac_pad		: Array [0..1] of Short;	{ unused }
    end;
    AudChannelPtr = ^AudChannel;

    SpriteDef = record
	pos		: Short;
	ctl		: Short;
	dataa		: Short;
	datab		: Short;
    end;
    SpriteDefPtr = ^SpriteDef;

    Custom = record
	bltddat		: Short;
	dmaconr		: Short;
	vposr		: Short;
	vhposr		: Short;
	dskdatr		: Short;
	joy0dat		: Short;
	joy1dat		: Short;
	clxdat		: Short;
	adkconr		: Short;
	pot0dat		: Short;
	pot1dat		: Short;
	potinp		: Short;
	serdatr		: Short;
	dskbytr		: Short;
	intenar		: Short;
	intreqr		: Short;
	dskpt		: Address;
	dsklen		: Short;
	dskdat		: Short;
	refptr		: Short;
	vposw		: Short;
	vhposw		: Short;
	copcon		: Short;
	serdat		: Short;
	serper		: Short;
	potgo		: Short;
	joytest		: Short;
	strequ		: Short;
	strvbl		: Short;
	strhor		: Short;
	strlong		: Short;
	bltcon0		: Short;
	bltcon1		: Short;
	bltafwm		: Short;
	bltalwm		: Short;
	bltcpt		: Address;
	bltbpt		: Address;
	bltapt		: Address;
	bltdpt		: Address;
	bltsize		: Short;
	pad2d		: Array [0..2] of Short;
	bltcmod		: Short;
	bltbmod		: Short;
	bltamod		: Short;
	bltdmod		: Short;
	pad34		: Array [0..3] of Short;
	bltcdat		: Short;
	bltbdat		: Short;
	bltadat		: Short;
	pad3b		: Array [0..3] of Short;
	dsksync		: Short;
	cop1lc		: Integer;
	cop2lc		: Integer;
	copjmp1		: Short;
	copjmp2		: Short;
	copins		: Short;
	diwstrt		: Short;
	diwstop		: Short;
	ddfstrt		: Short;
	ddfstop		: Short;
	dmacon		: Short;
	clxcon		: Short;
	intena		: Short;
	intreq		: Short;
	adkcon		: Short;
	aud		: Array [0..3] of AudChannel;
	bplpt		: Array [0..5] of Address;
	pad7c		: Array [0..3] of Short;
	bplcon0		: Short;
	bplcon1		: Short;
	bplcon2		: Short;
	pad83		: Short;
	bpl1mod		: Short;
	bpl2mod		: Short;
	pad86		: Array [0..1] of Short;
	bpldat		: Array [0..5] of Short;
	pad8e		: Array [0..1] of Short;
	sprpt		: Array [0..7] of Address;
	spr		: Array [0..7] of SpriteDef;
	color		: Array [0..31] of Short;
    end;
    CustomPtr = ^Custom;

