*************************************************************************
*									*
* 4/26/89	ArpGlue.asm	by MKSoft, translated by PCQ		*
*									*
*************************************************************************
*									*
*	AmigaDOS Resource Project -- Lattice Library Glue Code		*
*									*
*************************************************************************
*									*
*	Copyright (c) 1989 by MKSoft	For arp.library v39		*
*									*
*	With some ideas from V35 glue by JToebes			*
*									*
*	The arp.library, and related code and files may be freely used	*
*	by supporters of ARP.  Modules in the arp.library may not be	*
*	extracted for use in independent code, but you are welcome to	*
*	provide the arp.library with your work and call on it freely.	*
*									*
*	You are equally welcome to add new functions, improve the ones	*
*	within, or suggest additions.					*
*									*
*	BCPL programs are not welcome to call on the arp.library.	*
*	The welcome mat is out to all others.				*
*									*
*************************************************************************

*
*************************************************************************
*
*	External reference will be made to _ArpBase...
*
		xref		_ArpBase
*
*************************************************************************
*
*	Define the section as code...
*
		section		PCQ_Runtime,code
*
*************************************************************************
*
* Some macros to help with the work...
*

GLUE_DEF	MACRO
		xdef		_\1
_\1:

THIS_LIB	SET		_LVO\1		; Set the arp offset to call
		ENDM

CALL_ARP	MACRO
		move.l		a6,-(sp)	; Save a6...
		move.l		_ArpBase,a6	; If not a4 addressing...
		jsr		THIS_LIB(a6)
		move.l		(sp)+,a6
		ENDM
*
*************************************************************************
*
*	Now for the Printf... etc has to be done via glue since
*	it has a variable number of parameters...
*
		GLUE_DEF	Printf		; The Printf glue...
		move.l		4(sp),a1
		lea.l		8(sp),a0
		CALL_ARP
		rts				; return...
*
		GLUE_DEF	FPrintf		; Now, for the FPrintf glue...
		move.l		4(sp),a1
		move.l		8(sp),a0
		move.l		12(sp),d0
		CALL_ARP
		rts
*
		GLUE_DEF	SPrintf		; Same for SPrintf...
		move.l		4(sp),a1
		move.l		8(sp),a0
		move.l		12(sp),d0
		CALL_ARP
		rts

*
*************************************************************************
*	Now come some of the trackers...  Note that the tracker in	*
*	IoErr() will be invalid if the return is NULL			*
*************************************************************************
*

		GLUE_DEF	ArpOpen		; Tracked Open()
		movem.l		4(sp),d1/d2
		CALL_ARP
		bra.s		Check_Save	; Save tracker...
*
		GLUE_DEF	ArpOpenLibrary	; Tracked OpenLibrary()
		movem.l		4(sp),d0/a1
		CALL_ARP
		bra.s		Check_Save	; Save tracker...
*
		GLUE_DEF	ArpLock		; Tracked Lock()
		movem.l		4(sp),d1/d2
		CALL_ARP
		bra.s		Check_Save	; Save tracker...
*
	GLUE_DEF	ArpAllocFreq		; Last minute addition
	CALL_ARP
	bra.s	Check_Save
*
		GLUE_DEF	ArpDupLock	; Tracked DupLock()
		move.l		4(sp),d1
		CALL_ARP			; Drop into Check_Save...
*
*************************************************************************
*	This does the voodoo of saving the a1 register into IoErr()	*
*	This was put in the middle as to make sure all relative		*
*	branches will reach it...					*
*************************************************************************
*
Check_Save:	tst.l		d0		; Check for return error...
		beq.s		Exit_Save	; If error, skip setting...
Save_Second:	move.l		4,a0
		move.l		ThisTask(a0),a0
		move.l		a1,pr_Result2(a0)
Exit_Save:	rts
*
*************************************************************************
*	Now, with some more bindings...	( Not the skiing type :-( )	*
*************************************************************************
*
		GLUE_DEF	ArpAllocMem	; Tracked AllocMem()
		movem.l		4(sp),d0/d1
		CALL_ARP
		bra.s		Check_Save	; Save tracker...
*
		GLUE_DEF	RListAlloc	; ResList allocate...
		move.l		4(sp),a0
		move.l		8(sp),d0
		CALL_ARP
		bra.s		Save_Second	; Save tracker...
*
*************************************************************************
*	This gets a tracker and then, from the argument passed, puts	*
*	the ID into it.  While the ID is a WORD, for calling reasons	*
*	the binding/prototype uses a LONG.  (680x0 stack alignment...)	*
*************************************************************************
*
		GLUE_DEF	GetTracker	; Get Tracker (With ID)
		CALL_ARP
		beq.s		No_Tracker	; No tracker, ERROR!
		move.w		6(sp),dt_ID(a1)	; Save ID  (It was LONG)
No_Tracker:	move.l		a1,d0		; Put into return register
		bra.s		Save_Second	; Also save it...
*
*************************************************************************
*	And, there you have it.  Now you too can call on ARP.		*
*************************************************************************
*
		END
