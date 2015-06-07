
	SECTION	PCQ_Runtime,CODE

*	MinStart.asm (of PCQ Pascal runtime library)
*	Copyright (c) 1991 Patrick Quaid

*	This is the minimal startup code.  If the user specifies the
*	-s option on the command line, this code will be linked instead
*	of the normal stuff.  That will preclude the use of New, Dispose,
*	AllocString, any PCQ IO statements (include WriteLn, etc).
*


	XREF	_AbsExecBase
	XREF	_LVOOpenLibrary
	XREF	_LVOFindTask
	XREF	_LVOWaitPort
	XREF	_LVOGetMsg

	XREF	_p%exit

	XREF	_ExitProc
	XREF	_ExitCode
	XREF	_ExitAddr

	XREF	_CommandLine
	XREF	_p%DOSBase
	XREF	_p%IntuitionBase
	XREF	_p%MathBase
	XREF	_p%WorkBenchMsg
	XREF	dosname
	XREF	intuitionname
	XREF	mathname
	XREF	StkPtr
	XREF	newkey
	XREF	_HeapError

;	Define entry point

	xdef	_p%minimal_init
_p%minimal_init

;	Save stack pointer for exit() routine

	move.l	sp,StkPtr	; save stack pointer
	add.l	#4,StkPtr	; account for this jsr to get to original

;	Save the command line pointer to CommandLine

	move.l	a0,_CommandLine
        beq.s   dont_nullit

	move.b	#0,0(a0,d0.w)	; null terminate it

dont_nullit
;	Check for WB or CLI

	move.l	_AbsExecBase,a6
	suba.l	a1,a1
	jsr	_LVOFindTask(a6)
	move.l	d0,a4

;	are we running from a CLI?

	tst.l	172(a4)			; 172 = pr_CLI
	bne	fromCLI

	lea	92(a4),a0		; 92 = pr_MsgPort
	jsr	_LVOWaitPort(a6)
	lea	92(a4),a0
	jsr	_LVOGetMsg(a6)
	move.l	d0,_p%WorkBenchMsg	; save the WB message

	bra	openLibs		; do the rest of the startup


fromCLI:

;	clear the Workbench message

	move.l	#0,_p%WorkBenchMsg

;	Open libraries

openLibs:
	moveq	#0,d0
	move.l	d0,_p%DOSBase
	move.l	d0,_p%MathBase
	move.l	d0,_ExitProc
	move.l	d0,newkey
	move.l	d0,_HeapError

	lea	intuitionname,a1
	jsr	_LVOOpenLibrary(a6)
	move.l	d0,_p%IntuitionBase
	beq	_p%exit

	lea	dosname,a1
	moveq	#0,d0
	jsr	_LVOOpenLibrary(a6)
	move.l	d0,_p%DOSBase
	beq	_p%exit

	lea	mathname,a1
	clr	d0
	jsr	_LVOOpenLibrary(a6)
	move.l	d0,_p%MathBase
	beq	_p%exit

	rts

	END
