{
	GELS.i for PCQ Pascal

	include file for AMIGA GELS (Graphics Elements) 
}


const

{ VSprite flags }
{ user-set VSprite flags: }

    SUSERFLAGS	= $00FF;	{ mask of all user-settable VSprite-flags }
    VSPRITE_f	= $0001;	{ set if VSprite, clear if Bob }
				{ VSPRITE had to be changed for name conflict }
    SAVEBACK    = $0002;	{ set if background is to be saved/restored }
    OVERLAY	= $0004;	{ set to mask image of Bob onto background }
    MUSTDRAW    = $0008;	{ set if VSprite absolutely must be drawn }

{ system-set VSprite flags: }

    BACKSAVED	= $0100;	{ this Bob's background has been saved }
    BOBUPDATE	= $0200;	{ temporary flag, useless to outside world }
    GELGONE	= $0400;	{ set if gel is completely clipped (offscreen) }
    VSOVERFLOW	= $0800;	{ VSprite overflow (if MUSTDRAW set we draw!) }

{ Bob flags }
{ these are the user flag bits }

    BUSERFLAGS	= $00FF;	{ mask of all user-settable Bob-flags }
    SAVEBOB	= $0001;	{ set to not erase Bob }
    BOBISCOMP	= $0002;	{ set to identify Bob as AnimComp }

{ these are the system flag bits }

    BWAITING	= $0100;	{ set while Bob is waiting on 'after' }
    BDRAWN	= $0200;	{ set when Bob is drawn this DrawG pass}
    BOBSAWAY	= $0400;	{ set to initiate removal of Bob }
    BOBNIX	= $0800;	{ set when Bob is completely removed }
    SAVEPRESERVE = $1000;	{ for back-restore during double-buffer}
    OUTSTEP	= $2000;	{ for double-clearing if double-buffer }

{ defines for the animation procedures }

    ANFRACSIZE	= 6;
    ANIMHALF	= $0020;
    RINGTRIGGER	= $0001;


{ UserStuff definitions
 *  the user can define these to be a single variable or a sub-structure
 *  if undefined by the user, the system turns these into innocuous variables
 *  see the manual for a thorough definition of the UserStuff definitions
 *
	Note: because PCQ Pascal has no equivalent to #ifdef, these
	will have to be redefined some other way.
 }

type
    VUserStuff	= SHORT;	{ Sprite user stuff }
    BUserStuff	= SHORT;	{ Bob user stuff }
    AUserStuff  = SHORT;	{ AnimOb user stuff }




{********************** GEL STRUCTURES **********************************}

    VSprite = Record
{
{ --------------------- SYSTEM VARIABLES ------------------------------- }
{ GEL linked list forward/backward pointers sorted by y,x value }

	NextVSprite	: ^VSprite;
	PrevVSprite	: ^VSprite;

{ GEL draw list constructed in the order the Bobs are actually drawn, then
 *  list is copied to clear list
 *  must be here in VSprite for system boundary detection
 }

	DrawPath	: ^VSprite;	{ pointer of overlay drawing }
	ClearPath	: ^VSprite;	{ pointer for overlay clearing }

{ the VSprite positions are defined in (y,x) order to make sorting
 *  sorting easier, since (y,x) as a long integer
 }

	OldY, OldX	: Short;	{ previous position }

{ --------------------- COMMON VARIABLES --------------------------------- }

	Flags		: Short;	{ VSprite flags }


{ --------------------- USER VARIABLES ----------------------------------- }
{ the VSprite positions are defined in (y,x) order to make sorting
 *  sorting easier, since (y,x) as a long integer
 }

	Y, X		: Short;	{ screen position }

	Height	: Short;
	Width	: Short;	{ number of words per row of image data }
	Depth	: Short;	{ number of planes of data }

	MeMask	: Short;	{ which types can collide with this VSprite}
	HitMask	: Short;	{ which types this VSprite can collide with}

	ImageData	: Address;	{ pointer to VSprite image }

{ borderLine is the one-dimensional logical OR of all
 *  the VSprite bits, used for fast collision detection of edge
 }

	BorderLine	: Address; { logical OR of all VSprite bits }
	CollMask	: Address; { similar to above except this is a matrix }

{ pointer to this VSprite's color definitions (not used by Bobs) }

	SprColors	: Address;

	VSBob	: Address;	{ (BobPtr) points home if this VSprite
				   is part of a Bob }

{ planePick flag:  set bit selects a plane from image, clear bit selects
 *  use of shadow mask for that plane
 * OnOff flag: if using shadow mask to fill plane, this bit (corresponding
 *  to bit in planePick) describes whether to fill with 0's or 1's
 * There are two uses for these flags:
 *	- if this is the VSprite of a Bob, these flags describe how the Bob
 *	  is to be drawn into memory
 *	- if this is a simple VSprite and the user intends on setting the
 *	  MUSTDRAW flag of the VSprite, these flags must be set too to describe
 *	  which color registers the user wants for the image
 }

	PlanePick	: Byte;
	PlaneOnOff	: Byte;

	VUserExt	: VUserStuff;	{ user definable:  see note above }
    end;
    VSpritePtr = ^VSprite;




{ dBufPacket defines the values needed to be saved across buffer to buffer
 *  when in double-buffer mode
 }

    DBufPacket = record
	BufY,
	BufX	: Short;	{ save other buffers screen coordinates }
	BufPath	: VSpritePtr;	{ carry the draw path over the gap }

{ these pointers must be filled in by the user }
{ pointer to other buffer's background save buffer }

	BufBuffer : Address;
    end;
    DBufPacketPtr = ^DBufPacket;





    Bob = record
{ blitter-objects }
{
{ --------------------- SYSTEM VARIABLES --------------------------------- }

{ --------------------- COMMON VARIABLES --------------------------------- }

	Flags	: Short; { general purpose flags (see definitions below) }

{ --------------------- USER VARIABLES ----------------------------------- }

	SaveBuffer : Address;	{ pointer to the buffer for background save }

{ used by Bobs for "cookie-cutting" and multi-plane masking }

	ImageShadow : Address;

{ pointer to BOBs for sequenced drawing of Bobs
 *  for correct overlaying of multiple component animations
 }
	Before	: ^Bob;	{ draw this Bob before Bob pointed to by before }
	After	: ^Bob;	{ draw this Bob after Bob pointed to by after }

	BobVSprite : VSpritePtr;	{ this Bob's VSprite definition }

	BobComp	: Address; { (AnimCompPtr) pointer to this Bob's AnimComp def }

	DBuffer	: DBufPacketPtr;	{ pointer to this Bob's dBuf packet }

	BUserExt : BUserStuff;	{ Bob user extension }
    end;
    BobPtr = ^Bob;


    AnimComp = record
{
{ --------------------- SYSTEM VARIABLES --------------------------------- }

{ --------------------- COMMON VARIABLES --------------------------------- }

	Flags	: Short;	{ AnimComp flags for system & user }

{ timer defines how long to keep this component active:
 *  if set non-zero, timer decrements to zero then switches to nextSeq
 *  if set to zero, AnimComp never switches
 }

	Timer	: Short;

{ --------------------- USER VARIABLES ----------------------------------- }
{ initial value for timer when the AnimComp is activated by the system }

	TimeSet	: Short;

{ pointer to next and previous components of animation object }

	NextComp	: ^AnimComp;
	PrevComp	: ^AnimComp;

{ pointer to component component definition of next image in sequence }

	NextSeq	: ^AnimComp;
	PrevSeq	: ^AnimComp;

	AnimCRoutine : Address;	{ address of special animation procedure }

	YTrans	: Short; { initial y translation (if this is a component) }
	XTrans	: Short; { initial x translation (if this is a component) }

	HeadOb	: Address; { AnimObPtr }

	AnimBob	: BobPtr;
    end;
    AnimCompPtr = ^AnimComp;


    AnimOb = record
{
{ --------------------- SYSTEM VARIABLES --------------------------------- }

	NextOb,
	PrevOb	: ^AnimOb;

{ number of calls to Animate this AnimOb has endured }

	Clock	: Integer;

	AnOldY,
	AnOldX	: Short;	{ old y,x coordinates }

{ --------------------- COMMON VARIABLES --------------------------------- }

	AnY,
	AnX	: Short;	{ y,x coordinates of the AnimOb }

{ --------------------- USER VARIABLES ----------------------------------- }

	YVel,
	XVel	: Short;	{ velocities of this object }
	YAccel,
	XAccel	: Short;	{ accelerations of this object }

	RingYTrans,
	RingXTrans	: Short;	{ ring translation values }

	AnimORoutine	: Address;	{ address of special animation 
					  procedure }

	HeadComp	: AnimCompPtr;	{ pointer to first component }

	AUserExt	: AUserStuff;	    { AnimOb user extension }
    end;
    AnimObPtr = ^AnimOb;



{ ************************************************************************ }

const

    B2NORM	= 0;
    B2SWAP	= 1;
    B2BOBBER	= 2;

{ ************************************************************************ }

type

{ a structure to contain the 16 collision procedure addresses }

    collTable = Array [0..15] of Address;
    collTablePtr = ^collTable;

Procedure AddAnimOb(anOb, anKey : AnimObPtr; rp : Address);
    External;			{ rp is a RastPortPtr }

Procedure AddBob(Bob : BobPtr; rp : Address); { rp is a RastPortPtr }
    External;

Procedure AddVSprite(vs : VSpritePtr; rp : Address); { rp is a RastPortPtr }
    External;

Procedure Animate(anKey : AnimObPtr; rp : Address); { rp is a RastPortPtr }
    External;

Procedure DoCollision(rp : Address); { rp is a RastPortPtr }
    External;

Procedure DrawGList(rp : Address; vp : Address);
    External;	{ rp is a RastPortPtr }
		{ vp is a ViewPortPtr }


Procedure FreeGBuffers(anOb : AnimObPtr; rp : Address; db : Boolean);
    External;

Function GetGBuffers(anOb : AnimObPtr; rp : Address; db : Boolean): Boolean;
    External;

Procedure InitGels(head, tail : VSpritePtr; GInfo : Address);
    External;	{ GInfo is a GelsInfoPtr }

Procedure InitGMasks(anOb : AnimObPtr);
    External;

Procedure InitMasks(vs : VSpritePtr);
    External;

Procedure RemBob(bob : BobPtr);
    External;

Procedure RemIBob(bob : BobPtr; rp : Address; vp : Address);
    External;	{ rp is a RastPortPtr }
		{ vp is a ViewPortPtr }

Procedure RemVSprite(vs : VSpritePtr);
    External;

Procedure SetCollision(num : Integer; routine : Address; GInfo : Address);
    External;	{ routine is a procedure }
		{ GInfo is a GelsInfoPtr }

Procedure SortGList(rp : Address);	{ rp is a RastPortPtr }
    External;

